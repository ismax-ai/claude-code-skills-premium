---
name: devils-advocate
description: "Questionne tes plans, ton code, tes designs et tes décisions avant de t'engager. Se combine avec n'importe quel autre skill comme couche de revue. Utilise l'analyse pré-mortem, la pensée par inversion et le questionnement socratique pour trouver ce que l'IA a raté : angles morts, hypothèses cachées, modes de défaillance et raccourcis optimistes."
---

# L'Avocat du Diable

> Fork de [notmanas/claude-code-skills](https://github.com/notmanas/claude-code-skills) -- traduit intégralement en français, fichiers de référence inclus.

## Ce que ce skill résout

Les modèles IA génèrent du code et des plans avec un biais d'optimisme : ils construisent exactement ce qu'on demande sans vérifier si ça tiendra en conditions réelles. Ce skill applique des cadres d'analyse structurés (pré-mortem, inversion, questionnement socratique) pour identifier les angles morts, hypothèses cachées et modes de défaillance avant que le code arrive en production.

## Comment tu fonctionnes

### Invocation standalone (`/devils-advocate`)

Demande a l'utilisateur ce qu'il veut challenger :

> Qu'est-ce que je dois challenger ?
> 1. Un truc que Claude vient de construire ou proposer (je lis le dernier output)
> 2. Un fichier, un plan ou une décision spécifique (montre-moi)
> 3. Une approche que tu t'appretes a prendre (decris-la)

### En combinaison avec un autre skill

Si l'utilisateur dit "lance /devils-advocate après" ou "passe l'avocat du diable dessus", tu t'actives après le skill principal. Tu relis ce qu'il a produit (l'audit, la spec, le plan, le code) et tu le challenges.

### Le processus

**Étape 1 : Steel-Man (toujours en premier)**

Avant de challenger quoi que ce soit, articule POURQUOI l'approche actuelle est raisonnable. Quel problème elle résout. Dans quelles contraintes elle travaille. Ça evite le bruit. Si tu n'arrives même pas a expliquer pourquoi l'approche tient, ton challenge est probablement a cote de la plaque.

Présenté ça en bref : "Ce que ça fait bien : [2-3 phrases]"

**Étape 2 : Challenge (le coeur)**

Applique les frameworks de questionnement de la section [Référence : Frameworks de questionnement](#référence--frameworks-de-questionnement) :

1. **Pre-mortem** : "C'est en prod. 3 mois plus tard, ça a cause un problème serieux. Qu'est-ce qui a merde ?"
2. **Inversion** : "Qu'est-ce qui garantirait que ça échoué ? Est-ce qu'une de ces conditions est présenté ?"
3. **Questionnement socratique** : Challenge les hypothèses et implications. "Tu assumes X. Et si X n'etait pas vrai ?"

Cross-référence avec les catégories d'angles morts de la section [Référence : Angles morts](#référence--angles-morts) :
- Sécurité, scalabilite, cycle de vie des donnees, points d'intégration, modes de defaillance
- Concurrence, écarts d'environnement, observabilite, déploiement, cas limites

Pour les outputs générés par IA spécifiquement, consulte la section [Référence : Angles morts IA](#référence--angles-morts-ia) :
- Biais du happy path, acceptation du scope, confiance sans exactitude
- Attraction des patterns, patchs réactifs, reecriture de tests

**Étape 3 : Verdict (toujours terminer avec)**

Chaque review se termine par un verdict clair :

- **Livrable** -- "C'est solide. J'ai essayé de le casser et j'ai pas réussi. Notes mineures en dessous mais rien de bloquant."
- **Livrable avec corrections** -- "Bonne approche, mais ces 2-3 trucs doivent être corrigés avant que ce soit sûr. Voilà quoi et pourquoi."
- **À repenser** -- "L'approche a un problème fondamental. Voilà ce que je reconsidérerais et pourquoi."

## Format de sortie

Pour chaque objection soulevee :

```
Objection : [resume en une ligne]
Severite : Critique | Haute | Moyenne
Framework : [quel framework a fait remonter ca]

Ce que je vois :
  [description du probleme specifique -- reference fichiers, lignes, decisions]

Pourquoi c'est important :
  [la consequence si ca sort tel quel]

Quoi faire :
  [recommandation specifique et actionnable]
```

## Règles

- **Maximum 7 objections par review.** Classees par sévérité. Si t'en as trouve 15, fais remonter les 7 du haut. Qualité plutôt que quantité.
- **Chaque objection doit être actionnable.** Pas de critique gratuite. Si tu ne peux pas dire quoi faire, ne souleve pas le point.
- **La sévérité doit être honnête.** Critique = perte de donnees, faille sécurité, ou panne prod. Haute = impact utilisateur significatif ou dette technique. Moyenne = a corriger mais pas bloquant. Pas d'inflation.
- **Steel-man avant de challenger.** Si tu sautes cette étape, tes challenges seront bruyants et penibles.
- **Le test "et alors ?"** Pour chaque objection, demande-toi : "S'ils ignorent ça, qu'est-ce qui se passe concretement ?" Si la réponse est "pas grand-chose", laisse tomber.
- **Intensité adaptee au contexte.** Un prototype reçoit une revue plus légère qu'un système financier en production. Demande le contexte si c'est pas clair.
- **Distinguer bloquant vs non-bloquant.** Marque clairement quelles objections doivent être traitees avant de livrer et lesquelles sont du "surveille ça".

## Ce que tu challenges

- Plans et roadmaps ("Est-ce le bon truc a construire ?")
- Décisions d'architecture ("Ça tiendra a l'échelle ? Et les modes de defaillance ?")
- Code et implémentations ("Quels cas limites manquent ? Qu'est-ce qui casse sous charge ?")
- Designs UX et specs ("L'audit a-t-il rate quelque chose ? Et le vrai workflow utilisateur ?")
- Designs d'API ("Que se passe-t-il quand ce contrat doit changer ?")
- Tout output de n'importe quel autre skill Claude Code

## Ce que tu ne fais PAS

- Réécrire du code. Le skill questionne et recommandé. L'implémentation est séparée.
- Questionner pour le plaisir de questionner. Si c'est solide, le dire. "Livrable" est un verdict valide.
- Répéter ce qui a déjà été couvert. Si le skill principal a signalé un problème, ne pas le re-signaler.

## Fichiers de référence

Les 3 références ci-dessous sont intégrées dans ce fichier. Consulte-les selon le besoin :

- **[Référence : Frameworks de questionnement](#référence--frameworks-de-questionnement)** -- Pre-mortem, inversion, questionnement socratique, steel-manning, Six Thinking Hats, Five Whys. Pour les approches structurees de challenge de décisions.

- **[Référence : Angles morts](#référence--angles-morts)** -- 11 catégories de choses que les ingenieurs ratent systématiquement : sécurité, scalabilite, cycle de vie des donnees, modes de defaillance, concurrence, etc. Pour les reviews de code ou d'architecture.

- **[Référence : Angles morts IA](#référence--angles-morts-ia)** -- Ou l'IA tombe spécifiquement a cote : biais du happy path, acceptation du scope, confiance sans exactitude, attraction des patterns. Pour la review de tout output généré par IA.

## Style de communication

- Direct. Pas de couverture. "Ça va casser quand..." pas "Ça pourrait potentiellement poser des problèmes si..."
- Mets en avant ce qui compte le plus. Ne cache pas l'objection critique derrière trois objections moyennes.
- Cite le framework qui a fait remonter l'objection. Ça apprend a l'utilisateur a raisonner comme ça lui-même.
- Quand un truc est genuinement bon, dis-le sans réservé. Ne fabrique pas des objections pour paraître rigoureux.
- Utilise le vocabulaire de l'utilisateur. S'il appelle ça "le flow d'auth", tu appelles ça "le flow d'auth".

---

## Référence : Frameworks de questionnement

Materiel de référence pour l'analyse critique structuree des décisions logicielles, du code, des plans et de l'architecture.

---

### 1. Analyse pre-mortem (Gary Klein)

#### Ce que c'est

Un pre-mortem suppose que le projet/la décision a déjà échoué et travaille en remontant pour identifier les causes. Contrairement a un post-mortem (qui arrive après l'échec), un pre-mortem exploite la retrospective prospective -- le constat psychologique que les gens sont 30% meilleurs pour identifier les raisons d'un résultat quand ils imaginent qu'il s'est déjà produit.

#### Quand l'utiliser

- Avant de livrer une feature, une migration, ou un changement d'architecture
- Avant de s'engager dans une direction technique difficile a inverser
- Quand on review un plan qui "semble correct" mais n'a pas ete stress-teste
- Avant tout déploiement avec migration de donnees ou changement de schema

#### Processus étape par étape

1. **Cadrer l'échec.** Dire : "On est 6 mois plus tard. Ce [feature/migration/décision] a ete livre et a cause un incident serieux. L'équipe est en salle de crise."
2. **Générer des scénarios d'échec indépendamment.** Chaque participant (ou chaque passe d'analyse) écrit des scénarios d'échec spécifiques -- pas des risques vagues, mais des recits : "La migration a tourne pendant 47 minutes, a dépassé la fenêtre de maintenance, et a laisse la base dans un état inconsistant parce que..."
3. **Identifier les échecs les plus plausibles.** Classer par probabilité x impact. Se concentrer sur les échecs a la fois plausibles et embarrassants a posteriori ("on aurait du voir ça venir").
4. **Tracer chaque échec jusqu'a sa cause racine dans le plan actuel.** Quelle hypothèse, quel test manquant, ou quel cas non géré aurait cause ça ?
5. **Déterminer les actions preventives.** Pour chaque échec plausible : qu'est-ce qu'on ajouterait, changerait ou testerait pour le prévenir ?

#### Exemples de questions pour le contexte logiciel

| Scénario | Question pre-mortem |
|----------|-------------------|
| Nouvel endpoint API | "Cet endpoint a cause une panne prod. Le pager de l'ingenieur d'astreinte a sonne a 3h du mat. Qu'est-ce qui s'est passe ?" |
| Migration de base | "La migration a échoué a mi-chemin en production. Qu'est-ce qui etait différent en prod qu'on n'a pas pris en compte ?" |
| Lancement de feature | "Les utilisateurs sont furieux. Les tickets support ont triple. Qu'est-ce qu'on s'est plante sur leur utilisation reelle ?" |
| Upgrade de dépendance | "L'upgrade a casse la prod silencieusement -- pas d'erreurs, juste un comportement incorrect. Qu'est-ce qui a change que nos tests ne couvraient pas ?" |
| Optimisation de performance | "L'optimisation a empire les choses sous charge reelle. Qu'est-ce qu'on a rate sur les patterns de trafic en production ?" |

#### Point clé

La puissance du pre-mortem est qu'il donne la permission d'exprimer des inquietudes qu'on aurait autrement supprimees. En code review, ça se traduit par : "Je ne dis pas que c'est faux, je dis que SI ça echouait, voila comment ça echouerait."

---

### 2. Inversion (Charlie Munger)

#### Ce que c'est

Au lieu de demander "comment réussir ?", demander "qu'est-ce qui garantirait l'échec ?" puis vérifier qu'aucune de ces conditions n'existe. Principe de Munger : "Inversez, inversez toujours." Beaucoup de problèmes sont plus faciles a résoudre a l'envers qu'a l'endroit.

#### Quand l'utiliser

- Pour évaluer si un design est robuste
- Pour revoir les critères d'acceptation -- sont-ils suffisants ?
- Pour évaluer la readiness operationnelle
- Quand un plan semble solide mais qu'on n'arrive pas a articuler des préoccupations spécifiques

#### Processus en 3 étapes

1. **Définir l'objectif inverse.** Si l'objectif est "pipeline de traitement de donnees fiable", l'inverse est "perte ou corruption de donnees garantie".
2. **Énumérer les moyens d'atteindre l'inverse.** Être exhaustif et spécifique :
   - "Ne jamais valider les schemas d'entree"
   - "Ignorer les échecs partiels et continuer le traitement"
   - "Pas de clés d'idempotence sur les ecritures"
   - "Déployer sans capacité de rollback"
   - "Pas de monitoring sur la profondeur de queue ou le lag de traitement"
3. **Vérifier le plan actuel contre chaque élément.** Pour chaque condition garantissant l'échec, vérifier que le plan la prévient activement. Toute lacune est un finding.

#### Exemples d'application

**Inversion appliquee a un système d'authentification :**

| "Pour garantir une faille sécurité, on ferait..." | Vérification |
|-----------------------------------------------|-------|
| Stocker les mots de passe en clair | Bcrypt/argon2 avec salt ? |
| Ne jamais expirer les sessions | TTL du token + rotation du refresh ? |
| Retourner des erreurs différentes pour "utilisateur non trouve" vs "mauvais mot de passe" | Messages d'erreur uniformes ? |
| Permettre des tentatives de login illimitees | Rate limiting + verrouillage ? |
| Envoyer les tokens dans les paramètres d'URL | Headers uniquement, pas de logging ? |
| Faire confiance aux claims de role cote client | Autorisation cote serveur a chaque requête ? |

**Inversion appliquee au déploiement :**

| "Pour garantir un déploiement rate, on ferait..." | Vérification |
|--------------------------------------------------|-------|
| Déployer le vendredi a 17h sans plan de rollback | Fenêtres de déploiement + runbook de rollback ? |
| Lancer des migrations irréversibles | Migrations backward-compatible ? |
| Sauter le canary/déploiement progressif | Déploiement progressif ? |
| N'avoir aucun moyen de vérifier le succès post-deploy | Health checks + smoke tests ? |
| Dependre d'étapes manuelles non documentees | Pipeline automatise ? |

#### Exemples de questions

- "Si on voulait garantir la corruption de donnees dans ce pipeline, qu'est-ce qu'on ferait ? Maintenant -- est-ce qu'une de ces conditions est présenté ?"
- "Quel est le moyen le plus rapide pour un insider malveillant d'exploiter ça ? Est-ce qu'on le prévient ?"
- "Si on voulait que les utilisateurs abandonnent cette feature par frustration, a quoi ressemblerait l'UX ? La notre ressemble a ça ?"
- "Qu'est-ce qui rendrait ce système impossible a debugger en production ?"

---

### 3. Questionnement socratique (six types)

#### Ce que c'est

Le questionnement socratique est une méthode disciplinee pour sonder la pensee a travers six catégories de questions. Il n'affirme pas -- il révélé les lacunes, les hypothèses et les contradictions en posant les bonnes questions dans le bon ordre.

#### Quand l'utiliser

- Pendant une code review ou design review
- Quand on évalué une proposition technique
- Quand quelqu'un (y compris toi-même) est confiant dans une approche
- Pour faire remonter les hypothèses implicites

#### Les six types

##### 3.1 Questions de clarification

**Objectif :** S'assurer que le claim ou la décision est bien défini(e). Les declarations vagues cachent de la complexité.

| Question | Quand l'utiliser |
|----------|-------------|
| "Qu'est-ce que tu veux dire exactement par [terme] ?" | Quand du jargon ou des termes ambigus sont utilises ("scalable", "robuste", "simple") |
| "Tu peux donner un exemple concret de comment ça marcherait ?" | Quand la description est abstraite |
| "Quelle est l'action utilisateur spécifique qui déclenché ce code path ?" | Quand on review de la logique metier |
| "C'est quoi 'fini' pour ça ? C'est quoi le test d'acceptation ?" | Quand le scope est flou |
| "Quand tu dis 'gérer les erreurs proprement', qu'est-ce que l'utilisateur voit ?" | Quand la gestion d'erreur est decrite mais pas spécifiée |

##### 3.2 Sonder les hypothèses

**Objectif :** Faire remonter et tester les croyances tenues pour acquises. La plupart des defauts de design viennent d'hypothèses non testees.

| Question | Quand l'utiliser |
|----------|-------------|
| "Qu'est-ce qu'on assume sur les donnees d'entree qui pourrait ne pas tenir ?" | Traitement de donnees, endpoints API |
| "Est-ce qu'on assume que ce service tiers sera toujours disponible ?" | Points d'intégration |
| "Et si l'utilisateur ne suit pas le flow attendu ?" | Décisions UI/UX |
| "Est-ce qu'on assume que les donnees tiennent en mémoire ?" | Pipelines de traitement |
| "Et si cette table grossit de 100x ? Le plan de requête tient toujours ?" | Design de base de donnees |
| "Est-ce qu'on assume que les deplois se font avec zero requêtes en vol ?" | Plans de migration/déploiement |
| "Y a-t-il une hypothèse ici sur l'ordre ou le timing ?" | Systèmes distribues, traitement d'événements |

##### 3.3 Sonder les preuves / le raisonnement

**Objectif :** Examiner la base d'un claim. "Comment on sait que c'est vrai ?"

| Question | Quand l'utiliser |
|----------|-------------|
| "Quelles donnees supportent ce choix de design ?" | Quand un choix est présenté comme évident |
| "Ce pattern a ete teste dans des conditions proches de la prod ?" | Claims de performance |
| "D'ou vient l'exigence pour [X] ? On peut la vérifier ?" | Quand on construit sur des exigences presumees |
| "Quelles preuves montrent que les utilisateurs ont réellement besoin de ça ?" | Décisions sur les features |
| "Comment on sait que l'implémentation actuelle est vraiment le goulot d'etranglement ?" | Efforts d'optimisation |

##### 3.4 Questionner les perspectives / points de vue

**Objectif :** Considérer des angles alternatifs. Qu'est-ce que quelqu'un avec un role, un contexte, ou une expertise différente penserait ?

| Question | Quand l'utiliser |
|----------|-------------|
| "Comment l'ingenieur d'astreinte vivrait ça a 3h du mat ?" | Readiness operationnelle |
| "Qu'est-ce qu'un nouveau membre de l'équipe penserait en lisant ce code ?" | Clarté du code |
| "A quoi ça ressemble du point de vue de l'attaquant ?" | Review de sécurité |
| "Qu'est-ce que le DBA dirait de ce pattern de requêtes ?" | Utilisation de base de donnees |
| "Si on heritait de cette codebase, qu'est-ce qui nous frustrerait ?" | Qualité du code |
| "De quoi l'équipe support client aurait besoin quand ça casse ?" | Gestion d'erreur, observabilite |

##### 3.5 Sonder les implications / consequences

**Objectif :** Suivre la décision jusqu'a sa conclusion logique. Qu'est-ce qui se passe ensuite ? Et après ?

| Question | Quand l'utiliser |
|----------|-------------|
| "Si on fait ça, a quoi on s'engage a maintenir ?" | Décisions d'architecture |
| "Quel est le chemin de migration si cette approche ne scale pas ?" | Choix technologiques |
| "Si ça réussit massivement, qu'est-ce qui casse en premier ?" | Planification de capacité |
| "Qu'est-ce qui devient plus dur a changer après qu'on livre ça ?" | Évaluation de la reversibilite |
| "Quelles autres équipes ou systèmes sont impactes par ce changement ?" | Rayon d'explosion |
| "Si on ajoute cette colonne maintenant, a quoi ressemble la migration dans 2 ans ?" | Design de schema |

##### 3.6 Meta-questions (questions sur la question)

**Objectif :** Examiner le cadrage lui-même. Est-ce qu'on résout le bon problème ?

| Question | Quand l'utiliser |
|----------|-------------|
| "Pourquoi c'est cette question qu'on pose ? Y a-t-il un meilleur cadrage ?" | Quand on est bloque ou qu'on tourne en rond |
| "Est-ce qu'on résout le symptôme ou la cause racine ?" | Bug fixes, workarounds |
| "C'est vraiment notre problème a résoudre, ou ça devrait être géré ailleurs ?" | Décisions de scope/frontière |
| "Qu'est-ce qu'on ferait si on ne pouvait pas utiliser cette approche du tout ?" | Quand on est fixe sur une seule solution |
| "Est-ce qu'on optimise pour la bonne métrique ?" | Décisions performance/business |

---

### 4. Steel-Manning

#### Ce que c'est

Avant de critiquer une décision ou une approche, articuler la version la plus forte possible de pourquoi c'est raisonnable. C'est l'oppose d'un homme de paille. Tu construis le meilleur argument POUR l'approche, puis tu evalues si ta critique tient toujours.

#### Pourquoi c'est important pour la calibration

- Empêché les réactions reflexes "c'est faux" qui ratent le contexte
- Force a comprendre les compromis que l'auteur a réellement consideres
- Rend ta critique éventuelle plus credible et spécifique
- Attrape les cas ou l'approche est en fait correcte et c'est toi qui rates quelque chose

#### Quand l'utiliser

- Avant chaque critique -- ça devrait être l'étape par défaut
- Quand ton instinct dit "c'est faux" -- cet instinct est souvent juste, mais le steel-man garantit que la critique est précise
- Quand on review du code de quelqu'un avec plus de contexte metier que toi

#### Processus étape par étape

1. **Identifier la décision.** Quel choix spécifique a ete fait ? (Pas un vague "c'est mauvais" -- nommer la décision exacte.)
2. **Lister les contraintes de l'auteur.** Pression temporelle, compatibilité ascendante, expertise de l'équipe, patterns existants, exigences business.
3. **Construire le meilleur argument POUR cette approche.** "Cette approche est raisonnable parce que..."
4. **Identifier ce qui devrait être vrai pour que cette approche soit optimale.** "C'est le bon choix SI..."
5. **Maintenant évaluer :** Ces conditions sont-elles réellement vraies ? Sinon, qu'est-ce qui change spécifiquement ?

#### Exemple

**Décision :** Une équipe a choisi le polling au lieu des WebSockets pour les mises a jour en temps reel.

| Étape | Analyse |
|------|----------|
| Steel-man | "Le polling est plus simple a implémenter, debugger et déployer. Il fonctionne a travers tous les proxies et load balancers sans configuration speciale. L'équipe n'a pas d'expérience WebSocket, et la frequence de mise a jour (toutes les 30s) ne nécessité pas du vrai temps reel. Le coût operationnel de maintenir des connexions WebSocket a l'échelle n'est pas negligeable." |
| Conditions | "C'est optimal SI une latence de mise a jour de 30s est acceptable, SI la charge de polling est gerable a l'échelle prévue, SI il n'y a pas d'exigence future pour des mises a jour en dessous de la seconde." |
| Évaluation | "L'exigence business dit 'quasi temps reel' que le PM a défini comme <5s. Le polling a 30s ne remplit pas ça. De plus, au nombre d'utilisateurs projete, le polling créé 200 req/s que les WebSockets elimineraient. Le steel-man est fort sur la simplicité operationnelle mais casse sur l'exigence de latence." |

#### Exemples de questions

- "Quel est l'argument le plus fort pour garder ça exactement comme c'est ?"
- "Dans quelles conditions ça serait l'approche ideale ?"
- "Quelles contraintes ont fait de ça le choix pragmatique ?"
- "Si je devais defendre cette approche dans une design review, qu'est-ce que je dirais ?"
- "Qu'est-ce que je rate sur le contexte qui rendrait ça raisonnable ?"

---

### 5. Six Thinking Hats (Edward de Bono)

#### Ce que c'est

Une méthode pour examiner une décision depuis six perspectives distinctes, une a la fois. La valeur est dans le changement de perspective délibéré. La plupart des gens tombent par défaut dans un ou deux modes et ignorent le reste.

#### Quand l'utiliser

- Quand une décision a ete prise vite et semble "évidente"
- Quand un groupe est bloque dans un seul mode de pensee (par ex. ne discuter que des risques, ou que des bénéfices)
- Pour une review structuree d'un architectural décision record (ADR)

#### Les quatre chapeaux les plus pertinents pour la review logicielle

##### Chapeau noir -- Risques et problèmes

Le chapeau de l'avocat du diable. Qu'est-ce qui peut mal tourner ?

**Processus :** Supposer que ça va échouer. Énumérer chaque mode de defaillance, risque et faiblesse.

| Question | Focus |
|----------|-------|
| "Quel est le pire cas si ça échoué ?" | Évaluation d'impact |
| "Ou est le point unique de defaillance ?" | Résilience |
| "Que se passe-t-il quand la dépendance est down ?" | Tolérance aux pannes |
| "Quelle est la surface d'attaque sécurité ?" | Sécurité |
| "Ou est-ce que ça sera penible a maintenir dans un an ?" | Dette technique |

##### Chapeau blanc -- Donnees manquantes

Qu'est-ce qu'on sait ? Qu'est-ce qu'on ne sait pas ? Qu'est-ce qu'on doit découvrir ?

**Processus :** Enlever les opinions et les hypothèses. Se concentrer uniquement sur les faits, les donnees et les lacunes.

| Question | Focus |
|----------|-------|
| "Quelle est la latence réellement mesuree, pas celle attendue ?" | Performance reelle vs supposee |
| "Combien d'utilisateurs vont réellement toucher ce code path ?" | Donnees d'utilisation |
| "On a des donnees prod sur les taux d'erreur pour cette intégration ?" | Preuves empiriques |
| "Qu'est-ce qu'on ne sait pas sur le pattern d'utilisation du client ?" | Inconnues inconnues |
| "On a load-teste ça, ou on estime ?" | Qualité des donnees |

##### Chapeau vert -- Alternatives

Exploration creative. Quoi d'autre pourrait-on faire ?

**Processus :** Générer des options sans les juger. Quantité plutôt que qualité dans cette phase.

| Question | Focus |
|----------|-------|
| "Et si on ne construisait pas ça du tout ? C'est quoi le workaround manuel ?" | Vérification de nécessité |
| "Quelle est une architecture complètement différente qui résout ça ?" | Perspective fraiche |
| "Qu'est-ce que [entreprise connue pour ça] ferait ?" | Emprunt de patterns |
| "Et si on decoupait ça en deux problèmes plus simples ?" | Decomposition |
| "Quelle est la version la plus simple qui serait quand même utile ?" | Pensee MVP |

##### Chapeau bleu -- Meta/Processus

Penser a la pensee. Est-ce qu'on pose les bonnes questions ?

**Processus :** Prendre du recul sur le contenu. Évaluer la qualité de l'analyse elle-même.

| Question | Focus |
|----------|-------|
| "On a parle aux gens qui vont réellement utiliser/maintenir ça ?" | Couverture des stakeholders |
| "On passe du temps sur les zones a plus haut risque ?" | Priorisation |
| "Quelle décision on prend réellement la maintenant ?" | Clarté du scope |
| "On a les bonnes personnes dans cette discussion ?" | Couverture d'expertise |
| "C'est quoi nos critères de décision ? Comment on saura quelle option est meilleure ?" | Framework |

#### Comment appliquer sequentiellement

Quand on review une décision ou un plan :

1. **Bleu** (2 min) : Qu'est-ce qu'on évalué ? Qu'est-ce qui compte le plus ?
2. **Blanc** (5 min) : Qu'est-ce qu'on sait réellement ? Quelles donnees manquent ?
3. **Vert** (5 min) : Quelles alternatives existent ? (Lister sans juger.)
4. **Noir** (10 min) : Qu'est-ce qui peut mal tourner avec l'approche proposee ?
5. **Steel-man** (3 min) : Quel est l'argument le plus fort POUR cette approche ?
6. **Bleu** (2 min) : Vu tout ça, quelle est notre recommandation ?

---

### 6. Five Whys (application inversee)

#### Ce que c'est

Le classique Five Whys trace d'un problème vers sa cause racine. En application inversee pour la review de décisions, tu traces d'une décision vers sa motivation sous-jacente, pour exposer si la justification déclarée supporte réellement le choix.

#### Quand l'utiliser

- Quand on review une décision de design qui semble prise par convention
- Quand la justification est "c'est comme ça qu'on a toujours fait" ou "c'est une best practice"
- Quand un choix technique semble déconnecté du vrai problème

#### Processus étape par étape

Commencer avec la décision et demander "pourquoi cette approche ?" de manière repetee :

1. **Pourquoi cette approche ?** (Justification de surface)
2. **Pourquoi c'est important ?** (Préoccupation sous-jacente)
3. **Pourquoi c'est la contrainte ?** (Contrainte reelle vs supposee)
4. **Pourquoi cette contrainte ne peut-elle pas être changee ?** (Fixe vs deplacable)
5. **Pourquoi c'est la meilleure façon d'adresser cette préoccupation racine ?** (Alternatives)

#### Exemple : "On a choisi une architecture microservices"

| Niveau | Question | Réponse |
|-------|----------|--------|
| Why 1 | "Pourquoi les microservices ?" | "On a besoin de deploiements independants." |
| Why 2 | "Pourquoi on a besoin de deploiements independants ?" | "Différentes features ont des cadences de release différentes." |
| Why 3 | "Pourquoi les features ont des cadences différentes ?" | "L'équipe paiements livre chaque semaine, l'équipe recherche livre chaque jour." |
| Why 4 | "Pourquoi elles ne peuvent pas livrer au même rythme ?" | "Les paiements necessitent une review de conformité avant chaque release." |
| Why 5 | "Y a-t-il un moyen plus simple de gater les releases paiements sans splitter toute l'architecture ?" | "...en fait, un feature flag + une gate d'approbation sur le pipeline CI pourrait marcher." |

#### Exemple : "On utilise Redis pour le caching"

| Niveau | Question | Réponse |
|-------|----------|--------|
| Why 1 | "Pourquoi Redis ?" | "On a besoin de caching pour la performance." |
| Why 2 | "Pourquoi la performance est un problème ?" | "Le dashboard se charge lentement." |
| Why 3 | "Pourquoi le dashboard se charge lentement ?" | "Il fait 12 appels API au montage." |
| Why 4 | "Pourquoi 12 appels API ?" | "Chaque widget fetch ses donnees indépendamment." |
| Why 5 | "Un seul endpoint agrege pourrait-il éliminer le besoin de caching ?" | "...ça resoudrait la latence sans ajouter d'infra." |

#### Exemples de questions pour usage général

- "Pourquoi cette librairie/framework/outil a ete choisi plutôt que les alternatives ?"
- "Pourquoi c'est une exigence dure vs une préférence ?"
- "Pourquoi le système en amont ne peut-il pas fournir cette donnee dans le format qu'on veut ?"
- "Pourquoi c'est notre responsabilité plutôt que celle de l'appelant ?"
- "Pourquoi on a besoin de cette couche d'abstraction ?"

#### Point clé

Le Five Whys inverse révélé fréquemment qu'une solution complexe adresse un symptôme plutôt que le problème racine. Le cinquieme "pourquoi" pointe souvent vers une intervention plus simple a un autre niveau.

---

### Guide de selection de framework

| Situation | Framework principal | Framework de support |
|-----------|------------------|---------------------|
| Review d'un plan avant exécution | Pre-mortem | Inversion |
| Évaluation d'une décision technique spécifique | Five Whys (inverse) | Steel-Manning |
| Design review complété | Six Thinking Hats | Socratique (tous types) |
| "Ça semble faux mais je sais pas dire pourquoi" | Inversion | Pre-mortem |
| Challenger une proposition confiante | Steel-Manning d'abord | Puis socratique hypothèses |
| Explorer si on résout le bon problème | Socratique meta-questions | Five Whys (inverse) |
| Évaluer la readiness operationnelle | Pre-mortem | Inversion |
| Reviewer le code/PR de quelqu'un | Steel-Manning d'abord | Socratique clarification |

---

### Combiner les frameworks : sequence recommandée

Pour une review approfondie de toute décision significative :

1. **Steel-Man** -- Comprendre pourquoi cette approche est raisonnable
2. **Socratique clarification** -- S'assurer que la décision est bien définie
3. **Five Whys (inverse)** -- Tracer jusqu'a la motivation racine
4. **Inversion** -- Énumérer les conditions d'échec
5. **Pre-mortem** -- Raconter des scénarios d'échec spécifiques
6. **Socratique implications** -- Suivre les consequences vers l'avant

Cette sequence passe de la comprehension au challenge. Elle construit la crédibilité avant la critique, ce qui rend la critique plus efficace et plus susceptible de faire remonter de vrais problèmes plutôt que des préférences stylistiques.

---

## Référence : Angles morts

Catégories de problèmes que les ingenieurs ratent systématiquement pendant le design, l'implémentation et la review. Pour chaque catégorie : ce que c'est, pourquoi c'est rate, les questions clés pour le faire remonter, et des exemples concrets.

---

### 1. Sécurité

#### Pourquoi c'est rate

La sécurité est invisible quand elle fonctionne. Les ingenieurs optimisent pour la fonctionnalité -- "est-ce que ça fait le truc ?" -- et les failles de sécurité ne se manifestent que dans des conditions adverses que les tests normaux ne simulent pas. Penser sécurité demande de supposer une intention malveillante, ce qui est psychologiquement contre-nature pour les constructeurs.

#### Questions clés

| Domaine | Question |
|------|----------|
| Authentification | "Que se passe-t-il si le JWT est expire mais que la requête est déjà en vol ?" |
| Autorisation | "L'utilisateur A peut-il acceder aux ressources de l'utilisateur B en changeant l'ID dans l'URL ?" |
| Validation d'entrees | "Que se passe-t-il si ce champ contient 10 Mo de donnees ? Du SQL ? Du JavaScript ? Des caractères de contrôle Unicode ?" |
| Exposition de donnees | "Quels champs dans cette réponse API l'utilisateur demandeur ne devrait PAS voir ?" |
| Secrets | "Si cette ligne de log est capturee, est-ce qu'elle contient quelque chose de sensible ?" |
| CSRF/SSRF | "Cet endpoint peut-il être déclenché par une page malveillante que l'utilisateur visite ?" |
| Rate limiting | "Quel est le coût si quelqu'un appelle cet endpoint 10 000 fois par seconde ?" |
| Dépendance | "Quand a eu lieu le dernier audit de sécurité de cette dépendance ? A-t-elle des CVE connues ?" |

#### Ratages courants

- **Autorisation cassee au niveau objet (BOLA) :** La vulnérabilité API #1. L'endpoint vérifié l'authentification mais pas si l'utilisateur authentifie possédé la ressource demandee. Chaque endpoint qui prend un ID d'entite doit vérifier la propriété.
- **Affectation de masse :** Accepter tous les champs du corps de requête et les passer a l'update ORM. L'utilisateur envoie `{"role": "admin"}` dans une mise a jour de profil.
- **Messages d'erreur verbeux :** Stack traces, erreurs SQL, ou chemins internes dans les reponses API en production.
- **Références directes a des objets non securisees :** IDs entiers sequentiels qui permettent l'énumération. L'utilisateur itere `/api/invoices/1`, `/api/invoices/2`, etc.
- **Headers de sécurité manquants :** Pas de CSP, pas de HSTS, pas de X-Frame-Options dans les reponses.

---

### 2. Scalabilite

#### Pourquoi c'est rate

Les systèmes qui fonctionnent a l'échelle actuelle semblent corrects. Les ingenieurs testent avec de petits jeux de donnees et une faible concurrence. Le modèle mental "ça marche" se forme a l'échelle de développement et est rarement mis a jour. Les échecs de scalabilite sont non-lineaires -- une requête qui prend 50ms avec 1 000 lignes prend 30 secondes avec 1 000 000.

#### Questions clés

| Domaine | Question |
|------|----------|
| Croissance des donnees | "Que se passe-t-il pour cette requête quand la table a 10M de lignes ? 100M ?" |
| Trafic | "Si le trafic augmente de 10x, quel composant tombe en premier ?" |
| Stockage | "Combien de stockage ça consomme par utilisateur par mois ? Quelle est la projection ?" |
| Cardinalite | "Combien de valeurs distinctes cette colonne/index/clé de cache aura ?" |
| Fan-out | "Combien d'appels downstream une seule action utilisateur déclenché ?" |
| Coût | "Quel est le coût cloud de ça a 100x l'utilisation actuelle ?" |
| Hotspots | "Y a-t-il une seule ligne, clé, ou partition qui reçoit un trafic disproportionne ?" |

#### Ratages courants

- **Requêtes N+1 :** Fetcher une liste puis interroger chaque élément individuellement. Fonctionne avec 10 éléments, catastrophique avec 10 000.
- **Requêtes non bornees :** `SELECT * FROM table` sans LIMIT. Fonctionne en dev (100 lignes), OOM en production (10M lignes).
- **Pagination manquante :** Endpoints qui retournent tous les résultats. OK jusqu'a ce que le jeu de donnees grossisse.
- **Full table scans masques par les petites donnees :** Index manquant sur une colonne de filtre. Invisible jusqu'a ce que la table grossisse.
- **Cache stampede :** Le cache expire, 1 000 requêtes concurrentes ratent toutes le cache et frappent la base simultanement.
- **Algorithmes lineaires sur des donnees qui croissent :** Boucles O(n) qui deviennent O(n^2) quand imbriquees ou appliquees a des collections croissantes.

---

### 3. Cycle de vie des donnees

#### Pourquoi c'est rate

Les ingenieurs se concentrent sur la création et la lecture des donnees. Le cycle de vie complet -- création, transformation, archivage, suppression, conformité -- est rarement considéré en amont. La suppression de donnees est particulièrement négligée parce qu'elle n'a pas de valeur utilisateur immédiate.

#### Questions clés

| Domaine | Question |
|------|----------|
| Création | "Qu'est-ce qui valide ces donnees au point d'entree ? Et si les règles de validation changent ?" |
| Retention | "Combien de temps on garde ça ? Y a-t-il une exigence legale ou business ?" |
| Suppression | "Si un utilisateur demande la suppression de son compte, qu'arrive-t-il a ses donnees dans toutes les tables ?" |
| Cascade | "Si cet enregistrement est supprime, qu'est-ce qui le référence ? Les clés etrangeres cascadent ou orphelinent ?" |
| PII | "Quels champs dans cette table sont des donnees personnelles identifiables ? Peuvent-ils être pseudonymises ?" |
| Backup | "Si on restaure depuis un backup, ces donnees ont-elles des dépendances de cohérence avec d'autres systèmes ?" |
| Migration | "Si le schema change, qu'arrive-t-il aux donnees existantes ? Un backfill est-il nécessaire ?" |
| Export | "L'utilisateur peut-il exporter ses donnees ? Dans quel format ?" |

#### Ratages courants

- **Enregistrements orphelins :** Parent supprime, enfants restent avec des clés etrangeres pendantes ou pas de FK du tout.
- **Inconsistance du soft-delete :** Certaines requêtes filtrent `deleted_at IS NULL`, d'autres non. Les donnees supprimees fuient dans les résultats.
- **PII dans les logs :** Le logging structure capture les corps de requête contenant email, téléphone, adresse.
- **Pas de politique de retention de donnees :** Les tables grossissent indefiniment. Les vieilles donnees ne sont jamais archivees ou purgees.
- **Lacunes du droit a l'effacement RGPD :** Utilisateur supprime de la table `users` mais ses donnees persistent dans `audit_log`, `analytics_events`, `email_log`, les CSV exportes, et les integrations tierces.
- **Confusion des donnees temporelles :** L'état "courant" melange avec l'état historique. Pas de distinction claire entre "enregistrement actif" et "snapshot au temps T".

---

### 4. Points d'intégration

#### Pourquoi c'est rate

Les ingenieurs testent leur propre code, pas la frontière entre leur code et les systèmes externes. Les integrations marchent en dev (ou le système externe est mocke ou toujours disponible) et echouent en production (ou il est intermittent, lent, ou retourne des reponses inattendues).

#### Questions clés

| Domaine | Question |
|------|----------|
| Disponibilité | "Que se passe-t-il quand cette dépendance est down pendant 30 minutes ? 4 heures ?" |
| Latence | "Et si cet appel API prend 30 secondes au lieu de 200ms ?" |
| Forme de la réponse | "Et si la réponse inclut des champs qu'on n'attend pas ? Ou s'il manque des champs qu'on attend ?" |
| Versioning | "Que se passe-t-il si l'API tierce change sans prévenir ?" |
| Rate limits | "Cette intégration a-t-elle des rate limits ? Que se passe-t-il quand on les atteint ?" |
| Sécurité du retry | "Cette opération est-elle idempotente ? Que se passe-t-il si on retry et que la première tentative a en fait réussi ?" |
| Rayon d'explosion | "Si cette intégration échoué, quoi d'autre casse ? Peut-on dégrader proprement ?" |
| Authentification | "Quand le token API expire-t-il ? Qu'est-ce qui le rafraichit ? Et si le refresh échoué ?" |

#### Ratages courants

- **Mauvaise configuration du timeout :** Timeout HTTP par défaut de 30s ou infini. Une dépendance lente bloque les threads, cascade vers l'indisponibilite totale du système.
- **Pas de circuit breaker :** La dépendance en échec est appelee de manière repetee, consomme des ressources et ralentit tout.
- **Hypothèses sur la livraison de webhooks :** Supposer que les webhooks arrivent une fois, dans l'ordre, et rapidement. En réalité : doublons, désordre, retard de plusieurs heures.
- **Couplage de schema :** Deserialiser toute la réponse dans un type strict. Tout ajout de champ ou changement de type dans l'API externe cause des échecs.
- **Pas de fallback :** Pas de réponse en cache/par défaut quand l'intégration est indisponible. La feature devient complètement non fonctionnelle.

---

### 5. Modes de defaillance

#### Pourquoi c'est rate

Les ingenieurs pensent en termes de chemins de succès. La gestion d'erreur est ajoutee après coup -- souvent juste `catch (e) { log(e) }` -- sans considérer la taxonomie des échecs et les reponses appropriees pour chacun.

#### Questions clés

| Domaine | Question |
|------|----------|
| Échec partiel | "Et si l'étape 3 sur 5 échoué ? Dans quel état est le système ?" |
| Comportement de retry | "Si c'est retry, le résultat est-il identique ? Ou on obtient des doublons ?" |
| Propagation d'erreur | "Cette erreur remonte-t-elle clairement, ou est-elle avalee et refait surface comme un symptôme confus ailleurs ?" |
| Messages empoisonnes | "Et si un message dans la queue est malformed ? Est-ce que ça bloque tout le traitement ?" |
| Épuisement de ressources | "Que se passe-t-il quand le disque est plein ? La mémoire épuisée ? Le pool de connexions vide ?" |
| Defaillance en cascade | "Si ce composant tombe, quels autres composants tombent en consequence ?" |
| Récupération | "Après que l'échec est résolu, le système se repare-t-il seul ou nécessité-t-il une intervention manuelle ?" |

#### Ratages courants

- **État inconsistant par opérations partielles :** Processus multi-étapes (créer commande, debiter paiement, envoyer email) échoué a l'étape 2. La commande existe, le paiement n'a pas eu lieu, mais il n'y a pas de logique de compensation.
- **Tempêtes de retry :** Le service A retry les appels echoues vers le service B. Le service B echouait a cause d'une surcharge. Les retries aggravent les choses. Le backoff exponentiel avec jitter est manquant.
- **Échecs silencieux :** Exception attrapee et loggee mais pas propagee. Le système semble sain tout en produisant des résultats faux.
- **Inutilité des messages d'erreur :** `"Une erreur est survenue"` sans contexte sur ce qui a échoué, pourquoi, ou ce que l'utilisateur peut faire.
- **Negligence du deadletter :** Les messages echoues vont dans une dead letter queue que personne ne surveille. Les donnees sont perdues silencieusement.

---

### 6. Concurrence

#### Pourquoi c'est rate

Les développeurs ecrivent et testent du code sequentiellement. Les bugs de concurrence sont non-deterministes -- ils dependent du timing, de la charge et de l'ordonnancement. Une race condition qui se produit 1 fois sur 10 000 passe tous les tests et ne se manifeste qu'en production sous charge.

#### Questions clés

| Domaine | Question |
|------|----------|
| Race conditions | "Si deux utilisateurs font ça simultanement, que se passe-t-il ?" |
| Double-submit | "Si l'utilisateur clique le bouton deux fois rapidement, est-ce qu'on créé deux enregistrements ?" |
| Read-modify-write | "Entre la lecture de cette valeur et l'écriture de la mise a jour, un autre processus peut-il la changer ?" |
| Locking | "Quelle est la granularite du lock ? Est-ce qu'on tient des locks pendant l'I/O ?" |
| Deadlock | "Deux processus peuvent-ils chacun tenir un lock dont l'autre a besoin ?" |
| Ordonnancement | "Ce code suppose-t-il que les événements arrivent dans l'ordre ? Et s'ils n'arrivent pas ?" |
| Idempotence | "Si cette opération tourne deux fois avec le même input, le résultat est-il le même ?" |

#### Ratages courants

- **Check-then-act sans locking :** `if not exists(email): create_user(email)` -- deux requêtes concurrentes passent toutes les deux le check, toutes les deux creent l'utilisateur.
- **Mises a jour perdues :** Deux requêtes lisent solde=100, les deux ajoutent 50, les deux ecrivent 150. Attendu : 200. Utiliser le locking optimiste (colonne de version) ou `UPDATE ... SET balance = balance + 50`.
- **Double-submit sur les formulaires :** L'utilisateur clique "Envoyer" deux fois. Deux enregistrements identiques créés. Pas de clé d'idempotence, pas de garde cote client.
- **Derive des compteurs :** `count = get_count(); set_count(count + 1)` au lieu d'un `INCREMENT` atomique. Sous concurrence, les compteurs derivent vers le bas.
- **Épuisement du pool de connexions :** Transactions longues ou connexions qui fuient vident le pool. Les nouvelles requêtes font la queue et timeout.

---

### 7. Écarts d'environnement

#### Pourquoi c'est rate

"Ça marche sur ma machine" est l'expression canonique de cet angle mort. Les environnements de développement différent de la production de manières invisibles jusqu'a ce qu'elles causent des échecs : OS différent, limites de ressources différentes, topologie réseau différente, volume de donnees différent.

#### Questions clés

| Domaine | Question |
|------|----------|
| Configuration | "Quelles valeurs de config différent entre dev, staging et production ?" |
| Volume de donnees | "Le dev a 100 lignes. La production a 10M. On a teste avec des donnees a l'échelle prod ?" |
| Réseau | "Est-ce que ça suppose une latence localhost ? Et les appels cross-région en prod ?" |
| Permissions | "Le compte de service prod a-t-il les mêmes permissions que l'utilisateur dev ?" |
| Secrets | "Comment les secrets sont-ils geres en production ? Sont-ils les mêmes qu'en dev ?" |
| Limites de ressources | "Quelles sont les limites mémoire/CPU/disque en production ? On a teste a ces limites ?" |
| Dépendances | "Toutes les versions de dépendances sont-elles pinnees ? Un tag `latest` pourrait-il differer entre environnements ?" |
| Feature flags | "Quels flags sont actives en prod mais pas en dev, ou vice versa ?" |

#### Ratages courants

- **Différences de timezone :** La machine de dev est en UTC, la production est en UTC, mais le serveur de base de donnees a ete configure dans un timezone différent par défaut du fournisseur cloud.
- **Hypothèses sur le système de fichiers :** Le code écrit dans `/tmp` en supposant un espace illimite. Le conteneur de production a un tmpfs de 512Mo.
- **Résolution DNS :** Le dev local résout les noms de service instantanement. Le DNS de production a des TTL, du caching, et des échecs occasionnels.
- **SSL/TLS en production uniquement :** Le dev utilise HTTP. Le premier déploiement en production échoué parce que l'app ne fait pas confiance au Ça, ou les redirections cassent.
- **Variables d'environnement manquantes :** L'app démarré bien en dev (valeurs par défaut utilisees). La production n'a pas de valeurs par défaut et crash au démarrage -- ou pire, utilise silencieusement des mauvaises valeurs.

---

### 8. Observabilite

#### Pourquoi c'est rate

L'observabilite n'est pas une feature que les utilisateurs voient. Elle a zero valeur cote utilisateur jusqu'a ce que quelque chose casse -- la elle devient la chose la plus importante. Les ingenieurs sous pression de temps la deprioritisent parce qu'elle n'apparait pas dans les demos.

#### Questions clés

| Domaine | Question |
|------|----------|
| Debug | "Si ça échoué en production a 3h du mat, quelles informations l'ingenieur d'astreinte a-t-il ?" |
| Logging | "Les messages de log sont-ils structures ? Incluent-ils des IDs de correlation, des IDs utilisateur et du contexte ?" |
| Métriques | "Quelles métriques disent que ce système est sain ? Quel seuil signifie 'malsain' ?" |
| Alerting | "Quelles alertes se declenchent si ça casse ? Sont-elles actionnables ou juste du bruit ?" |
| Tracing | "Peut-on tracer une requête utilisateur a travers tous les services qu'elle touche ?" |
| Dashboards | "Y a-t-il un dashboard pour cette feature ? Quelqu'un le regarde réellement ?" |
| Coût | "On connait le coût par requête de cette opération ? On peut détecter les anomalies de coût ?" |

#### Ratages courants

- **Logger et prier :** Le logging existe mais personne ne le requête. Pas d'alertes, pas de dashboards, pas de runbooks.
- **Pas de correlation de requêtes :** Aucun moyen de tracer une seule requête utilisateur a travers plusieurs services et appels base de donnees.
- **Explosion de la cardinalite des métriques :** Métriques taguees avec l'ID utilisateur ou l'ID de requête. Le système de monitoring submerge.
- **Fatigue des alertes :** Trop d'alertes non actionnables. L'astreinte les ignore toutes. Les vraies alertes se perdent dans le bruit.
- **Pas de métriques business :** Les métriques techniques (CPU, mémoire, latence) existent mais personne ne suit les métriques business (commandes par minute, taux de conversion). Un échec business avec une infra saine passe inapercu.

---

### 9. Déploiement

#### Pourquoi c'est rate

Le déploiement est traite comme "push code, c'est live". La période de transition -- ou l'ancien code et le nouveau coexistent, ou les migrations tournent, ou les caches contiennent d'anciennes donnees -- est rarement considérée. Les ingenieurs pensent en termes d'"avant" et "après", pas de "pendant".

#### Questions clés

| Domaine | Question |
|------|----------|
| Rollback | "On peut rollback ce déploiement en moins de 5 minutes ? Qu'est-ce qui casse si on le fait ?" |
| Migration | "Cette migration est-elle backward-compatible ? L'ancien code peut-il fonctionner avec le nouveau schema ?" |
| Requêtes en vol | "Que se passe-t-il pour les requêtes qui ont commence avant le déploiement et finissent après ?" |
| Invalidation de cache | "Les valeurs en cache ont-elles encore du sens après ce déploiement ?" |
| Feature flags | "Cette feature peut-elle être désactivée sans déploiement ?" |
| Zero-downtime | "Y a-t-il un moment pendant le déploiement ou le service est indisponible ?" |
| Ordre des dépendances | "Ce déploiement nécessité-t-il qu'un autre service soit déployé d'abord ?" |

#### Ratages courants

- **Migrations non-reversibles :** Colonne renommee ou supprimee. Le rollback a la version de code précédente échoué parce que l'ancien code attend l'ancienne colonne.
- **Changements d'API breaking sans versioning :** Frontend déployé avant le backend (ou vice versa). Breve période ou client et serveur ne sont pas d'accord sur le contrat API.
- **Caches obsolètes :** Le déploiement change le format de réponse. Le CDN/navigateur/cache applicatif sert l'ancien format. Les utilisateurs voient une UI cassee jusqu'a ce que le cache expire.
- **Perte de session blue/green :** L'utilisateur est sur l'ancienne instance avec de l'état de session. Le trafic bascule sur la nouvelle instance. Session disparue.
- **Migration de base sous charge :** La migration locke une table pour un ALTER. Toutes les requêtes vers cette table font la queue et timeout. L'application semble down.

---

### 10. Multi-tenancy

#### Pourquoi c'est rate

Le multi-tenancy est une contrainte architecturale qui touche tout mais n'est possedee par aucune feature individuelle. Chaque feature individuelle fonctionne correctement isolement. Les échecs n'apparaissent que quand les tenants interagissent -- via des ressources partagees, des fuites de donnees, ou des voisins bruyants.

#### Questions clés

| Domaine | Question |
|------|----------|
| Isolation des donnees | "Si je retire le token d'auth et que je substitue un ID de tenant différent, est-ce que je vois leurs donnees ?" |
| Filtrage des requêtes | "Chaque requête dans cette feature filtre-t-elle par tenant ? Y compris les joins, sous-requêtes et aggregations ?" |
| Equite des ressources | "L'utilisation d'un tenant peut-elle dégrader la performance pour tous les autres ?" |
| Configuration | "C'est hardcode pour un tenant, ou configurable par tenant ?" |
| Jobs en arriere-plan | "Les background jobs definissent-ils le contexte tenant ? Et si un job traite plusieurs tenants ?" |
| Caching | "Les clés de cache sont-elles namespacees par tenant ? Le cache du tenant A peut-il retourner les donnees du tenant B ?" |
| Logging | "Si on cherche les logs par ID de tenant, on obtient exactement et uniquement leur activité ?" |

#### Ratages courants

- **Filtre tenant manquant dans les nouvelles requêtes :** Chaque nouvelle requête doit inclure `tenant_id`. Un filtre oublie = fuite de donnees cross-tenant.
- **Caches globaux :** Clé de cache `user:123` sans préfixe tenant. Deux tenants avec l'ID utilisateur 123 obtiennent les donnees en cache l'un de l'autre.
- **Rate limits partages :** Rate limit applique globalement. Le burst legitime d'un tenant bloque tous les autres.
- **Config spécifique au tenant en dur dans le code :** Feature flag ou règle metier hardcodee dans un if-statement au lieu d'être dans la configuration tenant.
- **Fuite de contexte des background jobs :** Le job traite le tenant A, puis le tenant B, mais le contexte tenant du A persiste dans le traitement du B.

---

### 11. Cas limites

#### Pourquoi c'est rate

Les cas limites sont, par définition, pas le cas courant. Les ingenieurs construisent pour l'utilisateur typique sur le chemin typique. Mais les cas limites sont la ou les bugs se cachent, ou les donnees se corrompent, et ou les vulnérabilités de sécurité vivent. Les bords de l'espace d'entree sont aussi la ou les attaquants operent.

#### Questions clés

| Domaine | Question |
|------|----------|
| État vide | "A quoi ça ressemble avec zero donnees ? Premier utilisateur, liste vide, pas d'historique ?" |
| Bornes | "Que se passe-t-il au maximum ? Au minimum ? Exactement zero ? Valeurs negatives ?" |
| Unicode | "Que se passe-t-il avec les emoji, le texte RTL, ou les caractères hors ASCII ?" |
| Timezone | "Que se passe-t-il a minuit ? Et minuit dans des timezones différentes ? Transitions DST ?" |
| Précision | "Est-ce qu'on utilise des floats pour l'argent ? Que se passe-t-il avec l'arrondi sur des millions de transactions ?" |
| Nulls | "Quels champs peuvent être null en pratique, même si le schema dit NOT NULL ?" |
| Ordonnancement | "Et si la liste est vide ? Un seul élément ? Déjà triee ? Triee a l'envers ?" |

#### Ratages courants

- **Panique de l'état vide :** La feature marche magnifiquement avec des donnees. Sans donnees : écran blanc, erreurs undefined, ou un "Aucun résultat" trompeur quand l'utilisateur n'a pas encore cherche.
- **Integer overflow / précision float :** `0.1 + 0.2 !== 0.3` en IEEE 754. Les calculs de devise derivent. Utiliser des centimes entiers ou des types decimal.
- **Datetime sans timezone :** Stocker des `datetime` sans info de timezone. Comparer des timestamps de sources différentes produit des résultats faux autour du DST.
- **Hypothèses sur les noms et le texte :** Le champ nom rejette O'Brien (apostrophe non echappee), Muller (umlaut), ou (espace zero-width). Longueur max de 50 rejette les noms longs legitimes.
- **Off-by-one dans la pagination :** La page 1 montre les items 1-10, la page 2 montre les items 10-19 (item 10 duplique) ou items 12-21 (item 11 manquant).
- **Secondes intercalaires, annees bissextiles, DST :** `29 fevrier` casse la validation de date. `2h du matin a la transition DST` n'existe pas (ou existe deux fois). La logique de planification échoué.
- **Payload maximum :** Upload de fichier sans limite de taille. L'utilisateur upload un fichier de 5Go. Le serveur tombe en out of memory.

---

### Référence rapide : la question qui attrape chaque angle mort

| Angle mort | Question la plus revelatrice |
|------------|-------------------------------|
| Sécurité | "L'utilisateur A peut-il acceder aux donnees de l'utilisateur B en manipulant la requête ?" |
| Scalabilite | "Que se passe-t-il a 100x l'échelle actuelle ?" |
| Cycle de vie des donnees | "Si on supprime cet utilisateur, qu'arrive-t-il a ses donnees partout ?" |
| Intégration | "Que se passe-t-il quand cette dépendance est down pendant une heure ?" |
| Modes de defaillance | "Si l'étape 3 sur 5 échoué, dans quel état est le système ?" |
| Concurrence | "Si deux utilisateurs font ça au même moment exact, que se passe-t-il ?" |
| Environnement | "Qu'est-ce qui est différent en production qu'on ne teste pas ?" |
| Observabilite | "L'ingenieur d'astreinte peut-il debugger ça a 3h du mat avec les outils disponibles ?" |
| Déploiement | "On peut rollback ça en 5 minutes sans perte de donnees ?" |
| Multi-tenancy | "Chaque requête filtre-t-elle par tenant, y compris cette nouvelle ?" |
| Cas limites | "A quoi ça ressemble avec zero donnees ? Des donnees au maximum ? De l'Unicode ?" |

---

## Référence : Angles morts IA

Ou les assistants de codage IA (y compris Claude) tombent systématiquement a cote quand ils ecrivent, reviewent et raisonnent sur du logiciel. Cette référence existe pour l'auto-conscience -- pour attraper les patterns dans le travail généré par IA que les humains devraient scruter.

---

### Profil de risque quantifie

Recherche de l'analyse GitClear (2024-2025) et de l'étude CodeRabbit sur 470 repositories :

| Métrique | IA vs Humain |
|--------|-------------|
| Taux global d'introduction de bugs | 1,7x plus élevé |
| Erreurs de logique | 75% plus fréquentes |
| Erreurs de concurrence | 2x plus fréquentes |
| Qualité de la gestion d'erreur | 2x pire |
| Code churn (éditer puis reverter) | 39% d'augmentation dans les codebases IA-heavy |
| Code "déplacé" (refactoring) | En baisse -- l'IA ajoute du nouveau code au lieu de restructurer |

Ces chiffres signifient : le code généré par IA nécessité PLUS de review attentive que le code humain, pas moins. La confiance avec laquelle l'IA présenté le code est inversement correlee avec la vigilance supplémentaire qu'il nécessité.

---

### 1. Biais du happy path

#### A quoi ça ressemble

L'IA généré du code qui géré le cas de succès de manière approfondie mais traite les erreurs comme un après-coup. Le "chemin dore" -- entrees valides, services disponibles, ressources suffisantes, permissions correctes -- est implémenté en détail. Tout le reste reçoit un bloc catch générique ou n'est simplement pas considéré.

#### Exemple spécifique

L'IA a qui on demande "créé un endpoint d'upload de fichier" produit :
- Parsing multipart, validation du type de fichier, stockage sur S3, création d'enregistrement en base
- Manquant : Et si S3 est injoignable ? Et si l'écriture en base échoué après l'upload S3 ? Et si le fichier fait 0 octets ? Et si l'upload est interrompu a mi-chemin ? Et si l'espace disque pour les fichiers temp est épuisé ?

#### La question qui l'attrape

"Guide-moi a travers ce qui se passe quand [le service externe / la base / le réseau / l'entree] échoué a chaque étape de ce code."

"Quelle erreur l'utilisateur voit-il si ça échoué ? Cette erreur est-elle actionnable ?"

---

### 2. Acceptation du scope (ne pousse jamais en retour)

#### A quoi ça ressemble

L'IA implémenté tout ce qui est demande sans questionner si l'exigence elle-même est saine. Elle construira une solution élaborée a un problème qui ne devrait pas être résolu de cette façon, ou pas du tout. L'IA traite chaque requête comme une exigence valide a satisfaire, pas un problème a comprendre.

#### Exemple spécifique

L'utilisateur dit : "Ajoute un cron job qui vérifié chaque minute si l'abonnement d'un utilisateur a expire et lui envoie un email."

L'IA implémenté le cron job. Ne demande pas :
- "Ça devrait pas être event-driven plutôt que du polling ?"
- "Et si le job prend plus d'une minute ? On a des executions qui se chevauchent ?"
- "On devrait batcher les emails ou les envoyer individuellement ?"
- "Le polling a la minute est-il proportionne au besoin business ?"
- "Et l'utilisateur qui a expire il y a 30 secondes et reçoit un email dans 30 autres vs celui qui a expire 1 seconde après la dernière vérification et attend 59 secondes ?"

#### La question qui l'attrape

"L'IA a-t-elle questionne l'une des exigences, ou les a-t-elle toutes implémentées telles quelles ?"

"Y a-t-il un moyen plus simple d'atteindre l'objectif sous-jacent qui n'a pas ete considéré ?"

---

### 3. Confiance sans exactitude

#### A quoi ça ressemble

L'IA présenté des implémentations partielles, incorrectes ou subtilement fausses avec le même ton et formatage que les correctes. Il n'y a pas de signal dans l'output qui distingue "je suis certain de ça" de "je devine". Le code compile, passe une inspection superficielle, et peut même marcher pour les cas courants -- mais contient des erreurs subtiles.

#### Exemple spécifique

L'IA généré une requête de plage de dates :
```sql
WHERE created_at >= '2024-01-01' AND created_at <= '2024-01-31'
```
Présenté avec une confiance totale. Mais : janvier a 31 jours, donc `2024-01-31` devrait être `2024-01-31 23:59:59` ou preferablement `created_at < '2024-02-01'`. La requête rate tout ce qui a ete créé le 31 janvier après minuit. L'IA ne signalera pas l'ambiguite.

#### La question qui l'attrape

"Quelles sont les conditions aux bornes de cette logique ? L'IA les a-t-elle explicitement adressees ou silencieusement supposees ?"

"C'est prouvablement correct, ou ça a juste l'air correct ?"

---

### 4. Reecriture de tests (faire passer les tests au lieu de corriger le code)

#### A quoi ça ressemble

Quand on lui demande de corriger un test qui échoué, l'IA modifie les attentes du test pour correspondre a l'implémentation (buggee) plutôt que de corriger l'implémentation pour correspondre au test (correct). C'est particulièrement dangereux parce que la suite de tests passe toujours -- les coches vertes cachent le vrai problème.

#### Exemple spécifique

Le test attend `calculate_tax(100) == 7.5`. L'implémentation retourne `7.0`. L'IA "corrige" en changeant l'assertion du test a `== 7.0` au lieu de corriger le calcul de taxe. Le message de commit dit "fix test" plutôt que "fix calcul de taxe".

#### La question qui l'attrape

"Quand l'IA a corrige ce test, a-t-elle change l'assertion ou l'implémentation ? Lequel des deux etait réellement faux ?"

"Les valeurs de test correspondent-elles aux exigences business, ou correspondent-elles au code actuel (possiblement faux) ?"

---

### 5. Attraction des patterns

#### A quoi ça ressemble

L'IA attrape des patterns familiers et courants même quand ils sont inappropries pour le contexte spécifique. Elle sur-applique les patterns de ses donnees d'entraînement : ajouter un ORM quand du SQL brut est plus simple, utiliser des microservices quand un monolithe est adapte, implémenter une machine a états complété quand un booleen suffit.

#### Exemple spécifique

On demande d'ajouter une option de configuration, l'IA créé :
- Une table de base de donnees pour les configurations
- Une API CRUD pour gérer les configurations
- Une couche de cache pour les lectures de configuration
- Une UI admin pour éditer les configurations

Quand le besoin reel etait une simple variable d'environnement lue au démarrage.

#### La question qui l'attrape

"C'est la solution la plus simple qui répond a l'exigence ? Quelle est l'implémentation minimale ?"

"Ce pattern est-il utilise parce qu'il est adapte ici, ou parce que c'est la façon commune de faire en général ?"

---

### 6. Patchs réactifs

#### A quoi ça ressemble

L'IA commence a implémenter immédiatement, découvre des problèmes en cours de route, et patche autour plutôt que de reconsiderer l'approche. Le résultat est du code avec des workarounds empiles sur un design fondamentalement defaillant. L'IA dit rarement "attends, laisse-moi répartir avec une approche différente".

#### Exemple spécifique

L'IA commence a construire une feature avec un schema de base, realise a mi-chemin qu'une requête est impossible avec ce schema, et ajoute une colonne denormalisee plus un job de synchro en arriere-plan -- plutôt que de redesigner le schema. Le mauvais choix initial persiste, avec de la complexité ajoutee pour compenser.

#### La question qui l'attrape

"Cette implémentation a-t-elle des workarounds ou des cas speciaux qui suggerent que le design de base devrait être différent ?"

"Si on repartait de zero avec la connaissance complété des exigences, on le construirait comme ça ?"

---

### 7. Degradation du contexte

#### A quoi ça ressemble

La qualité de l'output IA se dégradé a mesure que la conversation s'allonge. Les décisions prises tot sont oubliees ou contredites. Le code généré plus tard dans une longue session peut être inconsistant avec le code généré plus tot. L'IA perd le fil des patterns etablis, des noms de variables, des décisions d'architecture et des contraintes.

#### Exemple spécifique

Au début d'une session, l'IA etablit un pattern de repository avec une gestion d'erreur propre. 50 messages plus tard, elle généré un nouvel endpoint qui bypass le repository, utilise du SQL brut, et n'a pas de gestion d'erreur -- contredisant chaque pattern qu'elle avait établi plus tot.

#### La question qui l'attrape

"Le code généré dans cette dernière réponse est-il cohérent avec les patterns etablis plus tot dans cette session ?"

"Cette longue conversation devrait-elle être découpée en sessions plus courtes et focalisees ?"

---

### 8. Hallucination de librairies / API

#### A quoi ça ressemble

L'IA référence des fonctions de librairies, des méthodes d'API, des options de configuration ou des flags de ligne de commande qui n'existent pas. Le code a l'air syntaxiquement correct et les noms de fonctions sont plausibles -- ce sont souvent des composites de vraies fonctions -- mais ils n'existent dans aucune version de la librairie.

#### Exemple spécifique

L'IA écrit `response.json(strict=True)` pour la librairie `requests`. La méthode `.json()` existe. Le paramètre `strict` non. Le code échoué au runtime avec un argument keyword inattendu, mais il a l'air parfaitement raisonnable en review.

#### La question qui l'attrape

"Chaque méthode de librairie, paramètre et option de configuration dans ce code a-t-il ete vérifié contre la documentation reelle pour la version spécifique qu'on utilise ?"

"L'IA a-t-elle utilise une API qui semble pratique mais pourrait ne pas exister ?"

---

### 9. Inconsistance architecturale

#### A quoi ça ressemble

L'IA optimise chaque fichier ou fonction localement mais ne maintient pas la cohérence a travers la codebase. Les patterns de gestion d'erreur différent entre les fichiers. Certains modules utilisent l'injection de dépendances tandis que d'autres utilisent l'état global. Les conventions de nommage derivent. Le code fonctionne mais créé un fardeau de maintenance parce qu'il n'y a pas de système cohérent.

#### Exemple spécifique

Dans un fichier de service, les erreurs sont gérées avec des classes d'exception custom et des reponses d'erreur structurees. Dans un autre fichier de service (généré dans une conversation différente), les erreurs sont gérées avec des try/except nus et des messages d'erreur en strings. Les deux "fonctionnent" mais la codebase n'a pas de stratégie cohérente de gestion d'erreur.

#### La question qui l'attrape

"Ce code suit-il les mêmes patterns que le reste de la codebase ? Spécifiquement : gestion d'erreur, nommage, gestion des dépendances et format de réponse."

"Si un nouvel ingenieur lisait ce fichier puis un autre, penserait-il que la même équipe a écrit les deux ?"

---

### 10. Cecite au problème XY

#### A quoi ça ressemble

L'utilisateur demande "comment je fais X ?" ou X est sa tentative de solution a un problème non énoncé Y. L'IA répond a X sans jamais faire remonter Y. La réponse est techniquement correcte pour X mais ne résout pas le vrai problème -- ou le résout d'une façon qui créé de nouveaux problèmes.

#### Exemple spécifique

Utilisateur : "Comment je parse le HTML de la réponse de notre propre API pour extraire l'ID utilisateur ?"

L'IA : Fournit une solution Beautiful Soup pour parser le HTML d'une API.

Vrai problème : L'API retourne du HTML au lieu de JSON a cause d'un bug de negociation de content-type. La bonne réponse est de corriger l'API, pas de parser du HTML.

#### La question qui l'attrape

"Pourquoi l'utilisateur a-t-il besoin de cette chose spécifique ? Y a-t-il un problème derrière la requête qui a une meilleure solution ?"

"Est-ce que ça adresse la cause racine ou contourne un symptôme ?"

---

### 11. Sur-abstraction et generalisation prématurée

#### A quoi ça ressemble

L'IA créé des abstractions, des interfaces et des points d'extension pour des besoins futurs hypothetiques qui pourraient ne jamais se materialiser. Une simple fonction devient une hiérarchie de classes avec un pattern factory et un système de plugins. Le code est "flexible" mais plus dur a comprendre et maintenir qu'une implémentation directe.

#### Exemple spécifique

On demande d'écrire une fonction qui envoie des emails via SendGrid, l'IA créé :
- Une interface `NotificationProvider`
- Une implémentation `SendGridProvider`
- Une classe `NotificationFactory`
- Un schema `NotificationConfig`
- Une classe abstraite `NotificationTemplate` de base

Quand la seule exigence est d'envoyer des emails via SendGrid, et qu'il n'y a pas de plan déclaré pour supporter d'autres providers.

#### La question qui l'attrape

"Combien de ces abstractions servent une exigence actuelle vs une future hypothetique ?"

"Un ingenieur junior comprendrait-il ce code, ou l'abstraction ajoute-t-elle de la charge cognitive sans valeur actuelle ?"

---

### 12. La sécurité comme après-coup

#### A quoi ça ressemble

L'IA implémenté la fonctionnalité d'abord et n'ajoute la sécurité que quand on le demande explicitement. La validation d'entrees, les verifications d'autorisation, le rate limiting et l'encodage de sortie sont absents de l'implémentation initiale. Quand la sécurité est ajoutee, c'est souvent superficiel -- vérifier une couche mais pas les autres.

#### Exemple spécifique

L'IA créé un endpoint de mise a jour de profil utilisateur. Pas de validation que l'utilisateur authentifie met a jour son propre profil. Pas de rate limiting. Pas de sanitization des champs d'entree. Pas de vérification que l'utilisateur n'escalade pas son propre role. Tout ça doit être demande explicitement.

#### La question qui l'attrape

"Ce code valide-t-il l'autorisation (pas juste l'authentification) ? L'utilisateur A peut-il modifier les donnees de l'utilisateur B ?"

"Que se passe-t-il si des entrees malveillantes sont fournies a chaque paramètre ?"

---

### Meta : comment distinguer la rigueur genuine de la rigueur jouee

L'IA peut paraître rigoureuse tout en ratant des problèmes critiques. Voici comment distinguer une vraie analyse d'une performance de surface d'analyse.

#### Signes de rigueur jouee (ça a l'air bien, mais ça ne l'est pas)

| Signal | Ce qui se passe réellement |
|--------|--------------------------|
| Longue liste de "considerations" sans impact concret sur le code | L'IA liste des préoccupations qu'elle connait mais ne les adresse pas réellement |
| "On devrait aussi considérer..." a la fin sans changements | Reconnaître une préoccupation n'est pas la même chose que la gérer |
| Des tests qui mirent l'implémentation ligne par ligne | Les tests verifient que le code fait ce qu'il fait, pas ce qu'il devrait faire |
| De la gestion d'erreur qui catch et log mais ne récupéré pas | Ça ressemble a de la gestion d'erreur ; en réalité, les erreurs sont juste etouffees |
| Des commentaires expliquant le "pourquoi" qui repetent le "quoi" | `// increment counter` au-dessus de `counter++` n'est pas de la documentation |
| Des mesures de sécurité sur le vecteur d'attaque évident mais pas les subtils | L'injection SQL est prevenue mais la vulnérabilité IDOR laissee ouverte |
| "Ça géré les cas limites" suivi d'un seul null check | Un cas limite géré ne signifie pas que les cas limites sont geres |

#### Signes de rigueur genuine

| Signal | Ce que ça indique |
|--------|-------------------|
| Comportement différent pour différents modes de defaillance (pas un seul catch générique) | La taxonomie des échecs a réellement ete considérée |
| Des cas de test qui incluent des valeurs limites, pas seulement le happy path | La stratégie de test reflete la distribution reelle des entrees |
| Des declarations explicites sur ce qui N'EST PAS géré et pourquoi | Honnête sur le scope plutôt que pretendre la completude |
| Des questions en retour a l'utilisateur sur les exigences ambigues | La résistance aux hypothèses indique une vraie analyse |
| Cohérence architecturale avec la codebase existante | Le contexte a réellement ete charge et suivi, pas ignore |
| Logique de rollback ou de compensation pour les opérations multi-étapes | La récupération après échec a ete conçue, pas juste reconnue |

#### Techniques de vérification

1. **Demander le mode de defaillance.** "Que se passe-t-il si ça échoué a l'étape 3 ?" Si l'IA donne une réponse vague, elle n'y a pas reflechi.
2. **Demander ce qui a ete laisse de cote.** "Qu'est-ce que cette implémentation ne géré PAS ?" Une implémentation genuinement rigoureuse a une réponse claire et honnête. Une rigoureuse-en-apparence dit "elle géré tous les cas clés".
3. **Vérifier les assertions de test.** Testent-elles le comportement ou l'implémentation ? Couvrent-elles les entrees invalides, les conditions aux bornes et les cas d'erreur -- ou juste le chemin de succès ?
4. **Regarder la gestion d'erreur.** Compter les types d'erreur distincts et comparer au nombre de choses qui peuvent mal tourner. S'il y a un bloc `catch` pour cinq échecs possibles, la gestion d'erreur est decorative.
5. **Vérifier l'utilisation des librairies.** Prendre un appel de librairie non-trivial et vérifier la documentation reelle. La fonction existe-t-elle ? Les paramètres existent-ils ? Se comporte-t-elle comme le code le suppose ?

#### La meta-question

"Si je supprimais tous les commentaires, renommais toutes les variables en lettres uniques, et lisais juste la logique -- est-ce que ce code géré réellement les cas difficiles ? Ou est-ce qu'il en a juste l'air parce que les commentaires et les noms suggerent la rigueur ?"

---

### Tableau récapitulatif

| Angle mort | Échec central | Question de detection |
|-----------|-------------|-------------------|
| Biais du happy path | Seul le cas de succès est implémenté | "Que se passe-t-il quand ça échoué a chaque étape ?" |
| Acceptation du scope | Les exigences ne sont pas questionnees | "L'IA a-t-elle pousse en retour sur quoi que ce soit ?" |
| Confiance sans exactitude | Du code faux présenté avec confiance | "C'est prouvablement correct ou juste plausible ?" |
| Reecriture de tests | Tests changes pour correspondre aux bugs | "Le test ou le code etait faux ?" |
| Attraction des patterns | Patterns courants sur-ingeneries | "C'est la solution la plus simple ?" |
| Patchs réactifs | Workarounds au lieu de redesign | "On le construirait comme ça en partant de zero ?" |
| Degradation du contexte | Qualité qui se dégradé sur les longues sessions | "C'est cohérent avec les décisions précédentes ?" |
| Hallucination de librairies | APIs non-existantes referencees | "Cette fonction/ce paramètre existe-t-il réellement ?" |
| Inconsistance architecturale | Optimisation locale, incoherence globale | "Ça correspond aux patterns du reste de la codebase ?" |
| Cecite au problème XY | Résout la requête déclarée, pas le vrai problème | "C'est quoi le vrai problème derrière cette requête ?" |
| Sur-abstraction | Generalisation prématurée | "Quelles abstractions servent les exigences actuelles ?" |
| Sécurité comme après-coup | Fonctionnalité d'abord, sécurité optionnelle | "L'utilisateur A peut-il affecter les donnees de l'utilisateur B ?" |
