---
name: eli5
description: "Passe pédagogique sur le contenu long : détecte chaque terme technique utilisé sans explication et injecte une définition courte (1 phrase, compréhensible par un débutant) à sa première apparition. S'applique après rédaction, avant publication."
---

# ELI5 — Passe Pédagogique

> Skill original par [Ismax](https://github.com/ismax-ai).

## Ce que ce skill résout

Les contenus techniques utilisent des termes anglais adoptés mondialement (happy path, scope, feature flag, etc.). Ces termes sont corrects et légitimes. Mais un lecteur qui découvre le sujet décroche au premier terme non expliqué. Ce skill scanne le contenu et s'assure que chaque terme technique est défini à sa première apparition.

## Quand l'utiliser

- Après rédaction d'un contenu long (skill, article, newsletter, documentation)
- Avant publication ou partage
- Sur tout contenu destiné à une audience qui n'est pas 100% technique
- En combinaison avec d'autres skills (après rédaction, avant `/eagle-supervisor`)

## Comment il fonctionne

### Passe 1 — Détection

Scanner le contenu de haut en bas. Pour chaque terme, classifier :

| Catégorie | Action | Exemples |
|---|---|---|
| **Langage quotidien** | Rien à faire | email, bug, clic, smartphone, Wi-Fi |
| **Terme technique, déjà expliqué** | Rien à faire | "pre-mortem (exercice où l'on imagine que le projet a échoué)" |
| **Terme technique anglais, pas expliqué** | Signaler | happy path, scope, steel-man, feature flag |
| **Terme technique français, pas expliqué** | Signaler | amortissement, taux marginal, idempotent |
| **Acronyme, pas développé** | Signaler | CI/CD, ADR, JTBD |
| **Terme hybride, pas expliqué** | Signaler | pré-commit hook, auto-scaling, cross-post |

**Critère "langage quotidien"** : un terme est courant s'il est utilisé dans la vie de tous les jours, hors contexte professionnel ou technique. "Bug" est courant. "Serveur" ne l'est pas pour tout le monde. En cas de doute, expliquer.

Un terme est "expliqué" si dans les 2 phrases qui suivent sa première apparition, le lecteur peut comprendre ce que c'est sans connaissance préalable.

### Passe 2 — Injection

Pour chaque terme signalé, injecter une explication courte à sa première apparition. Trois formats possibles selon le contexte :

**Format parenthèse** (pour les termes dans un paragraphe) :
```
Le happy path (le scénario où tout se passe sans erreur) ne suffit pas.
```

**Format tiret** (pour les termes dans une liste ou un titre) :
```
- **Scope** -- le périmètre de ce qui est inclus dans le projet
```

**Format note** (pour les termes qui demandent plus de contexte) :
```
> **Steel-man** : reformuler l'argument adverse sous sa forme la plus forte
> avant de le critiquer. L'inverse de l'homme de paille.
```

### Passe 3 — Vérification

Relire le contenu modifié et vérifier :
- Chaque explication fait 1 phrase maximum (2 si le concept est complexe)
- L'explication est compréhensible par quelqu'un qui n'a jamais codé
- Le terme n'est expliqué qu'une seule fois (à sa première apparition)
- Les explications ne cassent pas le rythme de lecture

## Règles

1. **Expliquer une seule fois.** Première apparition uniquement. Les suivantes restent telles quelles.

2. **2 phrases maximum.** 1 phrase dans la majorité des cas. 2 si le concept a besoin d'un contraste pour être compris (ex: "L'inverse de X"). Au-delà, le terme est trop complexe pour une parenthèse — il lui faut une section dédiée.

3. **La définition ne contient aucun terme non expliqué.** Test concret : la définition injectée utilise uniquement des mots du vocabulaire quotidien. Si la définition elle-même contient du jargon, la reformuler.

4. **Ne pas expliquer le langage quotidien.** Ce qui est utilisé dans la vie courante hors contexte pro (email, bug, clic, smartphone) ne nécessite pas d'explication. Tout le reste : expliquer.

5. **Ne pas traduire de force.** Si le terme anglais est le standard (API, commit, sprint), le garder et l'expliquer. Ne pas inventer un équivalent français artificiel.

6. **En cas de doute, expliquer.** Mieux vaut une définition inutile pour 20% des lecteurs qu'un terme opaque pour 50%. Le défaut est toujours d'expliquer.

7. **Les acronymes sont toujours développés.** CI/CD → CI/CD (intégration continue / déploiement continu). Pas d'exception.

## Format de sortie

```
ELI5 — PASSE PÉDAGOGIQUE
═══════════════════════════════════════

Termes détectés sans explication : [N]

  1. [terme] — dans "[citation du passage]"
     → suggestion : "[terme] ([explication courte])"

  2. [terme] — acronyme dans "[citation du passage]"
     → suggestion : "[TERME] ([développement])"

  ...

Termes déjà expliqués : [N] ✅
Termes français courants ignorés : [N]

═══════════════════════════════════════
VERDICT : [CLAIR | À COMPLÉTER]
  [liste des corrections à appliquer si À COMPLÉTER]
```

## Intégration dans le pipeline

Position dans le workflow de publication :

1. Rédaction
2. Vérification langue / accents
3. **ELI5** (passe pédagogique)
4. `/eagle-supervisor` (supervision globale)
5. Publication

## Ce que ce skill ne fait PAS

- Il ne réécrit pas le contenu. Il ajoute des définitions courtes.
- Il ne traduit pas les termes anglais en français. Il les explique.
- Il ne simplifie pas le niveau technique du contenu. Le fond reste le même, les termes deviennent accessibles.
