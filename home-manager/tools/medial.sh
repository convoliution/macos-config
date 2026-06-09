outdir=$(date +%Y-%m-%d)
mkdir -p "$outdir"

# prompt user for URLs
urls="${outdir}/$(date +%H-%M-%S)-urls.txt"
vim "$urls"
if [[ ! -s "$urls" ]]; then
    rm -f "$urls"
    echo "No URLs entered. Exiting."
    exit 0
fi

# attempt download using gallery-dl
downloads=$(mktemp -d)
failed_urls=$(mktemp)
while read -r url; do
    if ! gallery-dl \
        --directory "${downloads}" \
        --filename "{username|author[name]|author[handle]|blog[name]|author}-{id|tweet_id|post_id|media_id}-{num:>02}.{extension}" \
        --cookies-from-browser firefox \
        "$url"
    then
        echo "$url" >> "${failed_urls}"
    fi
done < "$urls"

# attempt download using yt-dlp
if [[ -s "${failed_urls}" ]]; then
    success_urls=$(mktemp)
    yt-dlp \
        --paths "${downloads}" \
        --output "%(uploader)s-%(id)s.%(ext)s" \
        --ffmpeg-location "$(which ffmpeg)" \
        --cookies-from-browser firefox \
        --ignore-errors \
        --print-to-file "after_video:%(webpage_url)s" "${success_urls}" \
        --batch-file "${failed_urls}"
    remaining=$(grep -vxFf "${success_urls}" "${failed_urls}" || true)
    if [[ -n "$remaining" ]]; then
        echo "$remaining" > "${outdir}/failed.txt"
    fi
    rm "${success_urls}"
fi
rm "${failed_urls}"

# normalize videos' format
for f in "${downloads}"/*; do
    mime=$(file --mime-type -b "$f")
    if [[ "$mime" == video/* ]]; then
        filename=$(basename "$f")
        name="${filename%.*}"
        ffmpeg -loglevel error -i "$f" -c:v libx265 -crf 18 -pix_fmt yuv420p -tag:v hvc1 -c:a aac "${outdir}/${name}.mp4"
    elif [[ "$mime" == image/* ]]; then
        cp "$f" "${outdir}/$(basename "$f")"
    fi
done
rm "$urls"
