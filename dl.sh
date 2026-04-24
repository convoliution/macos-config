#!/bin/zsh
set -euo pipefail

mkdir -p .downloaded
yt-dlp -f "bestvideo+bestaudio/best" \
    -o ".downloaded/%(uploader)s-%(id)s.%(ext)s" \
    --cookies-from-browser firefox \
    -a urls.txt

mkdir -p .out
for f in .downloaded/*; do
    mime=$(file --mime-type -b "$f")
    if [[ "$mime" == video/* ]]; then
        name="${$(basename "$f")%.*}"
        ffmpeg -i "$f" -vcodec libx264 -pix_fmt yuv420p -an ".out/${name}.mp4"
    elif [[ "$mime" == image/* ]]; then
        cp "$f" ".out/$(basename "$f")"
    fi
done

mv .out/* .
rm -r .downloaded .out
rm urls.txt
