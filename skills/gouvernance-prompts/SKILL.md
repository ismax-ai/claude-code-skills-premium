---
name: gouvernance-prompts
description: "Utiliser pour gérer des prompts en production a grande échelle : versioning de prompts, A/B tests, registres de prompts, prévention des regressions, création de pipelines d'évaluation pour des features IA en production. Déclencheurs : 'gérer les prompts en production', 'versioning de prompts', 'regression de prompts', 'A/B test de prompts', 'registre de prompts', 'pipeline d'évaluation'. PAS pour écrire ou améliorer un prompt individuel (utiliser senior-prompt-engineer). PAS pour le design de pipelines RAG (utiliser rag-architect). PAS pour la réduction de coûts LLM (utiliser llm-cost-optimizer)."
---

# Gouvernance des Prompts

> Fork de [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) (contribution originale : [chad848](https://github.com/chad848), PR #448) -- traduit intégralement en français.

## Ce que ce skill résout

Les prompts en production changent le comportement de l'application. Sans gouvernance, chaque modification de prompt risque une régression de qualité non détectée. Ce skill traite les prompts comme de l'infrastructure : versionnés, testés, évalués et déployés avec la même rigueur que du code applicatif.

Les prompts c'est du code. Ils changent le comportement en production. Les déployer comme du code.

## Avant de commencer

**Vérifier le contexte d'abord :** Si un fichier project-context.md existe, le lire avant de poser des questions. Récupérer la stack IA, les patterns de déploiement, et toute approche existante de gestion des prompts.

Collecter ce contexte (poser tout en une seule fois) :

### 1. État actuel
- Comment sont stockes les prompts aujourd'hui ? (hardcodes dans le code, fichiers de config, base de donnees, outil de gestion de prompts ?)
- Combien de prompts distincts sont en production ?
- Un changement de prompt a-t-il déjà cause une regression de qualité non détectée avant que les utilisateurs ne la signalent ?

### 2. Objectifs
- Quel est le problème principal ? (chaos de versioning, pas d'evals, A/B testing a l'aveugle, iteration trop lente ?)
- Taille de l'équipe et modèle de propriété des prompts ? (un ingenieur possédé tous les prompts vs. plusieurs contributeurs ?)
- Contraintes d'outillage ? (open-source uniquement, CI/CD existant, cloud provider ?)

### 3. Stack IA
- Fournisseur(s) LLM utilise(s) ?
- Frameworks utilises ? (LangChain, LlamaIndex, custom, API directe ?)
- Infrastructure de test/CI existante ?

## Comment ce skill fonctionne

### Mode 1 : Construire un registre de prompts
Pas de gestion centralisee des prompts aujourd'hui. Concevoir et implémenter un registre de prompts avec versioning, promotion par environnement, et piste d'audit.

### Mode 2 : Construire un pipeline d'évaluation
Les prompts sont stockes quelque part mais il n'y a pas de test de qualité systématique. Construire un pipeline d'évaluation qui détecté les regressions avant la production.

### Mode 3 : Iteration gouvernee
Le registre et les evals existent. Designer le workflow de gouvernance complet : branche, test, eval, review, promotion -- avec capacité de rollback.

---

## Mode 1 : Construire un registre de prompts

**Ce que fournit un registre de prompts :**
- Source unique de vérité pour tous les prompts
- Historique des versions avec rollback
- Promotion par environnement (dev vers staging vers prod)
- Piste d'audit (qui a change quoi, quand, pourquoi)
- Gestion des variables/templates

### Registre minimum viable (base fichiers)

Pour les petites équipes : fichiers structures en contrôle de version.

Arborescence :
```
prompts/
  registry.yaml          # Index de tous les prompts
  summarizer/
    v1.0.0.md            # Contenu du prompt
    v1.1.0.md
  classifier/
    v1.0.0.md
  qa-bot/
    v2.1.0.md
```

Schema YAML du registre :
```yaml
prompts:
  - id: summarizer
    description: "Resumer les tickets support pour le triage par les agents"
    owner: platform-team
    model: claude-sonnet-4-5
    versions:
      - version: 1.1.0
        file: summarizer/v1.1.0.md
        status: production
        promoted_at: 2026-03-15
        promoted_by: eng@company.com
      - version: 1.0.0
        file: summarizer/v1.0.0.md
        status: archived
```

### Registre production (base de donnees)

Pour les équipes plus larges : registre de prompts accessible par API avec des tables clés pour les prompts et les prompt_versions, trackant le slug, le contenu, le modèle, l'environnement, le score d'eval et les métadonnées de promotion.

Pour initialiser un registre base fichiers, créer l'arborescence ci-dessus et peupler le YAML du registre avec les prompts existants, leurs versions actuelles et les métadonnées de propriété.

---

## Mode 2 : Construire un pipeline d'évaluation

**Le problème :** Les changements de prompts sont déployés au feeling. Il n'y a pas de moyen systématique de savoir si un nouveau prompt est meilleur ou pire que l'actuel.

**La solution :** Des evals automatisees qui tournent a chaque changement de prompt, similaires a des tests unitaires.

### Types d'évaluations

| Type | Ce que ça mesure | Quand l'utiliser |
|---|---|---|
| **Match exact** | L'output est egal a la chaîne attendue | Classification, extraction, output structure |
| **Vérification de contenu** | L'output contient les éléments requis | Extraction de points clés, résumés |
| **LLM-as-judge** | Un autre LLM score la qualité de 1 a 5 | Génération ouverte, ton, utilité |
| **Similarite semantique** | Similarite d'embedding avec la réponse gold | Comparaisons tolerantes aux paraphrases |
| **Validation de schema** | L'output est conforme au schema JSON | Tâches de sortie structuree |
| **Évaluation humaine** | Un humain note de 1 a 5 sur des critères | Enjeux eleves, gates de lancement |

### Design du dataset gold

Chaque prompt a besoin d'un dataset gold : un ensemble fixe de paires input/output attendu qui definissent le comportement correct.

Exigences du dataset gold :
- Minimum 20 exemples pour la couverture de base, 100+ pour la confiance en production
- Couvrir les cas limites et les modes d'échec, pas juste le happy path
- Revu et approuve par un expert du domaine, pas juste par l'ingenieur qui a écrit le prompt
- Versionne aux cotes du prompt (un changement de prompt peut nécessiter une mise a jour du dataset gold)

### Implémentation du pipeline d'évaluation

L'eval runner accepte une version de prompt et un dataset gold, appelle le LLM pour chaque exemple, évalué la réponse par rapport a l'output attendu, et retourne un résultat avec pass_rate, avg_score et détails des échecs.

Seuils de réussite (a calibrer selon le cas d'usage) :
- Classification/extraction : 95% ou plus en match exact
- Résumé : 0.85 ou plus en score LLM-as-judge
- Output structure : 100% en validation de schema
- Génération ouverte : 80% ou plus en approbation humaine

Pour exécuter les evals, construire un runner qui itere sur le dataset gold, appelle le LLM avec la version de prompt testee, score chaque réponse par rapport a l'output attendu, et rapporte le taux de réussite agrege et les détails des échecs.

---

## Mode 3 : Iteration gouvernee

Le cycle de déploiement complet avec des gates a chaque étape :

1. **BRANCHE** -- Créer une feature branch pour le changement de prompt
2. **Développé** -- Éditer le prompt en environnement dev, tests manuels
3. **Évalué** -- Lancer le pipeline d'eval vs dataset gold (automatise en CI)
4. **COMPARE** -- Comparer le score d'eval du nouveau prompt vs le score de production actuel
5. **REVIEW** -- PR review : résultats d'eval plus diff des changements de prompt
6. **PROMEUT** -- Staging vers Production avec gate d'approbation
7. **MONITORE** -- Surveiller les métriques de production pendant 24-48h post-deploy
8. **ROLLBACK** -- Retour en une commande a la version précédente si besoin

### A/B testing de prompts

Quand on veut mesurer l'impact sur de vrais utilisateurs, pas seulement les scores d'eval :

- Utiliser un assignment stable (le même utilisateur reçoit toujours la même variante, base sur le hash de user_id)
- Logger chaque assignment avec user_id, prompt_slug et variante pour l'analyse
- Définir la métrique de succès AVANT de commencer (pas après)
- Tourner pendant minimum 1 semaine ou 1 000 requêtes par variante
- Vérifier l'effet de nouveauté (pic d'engagement le premier jour)
- Significativite statistique : p<0.05 avant de déclarer un gagnant
- Monitorer la latence et le coût en parallele de la qualité

### Rollback Playbook

Rollback en une commande : promouvoir la version précédente en statut production dans le registre, puis vérifier en relancant les evals sur la version restauree.

---

## Déclencheurs proactifs

Signaler sans qu'on te le demande :

- **Prompts hardcodes dans le code applicatif** -- Les changements de prompts necessitent des deploiements de code. Ça ralentit l'iteration et melange les responsabilités. Flagger immédiatement.
- **Pas de dataset gold pour les prompts en production** -- Aucune visibilité sur la qualité. N'importe quel changement de prompt peut silencieusement dégrader la qualité.
- **Taux de réussite des evals en baisse au fil du temps** -- Les mises a jour de modèles peuvent silencieusement casser des prompts. Des evals planifiees detectent ça avant les utilisateurs.
- **Pas de capacité de rollback** -- Si un mauvais prompt atteint la production, l'équipe est bloquee jusqu'a un nouveau deploy. Toujours avoir un rollback.
- **Une seule personne détient tout le savoir sur les prompts** -- Risque de bus factor. Le registre de prompts et la documentation représentent un savoir qui survit aux changements d'équipe.
- **Changements de prompts déployés sans eval** -- Chaque deploy sans eval est un pari. Flagger quand l'équipe saute les evals "juste cette fois".

---

## Artefacts de sortie

| Ce que tu demandes... | Ce que tu obtiens... |
|---|---|
| Design du registre | Structure de fichiers, schema, workflow de promotion, et guide d'implémentation |
| Pipeline d'évaluation | Template de dataset gold, approche du runner d'eval, recommandations de seuils de réussite |
| Setup d'A/B test | Logique d'assignment des variantes, plan de mesure, métriques de succès, et template d'analyse |
| Review de diff de prompt | Comparaison cote a cote avec delta de score d'eval et recommandation de déploiement |
| Politique de gouvernance | Document de politique pour l'équipe : modèle de propriété, exigences de review, gates de déploiement |

---

## Communication

Tous les outputs suivent le standard structure :
- **Conclusion d'abord** -- le risque ou la recommandation avant l'explication
- **Quoi + Pourquoi + Comment** -- chaque constat inclut les trois
- **Les actions ont des propriétaires et des deadlines** -- pas de "l'équipe devrait envisager..."
- **Tagging de confiance** -- vérifié / moyen / suppose

---

## Anti-patterns

| Anti-pattern | Pourquoi ça échoué | Meilleure approche |
|---|---|---|
| Hardcoder les prompts dans le code source applicatif | Les changements de prompts necessitent des deploiements de code, ralentissant l'iteration et couplant les responsabilités | Stocker les prompts dans un registre versionne séparé du code applicatif |
| Déployer des changements de prompts sans lancer d'evals | Les regressions silencieuses de qualité atteignent les utilisateurs sans être détectées | Gater chaque changement de prompt sur le passage du pipeline d'eval automatise avant promotion |
| Utiliser un seul dataset gold pour toujours | A mesure que le produit évolué, le dataset gold derive des patterns d'usage reels | Revoir et mettre a jour le dataset gold trimestriellement, en ajoutant les nouveaux cas limites tires des échecs en production |
| Une seule personne détient tout le savoir sur les prompts | Bus factor de 1 -- quand cette personne part, le contexte des prompts est perdu | Documenter les prompts dans un registre avec propriété, justification et historique des versions |
| A/B test sans métrique de succès prédéfinie | La selection de métriques post-hoc introduit du biais et des résultats non concluants | Définir la métrique de succès principale et la taille d'échantillon requise avant de lancer le test |
| Sauter la capacité de rollback | Un mauvais prompt en production sans rollback force un déploiement de code en urgence | Chaque promotion de version de prompt doit avoir un rollback en une commande vers la version précédente |

## Skills associes

- **senior-prompt-engineer** : Utiliser pour écrire ou améliorer des prompts individuels. PAS pour gérer des prompts en production a grande échelle (ça c'est ce skill).
- **llm-cost-optimizer** : Utiliser pour réduire les dépenses API LLM. Se combine avec ce skill -- les evals detectent les regressions de qualité quand on route vers des modèles moins chers.
- **rag-architect** : Utiliser pour concevoir des pipelines de retrieval. Se combine avec ce skill pour gouverner séparément les prompts système RAG et les prompts de retrieval.
- **ci-cd-pipeline-builder** : Utiliser pour construire des pipelines CI/CD. Se combine avec ce skill pour automatiser les runs d'eval en CI.
- **observability-designer** : Utiliser pour concevoir le monitoring. Se combine avec ce skill pour les dashboards de qualité des prompts en production.
