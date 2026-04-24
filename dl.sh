#!/bin/zsh
set -euo pipefail

urls=$(mktemp)
vim "$urls"

if [[ ! -s "$urls" ]]; then
    rm "$urls"
    echo "No URLs entered. Exiting."
    exit 0
fi

mkdir -p .downloaded
yt-dlp -f "bestvideo+bestaudio/best" \
    -o ".downloaded/%(uploader)s-%(id)s.%(ext)s" \
    --cookies-from-browser firefox \
    -a "$urls"

outdir=$(date +%Y-%m-%d)
mkdir -p "$outdir"
for f in .downloaded/*; do
    mime=$(file --mime-type -b "$f")
    if [[ "$mime" == video/* ]]; then
        name="${$(basename "$f")%.*}"
        ffmpeg -i "$f" -vcodec libx264 -pix_fmt yuv420p -an "${outdir}/${name}.mp4"
    elif [[ "$mime" == image/* ]]; then
        cp "$f" "${outdir}/$(basename "$f")"
    fi
done

rm -r .downloaded
rm "$urls"
