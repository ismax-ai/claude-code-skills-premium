---
description: "Red Team challenge : attaque un output avec 20 profils professionnels (CIA, Six Hats, OWASP)"
---

# /sentinel — Red Team Challenge

Lance une attaque Red Team sur le contenu fourni. 20 profils d'attaque professionnels, un score sur 10, un verdict clair.

## Usage

```
/sentinel content    → Challenge un texte (newsletter, post, article)
/sentinel code       → Challenge du code (script, feature, architecture)
/sentinel decision   → Challenge une décision business ou stratégique
/sentinel idea       → Challenge une idée ou un concept
/sentinel            → Auto-détecte le type
```

## Ce que tu dois faire

1. **Identifier le contenu à challenger** :
   - Si `$ARGUMENTS` contient un type (content/code/décision/idea), utiliser ce type
   - Si `$ARGUMENTS` est vide, demander quel output challenger
   - Le contenu = le dernier output significatif de la conversation, OU un texte collé directement

2. **Lancer les 3 batteries d'attaque** (voir ci-dessous)

3. **Présenter le résultat** :
   - Score /10 + verdict (PASS / FAIL / AMEND)
   - Chaque finding avec sévérité + recommandation
   - Si FAIL : proposer les corrections concrètes
   - Si AMEND : proposer les corrections et demander confirmation
   - Si PASS : confirmer et noter les améliorations mineures

4. **Si FAIL ou AMEND et l'utilisateur dit "corrige"** :
   - Appliquer les corrections
   - Re-lancer le Red Team sur la version corrigée
   - Boucler jusqu'à PASS

---

## Batterie 1 — CIA Structured Analytic Techniques (9 attaques)

Les SATs sont les techniques utilisées par les analystes du renseignement pour éviter les biais cognitifs.

| # | Technique | Question posée au contenu |
|---|-----------|---------------------------|
| 1 | **Key Assumptions Check** | Quelles hypothèses non vérifiées sous-tendent ce contenu ? |
| 2 | **Pre-mortem** | On est 6 mois plus tard, ça a échoué. Qu'est-ce qui a mal tourné ? |
| 3 | **Analysis of Competing Hypothèses** | Quelles autres explications ou approches possibles ? |
| 4 | **Devil's Advocacy** | L'argument le plus fort CONTRE cette position ? |
| 5 | **Structured Self-Critique** | Où est-ce que l'auteur se trompe probablement ? |
| 6 | **Red Hat Analysis** | Quelles réactions émotionnelles chez le lecteur/utilisateur ? |
| 7 | **What If Analysis** | Si une variable clé changeait, le contenu tient-il encore ? |
| 8 | **Team A/B** | Deux équipes, deux conclusions, laquelle est la plus solide ? |
| 9 | **Deception Detection** | Quelque chose est-il présenté de manière trompeuse ou biaisée ? |

---

## Batterie 2 — Six Thinking Hats (6 perspectives)

Méthode d'Edward de Bono. Chaque chapeau force une perspective différente.

| Chapeau | Perspective | Ce qu'il cherche |
|---------|-------------|------------------|
| **Blanc** | Faits | Quelles données sont vérifiées vs supposées ? |
| **Rouge** | Émotions | Quelle réaction instinctive du lecteur ? Malaise ? Enthousiasme ? Méfiance ? |
| **Noir** | Critique | Qu'est-ce qui peut mal tourner ? Quels risques ignorés ? |
| **Jaune** | Optimisme | Quel est le meilleur scénario réaliste ? Quelles forces sous-exploitées ? |
| **Vert** | Créativité | Quelle alternative non explorée ? Quel angle mort ? |
| **Bleu** | Processus | La méthode utilisée est-elle solide ? Le raisonnement est-il structuré ? |

---

## Batterie 3 — OWASP LLM (5 vérifications)

Adapté des standards de sécurité pour les modèles de langage (OWASP Top 10 for LLM).

| # | Vérification | Question |
|---|-------------|----------|
| 1 | **Excessive Agency** | Le contenu promet-il plus que ce qu'il peut délivrer ? |
| 2 | **Misinformation** | Y a-t-il des affirmations sans source ou des chiffres non vérifiés ? |
| 3 | **Prompt Injection** | Le contenu est-il ambigu ou manipulable hors contexte ? |
| 4 | **Supply Chain** | Les sources citées sont-elles fiables et vérifiables ? |
| 5 | **Improper Output** | Le ton et le format sont-ils adaptés à l'audience cible ? |

---

## Scoring

Pour chaque finding, noter :
- **Sévérité** : CRITIQUE / HAUTE / MOYENNE / BASSE
- **Finding** : ce qui a été détecté
- **Recommandation** : comment corriger concrètement

**Score global sur 10. Verdict :**
- **PASS** (7+/10) : contenu solide. Corrections mineures optionnelles.
- **AMEND** (4-6/10) : problèmes détectés. Corrections nécessaires avant publication.
- **FAIL** (<4/10) : problèmes critiques. Réécriture nécessaire.

---

## Format de sortie

```
🔴 RED TEAM — [TYPE]
═══════════════════════════════════════

CIA SATs : [X/9 passed]
  [findings par technique]

Six Hats : [X/6 clean]
  [findings par chapeau]

OWASP : [X/5 passed]
  [findings par vérification]

═══════════════════════════════════════
SCORE : X/10
VERDICT : [PASS | AMEND | FAIL]
[corrections prioritaires si AMEND/FAIL]
```
