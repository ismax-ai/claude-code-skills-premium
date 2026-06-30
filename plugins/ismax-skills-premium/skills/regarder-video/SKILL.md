---
name: regarder-video
description: Donne à Claude la capacité de « regarder » une vidéo (lien ou fichier local). Télécharge avec yt-dlp, extrait des images avec FFmpeg, récupère la transcription horodatée (sous-titres natifs, sinon Whisper), et remet images + transcription à Claude pour qu'il réponde sur le contenu de la vidéo.
argument-hint: "<lien-ou-fichier> [ta question]"
allowed-tools: Bash, Read, AskUserQuestion
homepage: https://github.com/ismax-ai/claude-code-skills-premium
author: Ismax (adaptation française de bradautomates/claude-video, MIT)
license: MIT
user-invocable: true
---

# /regarder-video — Claude regarde une vidéo

Claude n'a pas d'entrée vidéo. Ce skill lui en donne une. Un script Python
télécharge la vidéo, en extrait des images (JPEG), récupère une transcription
horodatée (sous-titres natifs d'abord, sinon Whisper), et affiche le chemin des
images. Tu lis ensuite chaque image avec l'outil `Read` et tu combines images +
transcription pour répondre.

Une vidéo, c'est deux choses : des images et des mots. La plupart des outils ne
prennent que la transcription, donc ils ratent ce qui est montré à l'écran
(graphiques, texte, démonstrations). Ce skill récupère les deux.

## Étape 0 — Vérification de l'installation (à chaque appel, silencieux si tout va bien)

**Interpréteur Python :** chaque commande `python3 ...` vise macOS/Linux. Sur
**Windows**, remplace par `python`.

Avant chaque exécution, vérifie que les outils et la clé sont en place :

```bash
python3 "${CLAUDE_SKILL_DIR}/scripts/setup.py" --check
```

Lookup rapide (<100 ms). Si le code de sortie vaut 0, le script n'affiche rien :
passe à l'étape 1 sans commentaire. **N'annonce pas « installation OK »** à
chaque tour. La seule sortie visible acceptable de l'étape 0 concerne une
réparation nécessaire.

Si le code n'est pas 0, suis le tableau :

| Code | Sens | Action |
|------|------|--------|
| `2` | Outils manquants (`ffmpeg` / `ffprobe` / `yt-dlp`) | Lance l'installateur |
| `3` | Pas de clé Whisper | Lance l'installateur, puis demande une clé |
| `4` | Les deux manquent | Lance l'installateur, puis demande une clé |

L'installateur est idempotent (sans danger à relancer) :

```bash
python3 "${CLAUDE_SKILL_DIR}/scripts/setup.py"
```

Sur macOS avec Homebrew, il installe `ffmpeg` et `yt-dlp` automatiquement. Sur
Linux/Windows, il affiche les commandes exactes à lancer. Il crée
`~/.config/watch/.env` avec des emplacements commentés (droits `0600`).

**Si une clé manque encore après l'installation :** utilise `AskUserQuestion`
pour demander à la personne si elle a une clé Groq (recommandée, moins chère et
plus rapide) ou OpenAI. Écris-la ensuite dans `~/.config/watch/.env`
(`GROQ_API_KEY=...` ou `OPENAI_API_KEY=...`). Si elle ne veut pas de Whisper,
continue avec `--no-whisper` : les vidéos sans sous-titres reviendront en images
seules.

Dans une même session, tu peux sauter l'étape 0 aux appels suivants : une fois
que `--check` a renvoyé 0, l'environnement ne change plus entre les tours.

## Quand l'utiliser

- La personne colle un lien vidéo (YouTube, Vimeo, X, TikTok, Twitch, la plupart
  des sites gérés par yt-dlp) et pose une question dessus.
- La personne pointe un fichier local (`.mp4`, `.mov`, `.mkv`, `.webm`, etc.).
- La personne tape `/regarder-video <lien-ou-fichier> [question]`.

## Limites recommandées

- **Meilleure précision : vidéos de moins de 10 minutes.** La couverture en
  images diminue à mesure que la durée augmente.
- **Plafonds : 100 images au total et 2 images/seconde.** Le coût en jetons
  croît avec le nombre d'images, donc le script vise un budget par durée :
  - ≤30s → jusqu'à ~30 images
  - 30s-1min → ~40 images
  - 1-3min → ~60 images
  - 3-10min → ~80 images
  - >10min → 100 images espacées (un avertissement s'affiche)
- Sur une vidéo longue, demande d'abord si la personne veut une section précise
  avant de dépenser des jetons sur un survol clairsemé.

## Comment l'invoquer

**Étape 1 — sépare l'entrée.** Distingue la source (lien ou chemin) de la
question. Exemple : `/regarder-video https://youtu.be/abc dans quelle langue ?`
→ source = `https://youtu.be/abc`, question = `dans quelle langue ?`.

**Étape 2 — lance le script.** Passe la source telle quelle :

```bash
python3 "${CLAUDE_SKILL_DIR}/scripts/watch.py" "<source>"
```

Options utiles :
- `--start T` / `--end T` — cible une section (`SS`, `MM:SS` ou `HH:MM:SS`).
  Quand l'une est définie, la densité d'images augmente automatiquement.
- `--max-frames N` — abaisse le plafond pour un budget plus serré.
- `--resolution W` — largeur des images en px (défaut 512 ; monte à 1024
  seulement s'il faut lire du texte à l'écran).
- `--fps F` — force la cadence (plafonnée à 2 images/seconde).
- `--whisper groq|openai` — force un moteur de transcription.
- `--no-whisper` — désactive Whisper (images seules s'il n'y a pas de sous-titres).

### Cibler une section (cadence plus dense)

Quand la question porte sur un moment précis — « que se passe-t-il à 2 min ? »,
« zoome sur 0:45 à 1:00 » — passe `--start` et/ou `--end`. Le script passe en
mode ciblé (plus dense, toujours plafonné à 2 images/seconde). La transcription
est filtrée sur la même plage. Les horodatages des images sont absolus (vraie
timeline de la vidéo).

```bash
# Les 10 dernières secondes d'une vidéo d'une minute
python3 "${CLAUDE_SKILL_DIR}/scripts/watch.py" video.mp4 --start 50 --end 60

# Zoom sur 2:15 → 2:45
python3 "${CLAUDE_SKILL_DIR}/scripts/watch.py" "$URL" --start 2:15 --end 2:45
```

**Étape 3 — lis chaque image listée.** L'outil `Read` affiche les JPEG comme des
images. Lis toutes les images dans un seul message (appels parallèles) pour les
voir ensemble. Elles sont dans l'ordre chronologique avec un horodatage `t=MM:SS`.

**Étape 4 — réponds.** Tu as deux sources de preuve : les **images** (ce qui est
à l'écran à chaque instant) et la **transcription** (ce qui est dit). L'en-tête
du rapport indique l'origine (`captions` = sous-titres natifs ; `whisper (groq)`
ou `whisper (openai)` = transcrit par API). Si une question précise a été posée,
réponds-y en citant les horodatages. Sinon, résume la vidéo (structure, moments
clés, visuels notables, propos tenus).

**Étape 5 — nettoie.** Le script affiche un dossier de travail. Si la personne ne
posera pas de question de suivi, supprime-le avec `rm -rf <dossier>`.

## Transcription

1. **Sous-titres natifs (gratuit, préféré).** yt-dlp récupère les sous-titres
   manuels ou automatiques de la plateforme s'ils existent.
2. **Whisper (secours).** S'il n'y a pas de sous-titres (ou pour un fichier
   local), le script extrait l'audio et l'envoie à l'API Whisper configurée :
   - **Groq** — `whisper-large-v3`. Défaut préféré : moins cher, plus rapide.
     Clé sur console.groq.com/keys.
   - **OpenAI** — `whisper-1`. Secours. Clé sur platform.openai.com/api-keys.

Les clés vivent dans `~/.config/watch/.env`. `--no-whisper` saute ce secours.

## Pièges et réparations

- **Vérification d'installation échouée** → lance
  `python3 "${CLAUDE_SKILL_DIR}/scripts/setup.py"`.
- **Pas de transcription** → pas de sous-titres ET (pas de clé Whisper OU appel
  échoué). Continue en images seules et préviens la personne.
- **Avertissement vidéo longue** → propose de relancer ciblé sur une section
  avec `--start`/`--end` plutôt qu'un survol clairsemé.
- **Téléchargement échoué** → l'erreur yt-dlp part sur stderr. Si la vidéo exige
  une connexion ou est bloquée par région, dis-le simplement, sans réessayer en
  boucle.
- **« Too Many Requests » (429) ou « confirm you're not a bot »** → YouTube
  limite parfois yt-dlp. Attends quelques secondes et relance une fois ; si ça
  persiste, propose une autre vidéo ou un fichier local. Ne réessaie pas en
  boucle.
- **Whisper échoué** → clé invalide, limite de débit, ou limite d'envoi de 25 Mo
  sur une vidéo très longue. Tu peux réessayer avec `--whisper openai` si Groq a
  échoué (ou l'inverse).

## Sécurité et permissions

Ce skill : lance `yt-dlp` et `ffmpeg` en local ; envoie l'audio extrait à l'API
Whisper (Groq ou OpenAI) uniquement quand les sous-titres manquent ; écrit la
vidéo, les images et l'audio dans un dossier de travail temporaire ; lit/crée
`~/.config/watch/.env` (droits `0600`) pour la clé.

Ce skill **ne fait pas** : il n'envoie jamais la vidéo elle-même à une API
(seul l'audio extrait part, et seulement si nécessaire) ; il n'accède à aucun
compte (pas de connexion, pas de cookies de session) ; il ne partage pas les
clés entre fournisseurs ; il ne journalise jamais les clés.

**Scripts embarqués :** `scripts/watch.py` (entrée), `scripts/download.py`
(yt-dlp), `scripts/frames.py` (extraction FFmpeg), `scripts/transcribe.py`
(sous-titres + Whisper), `scripts/whisper.py` (clients Groq/OpenAI),
`scripts/setup.py` (vérification + installation).

> Adaptation française de `bradautomates/claude-video` (MIT). Voir `ATTRIBUTION.md`.
