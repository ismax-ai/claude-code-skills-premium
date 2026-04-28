---
description: "Routage automatique de modèle : dirige chaque sous-tâche vers Haiku, Sonnet ou Opus selon sa nature pour réduire la consommation de 50 à 80% sur les tâches simples sans sacrifier la qualité sur les tâches critiques"
---

# /model-router — Routage de Modèle

> Skill original par [Ismax](https://github.com/ismax-ai).

## Ce que ce skill résout

Claude Code utilise un seul modèle pour tout : le modèle sélectionné en début de session. Si tu travailles en Opus, chaque recherche de fichier, chaque `grep`, chaque listing de dossier passe par Opus. Le coût par token d'Opus est ~19x celui de Haiku.

En pratique, 60 à 70% des actions d'une session de développement sont de l'exploration : chercher un fichier, lister un dossier, scanner du code. Ces tâches ne demandent aucun raisonnement complexe. Les envoyer à Opus revient à payer le tarif maximum pour un travail que Haiku fait aussi bien.

Ce skill définit une règle de routage que Claude lit et applique : chaque sous-tâche est dirigée vers le modèle le moins cher capable de la traiter correctement. C'est une instruction comportementale — Claude la suit parce qu'elle est dans ses commandes, pas via un mécanisme d'enforcement externe.

## Comment fonctionne le model routing dans Claude Code

Claude Code propose trois mécanismes pour changer de modèle :

### 1. Commande `/model`

Change le modèle principal en cours de session. L'utilisateur tape `/model`, sélectionne un modèle, et tous les messages suivants utilisent ce modèle. Pas besoin de relancer la session.

### 2. Paramètre `model` dans l'Agent tool

Quand Claude lance un sous-agent (Agent tool), il peut spécifier le modèle via le paramètre `model`. Valeurs possibles : `"haiku"`, `"sonnet"`, `"opus"`. Ce paramètre est un enum — seules ces trois valeurs sont acceptées.

```json
{
  "name": "Agent",
  "parameters": {
    "prompt": "Cherche tous les fichiers .ts dans src/",
    "model": "haiku"
  }
}
```

Ce mécanisme permet de router chaque sous-tâche individuellement sans changer le modèle de la conversation principale.

### 3. Variable d'environnement `CLAUDE_CODE_SUBAGENT_MODEL`

Force TOUS les sous-agents vers un modèle unique. Utile comme filet de sécurité, mais trop rigide pour un routing intelligent — une tâche d'exploration et une review de sécurité ne demandent pas le même modèle.

Ce skill utilise le mécanisme #2 : routage individuel par sous-tâche via le paramètre `model` de l'Agent tool.

## Coût par token selon le modèle

| Modèle | Input (MTok) | Output (MTok) | Ratio vs Haiku |
|--------|-------------|--------------|----------------|
| **Haiku** | $0.80 | $4.00 | 1x |
| **Sonnet** | $3.00 | $15.00 | ~3.7x |
| **Opus** | $15.00 | $75.00 | ~18.7x |

Source : documentation Anthropic, tarifs API Claude (mai 2025).

Un `grep` dans un codebase consomme le même nombre de tokens quel que soit le modèle. La seule différence est le prix unitaire.

## Table de routage

| Type de tâche | Modèle | Exemples concrets |
|---|---|---|
| Exploration de fichiers | **Haiku** | grep, glob, lecture de fichiers, scan de codebase, listing de dossiers |
| Collecte de données | **Haiku** | Compter des lignes, lister des commandes, inventaires, audits simples |
| Analyse de code, synthèse | **Sonnet** | Debug, écriture de scripts, refactoring, analyse de dépendances |
| Modification de code | **Sonnet** | Écrire une feature, corriger un bug, ajouter des tests |
| Contenu textuel, rédaction | **Sonnet** | Documentation, messages, descriptions |
| Décisions d'architecture | **Opus** | Choix de design, patterns, structures de données critiques |
| Jugement critique, review | **Opus** | Review de sécurité, audit de code, quality gates |
| Raisonnement complexe | **Opus** | Debug multi-fichiers non reproductible, optimisation système |

## Arbre de décision

```
1. La tâche est une lecture, recherche, ou listing ?
   (grep, glob, find, read, ls, count, scan, inventaire)
   OUI → HAIKU
   NON ↓

2. La tâche produit ou modifie du code/contenu ?
   (écrire, corriger, refactorer, documenter, tester)
   OUI → SONNET
   NON ↓

3. La tâche demande un jugement, une décision, ou un raisonnement complexe ?
   (architecture, review sécurité, audit, debug multi-couches)
   OUI → OPUS
   NON → SONNET (défaut)
```

### Signaux de surclassement (prioritaires)

Ces signaux forcent un modèle supérieur, quel que soit le type de tâche.

| Signal détecté | Modèle minimum |
|----------------|----------------|
| "sécurité", "faille", "injection", "audit" | **Opus** |
| "architecture", "design system", "décision" | **Opus** |
| "production", "deploy", "migration" | **Sonnet** (Opus si irréversible) |
| "review", "vérifie", "quality gate" | **Opus** |
| Multi-fichiers avec effets de bord | **Sonnet** minimum |

### Signaux de déclassement

| Signal détecté | Modèle maximum |
|----------------|----------------|
| "cherche", "trouve", "liste", "montre-moi" | **Haiku** |
| "compte", "combien", "scan" | **Haiku** |
| Tâche de formatting/sorting | **Haiku** |

**Règle** : si surclassement ET déclassement dans le même message, le surclassement gagne.

## Cas limites

| Tâche | Modèle | Raison |
|-------|--------|--------|
| "Lis ce fichier et dis-moi ce qu'il fait" | **Sonnet** | La lecture = Haiku, mais "dis-moi ce qu'il fait" = analyse |
| "Cherche tous les TODO dans le projet" | **Haiku** | Recherche pure, aucun raisonnement |
| "Cherche les failles de sécurité dans ce fichier" | **Opus** | "Sécurité" surclasse le mot "cherche" |
| "Écris un test unitaire simple" | **Sonnet** | Écriture de code, même simple |
| "Compare ces deux architectures et recommande" | **Opus** | Jugement + décision |
| "Reformate ce JSON" | **Haiku** | Action mécanique |

## Correction de route

Le classement automatique n'est pas parfait. L'utilisateur peut corriger.

### Monter (modèle trop faible)

| L'utilisateur dit | Action |
|-------------------|--------|
| "la réponse est trop superficielle" | Remonter vers Sonnet ou Opus |
| "t'as pas vu le problème" | Remonter vers Opus |
| "analyse plus en profondeur" | Remonter d'un cran |
| "utilise Opus pour ça" | Override → Opus |

### Descendre (modèle trop cher)

| L'utilisateur dit | Action |
|-------------------|--------|
| "pas besoin d'Opus pour ça" | Descendre vers Sonnet ou Haiku |
| "c'est juste un listing" | Override → Haiku |
| "trop lent" | Descendre d'un cran (Haiku = le plus rapide) |

Après une correction, ajuster le calibrage pour les tâches similaires dans le reste de la session.

## Affichage

Une ligne en début de réponse quand un sous-agent est lancé :

```
[🔹 HAIKU] Scan des fichiers .ts dans src/...
```

```
[🔸 SONNET] Refactoring du module auth...
```

```
[🔶 OPUS] Review de sécurité du middleware...
```

Si la conversation principale (pas un sous-agent), ne rien afficher — le modèle principal est celui choisi par l'utilisateur.

L'utilisateur peut aussi forcer un modèle directement : "Fais ça en Haiku", "Utilise Opus", ou `/model` pour changer le modèle principal. Son override a toujours priorité sur le routage automatique.

## Diagnostic de session

Si l'utilisateur tape `/model-router` sans tâche :

```
🔀 MODEL ROUTER — Diagnostic
═══════════════════════════════════════

Sous-tâches routées : [N]
Distribution :
  🔹 HAIKU  : [X] ([%]%)
  🔸 SONNET : [X] ([%]%)
  🔶 OPUS   : [X] ([%]%)

Corrections utilisateur : [N]
  ↑ Montées : [X]
  ↓ Descentes : [X]

Économie estimée vs tout-Opus : [X]%
═══════════════════════════════════════
```

## Ce que ce skill ne fait pas

- **Ne change pas le niveau d'effort.** Effort = combien de réflexion. Modèle = quel cerveau. Pour l'effort routing, voir `/effort-router`.
- **Ne modifie pas le modèle principal de la session.** Il route les sous-agents. Le modèle de conversation reste celui choisi par l'utilisateur via `/model`.
- **Ne compresse pas le contexte.** C'est le job du compactage et des exclusions `.claudeignore`.

## Gains estimés

| Situation | Sans routing | Avec routing | Économie |
|-----------|-------------|-------------|----------|
| 10 recherches de fichiers (grep/glob) | 10x Opus ($0.15+) | 10x Haiku ($0.008) | ~95% sur ces tâches |
| Session mixte (60% exploration, 30% code, 10% architecture) | Tout en Opus | Haiku/Sonnet/Opus adaptés | ~60-70% |
| Session de debug (50% lecture, 50% analyse) | Tout en Sonnet | Haiku/Sonnet adaptés | ~40% |

Ces estimations sont basées sur les ratios de prix API, pas sur des mesures en conditions réelles. Le gain réel dépend de la distribution des tâches dans ta session. Le principe reste valide : les tâches d'exploration (majoritaires dans une session type) passent d'Opus/Sonnet à Haiku, ce qui divise le coût unitaire par 4 à 19x sur ces tâches.

Sur Claude Max (abonnement fixe), le routing reste utile : Haiku est plus rapide qu'Opus, et chaque token consommé remplit le contexte. Moins de tokens par tâche = sessions plus longues avant compaction.

## Interaction avec effort-router

Les deux skills sont complémentaires et indépendants :

| Dimension | Effort Router | Model Router |
|-----------|--------------|--------------|
| Ce qu'il contrôle | Profondeur de réflexion (LOW→MAX) | Choix du modèle (Haiku→Opus) |
| Mécanisme Claude | Extended thinking budget | Agent tool `model` parameter |
| Cible | Toutes les réponses | Sous-agents uniquement |
| Gain principal | Tokens de réflexion (-40 à -80%) | Coût par token (-50 à -95%) |

Combinés : effort-router réduit la quantité de réflexion, model-router réduit le coût unitaire de chaque token. Les économies se multiplient.

## Installation

Demande à Claude :

> « Installe le skill model-router depuis le repo GitHub ismax-ai/claude-code-skills-fr. Lis le fichier skills/model-router.md et installe-le comme commande Claude Code. »

Ou manuellement : copie le contenu de ce fichier dans `.claude/commands/model-router.md` dans ton projet.
