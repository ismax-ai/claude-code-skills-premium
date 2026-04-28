---
description: "Superviseur pré-publication : 6 passes séquentielles, 1 seul FAIL bloque tout"
---

# /eagle-supervisor — L'Aigle Superviseur

## Ce que ce skill résout

Les vérifications individuelles (orthographe, ton, structure) ratent les incohérences ENTRE les règles, les oublis systémiques et la dérive progressive du ton. Ce skill exécute 6 passes séquentielles sur le contenu. Chaque passe a un verdict (PASS, WARN, FAIL). Un seul FAIL bloque la publication.

## Quand l'invoquer

- APRÈS rédaction, AVANT publication
- Quand tu veux un dernier check qualité
- Quand le contenu a été réécrit 2+ fois (risque de dérive)
- En cas de doute sur la qualité

## Les 6 passes

---

## PASSE A — FORMAT

Identifier le format du contenu pour appliquer les bons critères.

```
FORMAT DÉTECTÉ : [article | newsletter | post social | carrousel | email | landing page | doc | autre]
CRITÈRES CHARGÉS : [adaptés au format]
```

Sans cette identification, les 5 passes suivantes utilisent les mauvais seuils.

---

## PASSE B — STRUCTURE

Le contenu a-t-il une architecture complète ?

- [ ] Le hook (accroche) est-il présent et pertinent ?
- [ ] Les sections s'enchaînent-elles logiquement ?
- [ ] Les transitions entre blocs sont-elles fluides ? (pas de saut brutal)
- [ ] Le fil rouge est-il clair du début à la fin ?
- [ ] Le CTA (appel à l'action) est-il présent et cohérent avec le contenu ?
- [ ] Pas de section orpheline (bloc qui ne sert pas le propos) ?

Verdict : PASS si tous les checks OK. FAIL si un élément structurel manque.

---

## PASSE C — LANGUE

Le texte sonne-t-il comme un humain ou comme un robot ?

### Détection robotique (5 signaux)
1. **Staccato nominatif** : 3+ phrases courtes sans verbe d'affilée → FAIL
2. **Calque syntaxique** : structures traduites de l'anglais ("Pas par X. Parce que Y.") → FAIL
3. **Deux-points de présentation** : abus de "L'objectif : faire X" → WARN
4. **Rythme monotone** : 3+ phrases consécutives de même longueur (±3 mots) → WARN
5. **Langage marketing creux** : "incroyable", "game-changer", "révolutionnaire", "transforme ton business" → FAIL

### Vérification authenticité
- [ ] Le texte utilise-t-il des connecteurs naturels ? (du coup, en fait, bon, bref, d'ailleurs)
- [ ] La ponctuation est-elle variée et naturelle ?
- [ ] Les phrases varient-elles en longueur ? (court, moyen, long)
- [ ] 0 pattern IA détecté ? (pas de tirets longs, pas de listes à puces infinies, pas de "plongeons dans...")
- [ ] 0 phrase de remplissage ? (pas de "dans le monde d'aujourd'hui", "il est important de noter que")

Verdict : PASS si 0 FAIL et max 2 WARN. FAIL si 1+ FAIL ou 3+ WARN.

---

## PASSE D — TON

Le texte sonne-t-il comme TOI (l'auteur) ou comme un chatbot ?

### Le test "à voix haute"
- [ ] Énergie calme et confiante ? (pas d'exclamation forcée, pas de dramatisation)
- [ ] Registre cohérent du début à la fin ? (pas de changement brutal de ton)
- [ ] Pas de flatterie ? ("bonne question", "tu soulèves un point excellent")
- [ ] Pas de condescendance ? ("je t'explique", "c'est simple", "tu verras")
- [ ] Pas d'enthousiasme forcé ? ("c'est incroyable", "tu vas adorer", "c'est un must")
- [ ] Le texte sonne comme quelqu'un qui SAIT et qui EXPLIQUE, pas qui VEND ?

**Méthode** : lire les 3 premiers paragraphes à voix haute.
- Si ça sonne comme une présentation PowerPoint → FAIL
- Si ça sonne comme un message à un collègue → PASS

Verdict : PASS si le texte sonne authentique. FAIL si ça sonne IA, marketeur, ou prof.

---

## PASSE E — AUDIENCE

Le contenu est-il compréhensible par l'audience cible ?

- [ ] Chaque terme technique est-il expliqué à sa première mention ?
- [ ] Le contenu est-il actionnable sans connaissances techniques préalables ?
- [ ] Pas de jargon non expliqué ?
- [ ] Un non-expert pourrait-il résumer le message principal en 1 phrase ?
- [ ] Le contenu respecte-t-il le "test du pote au café" ? (tu l'expliquerais comme ça à un ami)

Verdict : PASS si l'audience cible comprend tout. FAIL si un terme technique n'est pas expliqué.

---

## PASSE F — PROMESSE

Le titre est-il tenu dans le contenu ?

- [ ] La promesse du titre/hook est-elle délivrée dans le corps ?
- [ ] Le lecteur obtient-il concrètement ce qui était annoncé ?
- [ ] Les chiffres et affirmations sont-ils cohérents entre le titre et le corps ?
- [ ] Le CTA est-il aligné avec la promesse initiale ?
- [ ] Pas de clickbait ? (promesse > contenu = clickbait)

Verdict : PASS si la promesse est tenue. FAIL si le titre promet quelque chose que le contenu ne délivre pas.

---

## Format de sortie

```
🦅 EAGLE SUPERVISOR — [FORMAT DÉTECTÉ]
═══════════════════════════════════════

PASSE A — FORMAT : [format] ✅
PASSE B — STRUCTURE : [PASS|WARN|FAIL]
  [détails si WARN/FAIL]
PASSE C — LANGUE : [PASS|WARN|FAIL]
  [signaux robotiques détectés si WARN/FAIL]
PASSE D — TON : [PASS|WARN|FAIL]
  [ce qui ne sonne pas authentique si WARN/FAIL]
PASSE E — AUDIENCE : [PASS|WARN|FAIL]
  [termes non expliqués si WARN/FAIL]
PASSE F — PROMESSE : [PASS|WARN|FAIL]
  [éléments manquants si WARN/FAIL]

═══════════════════════════════════════
VERDICT : [PUBLIE | CORRIGE AVANT | REWRITE]
[corrections par priorité si CORRIGE/REWRITE]
```

---

## Ce que ce skill ne fait PAS

- Il ne réécrit pas le contenu (c'est ton job)
- Il ne change pas les règles (il les applique)
- Il dit "non" quand personne d'autre ne le dit

Ce skill supervise. Il détecte les patterns que les vérifications individuelles ratent, la dérive progressive, et bloque ce qui n'est pas prêt.

---

## Intégration

Ce skill est le DERNIER contrôle avant publication :

1. Rédaction
2. Relecture / vérification langue
3. **🦅 /eagle-supervisor** (supervision globale)
4. Publication

Si le verdict est FAIL → retour à l'étape 1 ou 2 selon le problème.
