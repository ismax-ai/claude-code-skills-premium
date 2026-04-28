---
name: anti-fabrication
description: "Linter sémantique qui détecte les 10 types de fabrication dans un texte (faits inventés, fausse précision, URLs fictives, simplification abusive, etc.). Produit un rapport avec localisation par paragraphe, sévérité, et corrections proposées. Fonctionne sur les textes générés par l'IA ou sur des textes externes."
tools: Read, Bash, Grep
---

# /anti-fabrication — Détecteur de fabrication dans un texte

Analyse un texte et détecte les affirmations fabriquées, les chiffres inventés, les sources fictives, et les raisonnements biaisés. Produit un rapport avec la localisation exacte de chaque problème et une correction proposée.

## Quand l'utiliser

- Après avoir fait rédiger un texte par Claude (ou un autre LLM) et avant de le publier
- Pour auditer un texte reçu (article, email, document) dont tu doutes de la fiabilité
- Avant d'envoyer une proposition commerciale, une présentation, ou un contenu public

## Comment il fonctionne

Le skill opère en 3 passes séquentielles. Chaque passe a un rôle différent pour éviter le biais de confirmation (l'auteur qui valide son propre texte).

### Passe 1 — Extraction des claims

Lire le texte et extraire chaque affirmation factuelle (fait, chiffre, statistique, citation, attribution, lien). Ignorer les opinions, les questions, et les formulations conditionnelles.

Pour chaque claim, noter :
- Le paragraphe et la phrase exacte
- Le type de claim : fait, chiffre, citation, attribution, lien, comparaison, absolu

### Passe 2 — Détection (10 détecteurs)

Pour chaque claim extrait, passer les 10 détecteurs dans cet ordre :

| ID | Détecteur | Ce qu'il cherche | Sévérité |
|---|---|---|---|
| F01 | Fait inventé | Affirmation spécifique sans source identifiable. Aucun document fourni ne contient cette information. | CRITICAL |
| F02 | Simplification abusive | Un sujet complexe réduit à une affirmation simple qui perd des nuances importantes. Souvent après "en résumé", "en gros", "simplement". | HIGH |
| F03 | Attribution sans source | "Selon les experts", "les études montrent", "il est reconnu que" sans nommer la source exacte. | CRITICAL |
| F04 | Extrapolation silencieuse | Une conclusion qui dépasse ce que les données permettent d'affirmer, présentée comme un fait. | HIGH |
| F05 | Déformation | Un fait réel accompagné d'une interprétation biaisée qui oriente le lecteur vers une conclusion non justifiée. | HIGH |
| F06 | Omission contradictoire | Un argument présenté sans sa contrepartie connue. Si le sujet a des pour ET des contre, et que seuls les pour sont mentionnés. | MEDIUM |
| F07 | Fausse précision | Un chiffre avec décimales ("14,3%", "6,1 milliards") sans source, qui donne une illusion de rigueur. Les chiffres ronds ("environ 6 milliards") sont aussi suspects s'ils ne sont pas sourcés. | CRITICAL |
| F08 | Hypothèse présentée comme fait | Une supposition ou une estimation présentée sans conditionnel, sans "probablement", sans "je suppose". | HIGH |
| F09 | URL ou source inventée | Un lien, un DOI, une référence bibliographique qui n'a pas été extraite d'un document fourni. Toute URL générée par l'IA est suspecte par défaut. | CRITICAL |
| F10 | Rationalisation | Après une correction, reformuler l'erreur comme une nuance ("en effet, c'est plus nuancé que ce que j'ai dit") au lieu de reconnaître l'erreur. | MEDIUM |

Règles de détection :

- Un claim avec source vérifiable (document uploadé, URL connue, citation exacte) = CLEAN.
- Un claim avec "c'est une connaissance générale" = CLEAN si c'est effectivement trivial (Paris est la capitale de la France). SUSPECT si c'est un chiffre précis ou une affirmation technique.
- Un claim avec "je ne sais pas" ou "je n'ai pas cette information" = CLEAN (l'honnêteté n'est pas une fabrication).
- Un claim conditionnel ("probablement", "il est possible que", "selon mon estimation") = CLEAN si le conditionnel est explicite.

### Passe 3 — Vérification croisée (si documents disponibles)

Si des documents ont été uploadés dans le projet ou fournis dans la conversation :

Pour chaque claim détecté en CRITICAL ou HIGH, chercher une citation exacte dans les documents qui confirme ou infirme le claim.

- Citation trouvée qui confirme → reclasser en CLEAN
- Citation trouvée qui contredit → CONFIRMED FABRICATION
- Aucune citation trouvée → maintenir la détection

Cette passe utilise la technique Chain of Verification (CoVe) documentée par la recherche en IA : générer les claims, puis vérifier chaque claim indépendamment contre les sources disponibles.

## Niveau de confiance du rapport

Le skill indique le niveau de confiance de son propre rapport :

| Contexte | Confiance | Pourquoi |
|---|---|---|
| Texte externe + documents de référence | HAUTE | L'auditeur (Claude) n'a pas écrit le texte et peut croiser avec les documents |
| Texte externe sans documents | MOYENNE | Pas de biais d'auteur mais pas de source pour vérifier |
| Texte généré par Claude + documents | MOYENNE | Biais d'auteur possible mais les documents permettent de croiser |
| Texte généré par Claude sans documents | BASSE | Biais d'auteur + pas de source de vérification. Le rapport reste utile mais ne remplace pas une vérification humaine |

## Format de sortie

```
ANTI-FABRICATION — Rapport d'audit
═══════════════════════════════════════════════════

Source du texte : [généré par IA / externe]
Documents de référence : [oui (N documents) / non]
Confiance du rapport : [HAUTE / MOYENNE / BASSE]

VERDICT : [FIABLE / À VÉRIFIER / NON FIABLE]
  CRITICAL : X détection(s)
  HIGH     : Y détection(s)
  MEDIUM   : Z détection(s)

───────────────────────────────────────────────────
DÉTECTIONS :

[F01 CRITICAL] § 2, phrase 3
  "Le marché pèse 6,1 milliards d'euros"
  Fait inventé — aucun document fourni ne contient cette donnée.
  Correction : remplacer par "je n'ai pas de chiffre fiable sur
  ce marché" ou citer la source avec la date de la donnée.

[F07 CRITICAL] § 2, phrase 3
  "avec une croissance annuelle de 14,3%"
  Fausse précision — pourcentage avec décimale sans source.
  Correction : supprimer ou citer la source exacte (nom, date, page).

[F06 MEDIUM] § 5, phrase 1
  "Claude est le meilleur outil pour cette tâche"
  Omission contradictoire — pas de mention des alternatives.
  Correction : nuancer avec "par rapport à [X et Y]" ou ajouter
  les limites connues.

───────────────────────────────────────────────────
FIABILITÉ PAR SECTION :
  Introduction    : ✓ FIABLE
  Section 1       : ✗ NON FIABLE (2 CRITICAL)
  Section 2       : ⚠ À VÉRIFIER (1 MEDIUM)
  Conclusion      : ✓ FIABLE

RÉSUMÉ PAR TYPE :
  F01 Faits inventés         : 1
  F06 Omission contradictoire: 1
  F07 Fausse précision       : 1

CLAIMS VÉRIFIÉS (passe 3) :
  "Paris est la capitale de la France" → CLEAN (connaissance générale triviale)
  "Anthropic recommande < 500 mots" → CLEAN (confirmé doc Custom Instructions)
═══════════════════════════════════════════════════
```

## Verdicts

| Condition | Verdict |
|---|---|
| 0 CRITICAL et 0 HIGH | FIABLE — le texte peut être publié |
| 0 CRITICAL et 1-3 HIGH | À VÉRIFIER — corriger les HIGH avant publication |
| 1+ CRITICAL | NON FIABLE — ne pas publier en l'état |

## Usage

```
/anti-fabrication                     → analyser le dernier texte généré
/anti-fabrication "texte à analyser"  → analyser un texte spécifique
/anti-fabrication fichier.md          → analyser un fichier
```

## Auto-amélioration : le skill retient tes corrections

Ce skill s'améliore à chaque utilisation. Il ne fait pas du machine learning. Il fait quelque chose de plus simple et de plus fiable : il retient tes corrections dans un fichier local et ajuste sa sensibilité en conséquence.

### Comment ça fonctionne

Au premier audit, le skill crée un dossier `~/.claude/anti-fabrication/` avec 3 fichiers :

```
~/.claude/anti-fabrication/
├── log.json       ← historique de chaque audit (append-only)
├── learned.json   ← patterns appris (précision par détecteur, contextes fiables)
└── stats.json     ← métriques agrégées
```

Après chaque rapport, le skill te demande : "Des faux positifs dans ce rapport ?"

Tu réponds en langage naturel. Par exemple : "Le chiffre du paragraphe 2 est correct, il vient du rapport Xerfi 2025." Le skill enregistre cette correction et la classe comme `dismissed_with_source`.

### Ce que le skill retient

Pour chaque détecteur (F01 à F10), le skill calcule sa précision :

```
précision = (détections confirmées) / (total détections)
```

Si un détecteur passe en dessous de 50% de précision (plus de faux positifs que de vrais positifs), le skill baisse automatiquement sa sévérité. Il passe de CRITICAL à HIGH, ou de HIGH à MEDIUM. Il ne supprime jamais un détecteur, il ajuste sa sensibilité.

Si tu confirmes qu'un domaine est fiable en fournissant la source 3 fois (par exemple, tu cites toujours les données Xerfi quand tu parles de formation en ligne), le skill crée un contexte de confiance. Il arrête de flagger les chiffres dans ce domaine quand une source est fournie.

Le skill ne baisse jamais sa garde sans preuve. Si tu dis "c'est correct" sans fournir de source, ça ne compte pas comme un contexte de confiance. Seules les corrections avec source alimentent l'apprentissage.

### Le rapport d'amélioration

Après 10 audits, tu peux demander un rapport d'amélioration :

```
/anti-fabrication stats
```

Le rapport montre :

```
ANTI-FABRICATION — Rapport d'amélioration
═══════════════════════════════════════════

Audits effectués : 10
Claims analysés : 127
Détections totales : 34
Faux positifs confirmés : 6

PRÉCISION PAR DÉTECTEUR :
  F01 Fait inventé         : 95% (19/20) — FIABLE
  F03 Attribution          : 88% (7/8)  — FIABLE
  F07 Fausse précision     : 60% (3/5)  — SENSIBILITÉ BAISSÉE
  F08 Hypothèse = fait     : 100% (1/1) — PAS ASSEZ DE DONNÉES

CONTEXTES DE CONFIANCE :
  ✓ "formation en ligne" : source Xerfi confirmée 3x
    → F01/F07 ajustés dans ce contexte

ÉVOLUTION :
  Audits 1-5 : 4 faux positifs sur 18 détections (78% précision)
  Audits 6-10 : 2 faux positifs sur 16 détections (88% précision)
═══════════════════════════════════════════
```

### Réinitialisation

Si le skill devient trop permissif ou si tu changes de domaine de travail :

```
/anti-fabrication reset
```

Supprime les fichiers learned.json et stats.json. Le log.json est conservé comme historique.

### Usage

```
/anti-fabrication                → auditer le dernier texte
/anti-fabrication "texte"        → auditer un texte spécifique
/anti-fabrication fichier.md     → auditer un fichier
/anti-fabrication stats          → rapport d'amélioration (après 10+ audits)
/anti-fabrication reset          → réinitialiser l'apprentissage
```

## Ce que ce skill ne fait pas

- Il ne corrige pas le texte automatiquement. Il détecte et propose des corrections que tu valides.
- Il ne vérifie pas les faits sur internet. Il vérifie contre les documents fournis et contre la cohérence interne du texte.
- Il ne remplace pas la vérification humaine. Sur les textes générés par l'IA avec une confiance BASSE, le rapport est un premier filtre, pas le dernier.

## Combinaison avec d'autres skills

Ce skill fonctionne seul. Si tu as d'autres skills installés, tu peux les combiner :

- `/anti-fabrication` puis `/sentinel` pour un Red Team complet (faits + argumentation)
- `/anti-fabrication` puis `/eli5` pour vérifier les faits puis simplifier le langage
- `/anti-fabrication` puis `/eagle-supervisor` pour un audit final avant publication
