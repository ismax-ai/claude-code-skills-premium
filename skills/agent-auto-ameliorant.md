---
name: agent-auto-améliorant
description: "Il produit, il critique, il corrige. Tout seul. Curation de la mémoire auto de Claude Code : analyse, promotion en règles, extraction en skills réutilisables."
---

# Agent Auto-Améliorant

> Inspire de [pskoett/self-improving-agent](https://github.com/pskoett/self-improving-agent) — adapte en français.

La mémoire auto de Claude Code capture des patterns. Ce skill ajoute l'intelligence : il analyse ce que Claude a appris, promeut les patterns prouves en règles, et extrait les solutions récurrentes en skills réutilisables.

## Commandes

| Commande | Ce que ça fait |
|----------|---------------|
| `/si:review` | Analyse MEMORY.md — trouve les candidats a promotion, les entrees obsolètes, les opportunités de consolidation |
| `/si:promote` | Fait passer un pattern de MEMORY.md → CLAUDE.md ou `.claude/rules/` |
| `/si:extract` | Transforme un pattern prouve en skill standalone |
| `/si:status` | Dashboard santé mémoire — nombre de lignes, fichiers thematiques, recommandations |
| `/si:remember` | Sauvegarde explicitement un savoir important dans la mémoire auto |

## Comment ça s'articule

```
┌──────────────────────────────────────────────────┐
│              Pile memoire Claude Code              │
├─────────────┬──────────────────┬─────────────────┤
│  CLAUDE.md  │   Memoire auto   │  Memoire session │
│  (toi)      │   (Claude)       │  (Claude)        │
│  Regles &   │   MEMORY.md      │  Logs de         │
│  standards  │   + fichiers     │  conversation    │
│  Charge     │   thematiques    │  Contextuel      │
│  complet    │   200 premieres  │                  │
│             │   lignes         │                  │
├─────────────┴──────────────────┴─────────────────┤
│          ↑ /si:promote    ↑ /si:review           │
│       Agent Auto-Ameliorant (ce skill)            │
│          ↓ /si:extract    ↓ /si:remember         │
├──────────────────────────────────────────────────┤
│  .claude/rules/   │  Nouveaux skills  │  Logs    │
│  (regles scopees) │  (extraits)       │  erreurs │
└──────────────────────────────────────────────────┘
```

## Architecture mémoire

| Fichier | Qui écrit | Charge quand |
|---------|-----------|-------------|
| `./CLAUDE.md` | Toi (+ `/si:promote`) | Chaque session, en entier |
| `MEMORY.md` | Claude (auto) | 200 premières lignes |
| `memory/*.md` | Claude (débordement) | A la demande |
| `.claude/rules/*.md` | Toi (+ `/si:promote`) | Quand les fichiers concernes sont ouverts |

## Cycle de promotion

```
1. Claude decouvre un pattern → memoire auto (MEMORY.md)
2. Le pattern revient 2-3 fois → /si:review le signale comme candidat
3. Tu approuves → /si:promote le fait monter en CLAUDE.md ou rules/
4. Le pattern devient une regle appliquee, plus juste une note
5. L'entree MEMORY.md est supprimee → libere de l'espace pour de nouveaux apprentissages
```

## Concepts clés

### La mémoire auto capture, elle ne trie pas

La mémoire auto est excellente pour enregistrer ce que Claude apprend. Mais elle ne juge pas :
- Quel apprentissage est temporaire vs permanent
- Quels patterns devraient devenir des règles
- Quand la limite de 200 lignes gaspille de l'espace sur des entrees obsolètes
- Quelles solutions meritent de devenir des skills

C'est le role de ce skill.

### Promotion = graduation

Quand tu promeus un apprentissage, il passe du brouillon de Claude (MEMORY.md) au système de règles de ton projet (CLAUDE.md ou `.claude/rules/`).

- **MEMORY.md** : "Ce projet utilise pnpm" (contexte de fond)
- **CLAUDE.md** : "Utiliser pnpm, pas npm" (instruction appliquee)

Les règles promues ont une priorité supérieure et sont chargees en entier (pas tronquées a 200 lignes).

### Le dossier rules/ pour le savoir scope

Tout ne va pas dans CLAUDE.md. Utilise `.claude/rules/` pour les patterns qui s'appliquent uniquement a certains types de fichiers :

```yaml
# Exemple : regle scopee sur les tests API
---
paths:
  - "src/api/**/*.test.ts"
  - "tests/api/**/*"
---
- Utiliser supertest pour les tests d'endpoints API
- Mocker les services externes avec msw
- Toujours tester les reponses d'erreur, pas juste le happy path
```

Ça se charge uniquement quand Claude travaille sur des fichiers de test API. Zero overhead sinon.

## Agents internes

### memory-analyst
Analyse MEMORY.md et les fichiers thematiques pour identifier :
- Entrees qui reviennent entre sessions (candidats a promotion)
- Entrees obsolètes qui referencent des fichiers supprimes
- Entrees liees qui devraient être consolidees
- Écarts entre ce que MEMORY.md sait et ce que CLAUDE.md impose

### skill-extractor
Prend un pattern prouve et généré un skill complet :
- Fichier SKILL.md avec frontmatter correct
- Documentation de référence
- Exemples et cas limites
- Pret a installer
