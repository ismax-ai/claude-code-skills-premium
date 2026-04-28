---
name: superpowers
description: "A utiliser au début de chaque conversation — définit comment trouver et utiliser les skills, impose l'invocation du Skill tool AVANT toute réponse, y compris les questions de clarification."
---

> Fork de [pcvelz/superpowers](https://github.com/pcvelz/superpowers) — traduit intégralement en français.

<SUBAGENT-STOP>
Si tu as ete lance comme sous-agent pour exécuter une tâche spécifique, ignore ce skill.
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
Si tu penses qu'il y a ne serait-ce que 1% de chance qu'un skill s'applique a ce que tu fais, tu DOIS ABSOLUMENT invoquer le skill.

SI UN SKILL S'APPLIQUE A TA Tâche, TU N'AS PAS LE CHOIX. TU DOIS L'UTILISER.

Ce n'est pas négociable. Ce n'est pas optionnel. Tu ne peux pas rationaliser pour t'en sortir.
</EXTREMELY-IMPORTANT>

## Priorité des instructions

Les skills Superpowers remplacent le comportement par défaut du system prompt, mais **les instructions de l'utilisateur ont toujours la priorité** :

1. **Instructions explicites de l'utilisateur** (CLAUDE.md, GEMINI.md, AGENTS.md, demandes directes) — priorité maximale
2. **Skills Superpowers** — remplacent le comportement système par défaut quand il y a conflit
3. **System prompt par défaut** — priorité minimale

Si CLAUDE.md, GEMINI.md ou AGENTS.md dit "pas de TDD" et qu'un skill dit "toujours utiliser TDD", suis les instructions de l'utilisateur. C'est l'utilisateur qui décidé.

## Comment acceder aux skills

**Dans Claude Code :** Utilise l'outil `Skill`. Quand tu invoques un skill, son contenu est charge et présenté — suis-le directement. N'utilise jamais l'outil Read sur les fichiers de skills.

**Dans Copilot CLI :** Utilise l'outil `skill`. Les skills sont auto-decouverts depuis les plugins installes. L'outil `skill` fonctionne comme l'outil `Skill` de Claude Code.

**Dans Gemini CLI :** Les skills s'activent via l'outil `activate_skill`. Gemini charge les métadonnées des skills au démarrage de session et active le contenu complet a la demande.

**Dans d'autres environnements :** Consulte la documentation de ta plateforme pour savoir comment les skills sont charges.

## Adaptation par plateforme

Les skills utilisent les noms d'outils de Claude Code. Plateformes non-CC : voir `references/copilot-tools.md` (Copilot CLI), `references/codex-tools.md` (Codex) pour les équivalences d'outils. Les utilisateurs Gemini CLI reçoivent le mapping d'outils automatiquement via GEMINI.md.

# Utiliser les skills

## La règle

**Invoquer les skills pertinents ou demandes AVANT toute réponse ou action.** Même 1% de chance qu'un skill s'applique = l'invoquer pour vérifier. Si le skill invoque ne colle pas a la situation, pas besoin de l'utiliser.

```dot
digraph skill_flow {
    "Message utilisateur recu" [shape=doublecircle];
    "Sur le point d'entrer en PlanMode ? NON" [shape=doublecircle];
    "Brainstorming deja fait ?" [shape=diamond];
    "Invoquer le skill de brainstorming" [shape=box];
    "Un skill pourrait s'appliquer ?" [shape=diamond];
    "Invoquer l'outil Skill" [shape=box];
    "Annoncer : 'J utilise [skill] pour [objectif]'" [shape=box];
    "A une checklist ?" [shape=diamond];
    "TaskCreate pour chaque element de la checklist" [shape=box];
    "Suivre le skill a la lettre" [shape=box];
    "Repondre (y compris clarifications)" [shape=doublecircle];

    "Sur le point d'entrer en PlanMode ? NON" -> "Brainstorming deja fait ?";
    "Brainstorming deja fait ?" -> "Invoquer le skill de brainstorming" [label="non"];
    "Brainstorming deja fait ?" -> "Un skill pourrait s'appliquer ?" [label="oui"];
    "Invoquer le skill de brainstorming" -> "Un skill pourrait s'appliquer ?";

    "Message utilisateur recu" -> "Un skill pourrait s'appliquer ?";
    "Un skill pourrait s'appliquer ?" -> "Invoquer l'outil Skill" [label="oui, meme 1%"];
    "Un skill pourrait s'appliquer ?" -> "Repondre (y compris clarifications)" [label="clairement non"];
    "Invoquer l'outil Skill" -> "Annoncer : 'J utilise [skill] pour [objectif]'";
    "Annoncer : 'J utilise [skill] pour [objectif]'" -> "A une checklist ?";
    "A une checklist ?" -> "TaskCreate pour chaque element de la checklist" [label="oui"];
    "A une checklist ?" -> "Suivre le skill a la lettre" [label="non"];
    "TaskCreate pour chaque element de la checklist" -> "Suivre le skill a la lettre";
}
```

## Red flags

Ces pensees signifient STOP — tu es en train de rationaliser :

| Pensee | Réalité |
|--------|---------|
| "C'est juste une question simple" | Les questions sont des tâches. Vérifier les skills. |
| "J'ai besoin de plus de contexte d'abord" | Le check des skills vient AVANT les questions de clarification. |
| "Laisse-moi explorer la codebase d'abord" | Les skills te disent COMMENT explorer. Vérifier d'abord. |
| "Je peux checker git/les fichiers rapidement" | Les fichiers n'ont pas le contexte de la conversation. Vérifier les skills. |
| "Laisse-moi d'abord rassembler des infos" | Les skills te disent COMMENT rassembler les infos. |
| "Pas besoin d'un skill formel pour ça" | Si un skill existe, l'utiliser. |
| "Je me souviens de ce skill" | Les skills evoluent. Lire la version actuelle. |
| "Ça ne compte pas comme une tâche" | Action = tâche. Vérifier les skills. |
| "Le skill est excessif pour ça" | Les trucs simples deviennent complexes. L'utiliser. |
| "Je vais juste faire ce truc d'abord" | Vérifier AVANT de faire quoi que ce soit. |
| "Ça a l'air productif la" | L'action sans méthode fait perdre du temps. Les skills empêchent ça. |
| "Je sais ce que ça veut dire" | Connaître le concept != utiliser le skill. L'invoquer. |

## Priorité des skills

Quand plusieurs skills pourraient s'appliquer, utiliser cet ordre :

1. **Skills de processus d'abord** (brainstorming, debugging) — ils determinent COMMENT aborder la tâche
2. **Skills d'implémentation ensuite** (frontend-design, mcp-builder) — ils guident l'exécution

"Construis X" → brainstorming d'abord, puis skills d'implémentation.
"Corrige ce bug" → debugging d'abord, puis skills spécifiques au domaine.

## Types de skills

**Rigides** (TDD, debugging) : suivre a la lettre. Ne pas adapter pour esquiver la discipline.

**Flexibles** (patterns) : adapter les principes au contexte.

Le skill lui-même te dit lequel il est.

## Instructions utilisateur

Les instructions disent QUOI, pas COMMENT. "Ajoute X" ou "Corrige Y" ne veut pas dire sauter les workflows.
