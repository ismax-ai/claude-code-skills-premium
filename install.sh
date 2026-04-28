#!/bin/bash
# Installation des skills Claude Code Premium
# Usage : bash install.sh

SKILLS_DIR="$HOME/.claude/commands"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/skills"

# Créer le dossier si nécessaire
mkdir -p "$SKILLS_DIR"

# Compter les fichiers
count=0
for file in "$SOURCE_DIR"/*.md; do
    [ -f "$file" ] || continue
    name=$(basename "$file")
    cp "$file" "$SKILLS_DIR/$name"
    count=$((count + 1))
    echo "  ✓ $name"
done

echo ""
echo "$count skills installés dans $SKILLS_DIR"
echo ""
echo "Pour les utiliser, ouvre Claude Code et tape /"
echo "suivi du nom du skill (ex: /sentinel, /karen, /ralph)"
