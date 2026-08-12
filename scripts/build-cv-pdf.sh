#!/usr/bin/env bash
# Rebuild files/junha_hyung_cv.pdf from the Overleaf CV project.
#
# The Overleaf source is cloned at ~/projects/overleaf-cv (git bridge). Two
# things have to be patched in a scratch copy before it will build on a current
# TeX Live -- Overleaf itself runs an older one where both are fine:
#   * the class is loaded with the `draft` option
#   * academic-cv.cls redefines \FA after fontawesome.sty already defined it
# Neither patch is pushed back to Overleaf.
set -euo pipefail

SRC="${1:-$HOME/projects/overleaf-cv}"
DEST="$(cd "$(dirname "$0")/.." && pwd)/files/junha_hyung_cv.pdf"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

git -C "$SRC" pull --rebase --quiet
cp -R "$SRC"/. "$TMP"/
cd "$TMP"

sed -i '' 's/\[11pt, letterpaper, draft\]/[11pt, letterpaper]/' cv.tex
sed -i '' 's|^\\newfontfamily\\FA\[Path=\\@fontdir\]{FontAwesome}|\\ifdefined\\FA\\let\\FA\\relax\\fi\\newfontfamily\\FA[Path=\\@fontdir]{FontAwesome}|' academic-cv.cls

tectonic -X compile cv.tex --outfmt pdf
cp cv.pdf "$DEST"
echo "wrote $DEST"
