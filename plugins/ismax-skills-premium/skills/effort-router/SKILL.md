---
description: "Routage automatique d'effort : adapte la profondeur de réflexion (low/medium/high/max) a chaque tâche pour éliminer la sur-réflexion sur les tâches simples et la sous-réflexion sur les tâches critiques"
---

# /effort-router — Le Régulateur

> Skill original par [Ismax](https://github.com/ismax-ai).

## Ce que ce skill résout

Depuis Opus 4.6, Claude utilise l'extended thinking : une phase de réflexion interne avant chaque réponse. Cette réflexion consomme des tokens. Par défaut, l'effort est règle sur `medium` pour toutes les tâches, quelle que soit leur complexité.

Problème : renommer un fichier et concevoir une architecture distribuee consomment le même budget de réflexion. Sur les tâches simples, Claude gaspille des tokens en réflexion inutile. Sur les tâches critiques, il ne réfléchit pas assez.

Ce skill adapte le comportement de Claude (profondeur d'analyse, nombre d'alternatives considérées, détail de la réponse) en fonction de la complexité reelle de chaque tâche.

## Comment fonctionne l'extended thinking dans Claude

L'extended thinking est une phase de raisonnement interne que Claude exécuté avant de générer sa réponse. Cette phase :
- Consomme des tokens (entre 500 et 50 000+ selon le niveau)
- N'est pas visible dans la réponse finale
- Est contrôlée par le paramètre `/effort` (low, medium, high, max)

La différence de consommation entre `max` et `low` peut atteindre 10x. En pratique, utiliser `medium` pour tout revient a payer le prix moyen pour des tâches qui n'en ont pas besoin.

Ce skill ne modifie pas le paramètre `/effort` (c'est un reglage système). Il adapte le COMPORTEMENT de Claude : longueur de réponse, profondeur d'analyse, nombre d'alternatives évaluées, détail des justifications.

## Les 4 niveaux

### LOW — Exécution directe

Tâches ou la réponse est évidente. Pas de délibération nécessaire.

| Signal | Exemples |
|--------|----------|
| Renommer, déplacer, copier | "Renomme ce fichier en kebab-case" |
| Lister, compter, scanner | "Liste tous les .py dans src/" |
| Formater, indenter, trier | "Trie ces imports par ordre alphabetique" |
| Répondre factuellement | "C'est quoi la syntaxe de map() en JS ?" |
| Supprimer du code mort | "Supprime les imports inutilises" |
| Chercher un fichier/pattern | "Trouve ou est défini UserService" |
| Générer du boilerplate standard | "Créé un Dockerfile basique pour ce projet Node" |

**Comportement LOW** : réponse directe, pas d'alternatives, pas de considerations, pas d'avertissements superflus.

### MEDIUM — Travail courant

Tâches qui demandent de la réflexion dans un scope limite. Un seul fichier, un seul composant, résultat previsible.

| Signal | Exemples |
|--------|----------|
| Modifier du code existant | "Ajoute un champ email a ce formulaire" |
| Corriger un bug simple | "Ce bouton ne redirige pas, corrige" |
| Écrire un test unitaire | "Ecris les tests pour cette fonction" |
| Refactorer localement | "Extrais cette logique dans une fonction" |
| Expliquer du code | "Explique-moi ce que fait ce middleware" |
| Écrire de la documentation | "Documente cette API" |

**Comportement MEDIUM** : considérer 1-2 approches, mentionner les implications directes. Pas d'analyse exhaustive.

### HIGH — Analyse approfondie

Tâches complexes. Multi-fichiers, effets de bord, décisions a prendre. Une erreur a des consequences.

| Signal | Exemples |
|--------|----------|
| Debug multi-fichiers | "L'auth casse après le deploy, trouve pourquoi" |
| Concevoir une feature | "Ajoute un système de notifications real-time" |
| Refactorer un module entier | "Refactoré le module de paiement" |
| Écrire un plan technique | "Planifie la migration de REST a GraphQL" |
| Review de code | "Review cette PR, je veux pas de surprises" |
| Optimiser les performances | "La page met 4s a charger, optimise" |

**Comportement HIGH** : analyser en profondeur, considérer 3+ approches, anticiper les effets de bord, vérifier les implications.

### MAX — Mode expert

Réservé aux problèmes ou une erreur coûte cher. Décisions irréversibles, production, sécurité.

| Signal | Exemples |
|--------|----------|
| Décision architecturale | "Monolith ou microservices ?" |
| Sécurité / audit | "Vérifié les failles d'injection" |
| Bug non reproduisible | "Ça crash en prod 1 fois sur 10" |
| Migration de donnees critique | "Migre la DB, zero perte, zero downtime" |
| Design système a grande échelle | "Système de file d'attente pour 10K req/s" |

**Comportement MAX** : investigation exhaustive, tous les angles consideres, chaque affirmation justifiee.

---

## Arbre de décision

```
1. Action mecanique sans ambiguite ?
   (renommer, lister, copier, formater, factuel)
   OUI → LOW
   NON ↓

2. Scope = 1 fichier/composant, resultat previsible ?
   OUI → MEDIUM
   NON ↓

3. Signal critique detecte ? (voir Signaux de surclassement)
   OUI + consequences irreversibles → MAX
   OUI + scope limite → HIGH
   NON → MEDIUM

4. Doute sur le niveau ?
   → Monter d'un cran. Sur-reflechir coute des tokens. Sous-reflechir coute des erreurs.
```

### Signaux de surclassement (prioritaires)

Ces signaux l'emportent TOUJOURS sur les signaux de déclassement.

| Signal détecté | Niveau minimum |
|----------------|----------------|
| "production", "prod", "deploy" | HIGH |
| "sécurité", "injection", "auth", "faille" | HIGH (souvent MAX) |
| "migration", "sans perte", "zero downtime" | MAX |
| "architecture", "système", "design system" | HIGH |
| "critique", "irréversible" | HIGH |
| "décision", "choix stratégique" | MAX |
| Suppression de donnees en prod | MAX |

### Signaux de déclassement (sauf si surclassement present)

| Signal détecté | Niveau maximum |
|----------------|----------------|
| "juste", "vite fait", "rapidement" | MEDIUM |
| "montre-moi", "affiche", "liste" | LOW |
| "renomme", "déplacé", "supprime" (hors prod) | LOW |
| "c'est quoi", "comment on fait" (factuel simple) | LOW |

**Règle** : si surclassement ET déclassement dans le même message, le surclassement gagne. "Supprime juste les users inactifs en prod" = MAX, pas LOW.

---

## Cas limites

| Tâche | Classification | Raison |
|-------|---------------|--------|
| "Ecris un Dockerfile pour ce projet" | **MEDIUM** | Choix d'image, multi-stage, sécurité des layers. Si "basique" → LOW. |
| "Explique-moi pourquoi X ne marche pas" | **MEDIUM** | Diagnostic sans fix, réflexion nécessaire. |
| "Supprime les imports inutilises" dans un fichier de 200 imports | **MEDIUM** | Volume = complexité. Effets de bord possibles sur des re-exports. |
| "Corrige ce bug en prod" | **HIGH** | "Prod" surclasse tout. |
| "Fais un README" | **LOW** | Documentation standard. |
| "Fais un README pour ce projet open-source" | **MEDIUM** | Décisions de communication et structure. |
| "Refactoré tout le module auth" | **HIGH** | Multi-fichiers, sécurité impliquee, effets de bord. |

---

## Correction de route

Le classement automatique n'est pas parfait. L'utilisateur peut corriger en cours de session.

### Monter (sous-estimation détectée)

| L'utilisateur dit | Action |
|-------------------|--------|
| "va plus loin", "creuse plus" | Monter d'un niveau, re-analyser |
| "c'est plus complexe que ça" | Monter d'un niveau |
| "t'as pas considéré X" | Monter d'un niveau, intégrer X |
| "mode max" / "reflechis a fond" | MAX |

### Descendre (sur-estimation détectée)

| L'utilisateur dit | Action |
|-------------------|--------|
| "pas besoin d'autant de détail" | Descendre d'un niveau |
| "fais-le juste", "exécuté" | LOW |
| "trop long", "plus court" | Descendre d'un niveau |

Après une correction, ajuster le calibrage pour les messages suivants de la même session. Si l'utilisateur dit "creuse plus" sur un type de tâche, classer les tâches similaires un cran au-dessus pour le reste de la session.

---

## Affichage

Une ligne en début de réponse, uniquement quand le niveau change.

```
⚡ LOW — execution directe
```

```
⚙️ MEDIUM — reflexion standard
```

```
🔥 HIGH — analyse approfondie
```

```
🧠 MAX — reflexion maximale
```

Si le niveau est le même qu'au message précédent, ne rien afficher.

---

## Override utilisateur

L'utilisateur peut forcer un niveau a tout moment. Son override a toujours priorité.

- "Fais ça en mode max" → MAX
- "Vite fait" → LOW
- `/effort high` → override pour ce message

---

## Diagnostic de session

Si l'utilisateur tape `/effort-router` sans tâche :

```
⚙️ EFFORT ROUTER — Diagnostic
═══════════════════════════════════════

Messages traites : [N]
Distribution :
  ⚡ LOW    : [X] ([%]%)
  ⚙️ MEDIUM : [X] ([%]%)
  🔥 HIGH   : [X] ([%]%)
  🧠 MAX    : [X] ([%]%)

Corrections utilisateur : [N]
  ↑ Montees : [X]
  ↓ Descentes : [X]

Calibrage : [stable | tendance haute | tendance basse]
═══════════════════════════════════════
```

---

## Ce que ce skill ne fait pas

- **Ne change pas le modèle.** Haiku/Sonnet/Opus = quel cerveau. Effort = combien de réflexion. Pour le model routing, voir `/model`.
- **Ne compresse pas le contexte.** C'est le job du compactage et de token-optimizer.
- **Ne modifie pas le paramètre système `/effort`.** Il adapte le comportement de Claude (profondeur, détail, alternatives). L'utilisateur peut aussi taper `/effort [niveau]` directement.

---

## Gains mesurables

| Situation | Sans routing | Avec routing | Économie |
|-----------|-------------|-------------|----------|
| Renommer 5 fichiers | 5x MEDIUM (~2500 tokens thinking) | 5x LOW (~500 tokens thinking) | ~80% |
| Session mixte (70% simple, 30% complexe) | Tout en MEDIUM | LOW/MEDIUM/HIGH adaptes | ~40% |
| Debug prod critique | MEDIUM (sous-réflexion) | MAX (analyse complété) | Moins de tokens gaspilles en allers-retours |

Le gain principal n'est pas que l'économie de tokens : c'est aussi la qualité. Les tâches critiques reçoivent plus de réflexion, les tâches simples sont executees sans latence inutile.

---

## Intégration avec les autres techniques d'optimisation

| Technique | Ce qu'elle optimise | Skill |
|-----------|-------------------|-------|
| **Effort routing** (ce skill) | Profondeur de réflexion par tâche | /effort-router |
| **Model routing** | Choix du modèle par tâche | Frontmatter `model:` |
| **Token optimizer** | Nettoyage des tokens fantomes | /token-optimizer |
| **Compactage** | Compression du contexte | autoCompact |
| **Cache prompt** | Reutilisation des instructions système | Protection cache |
