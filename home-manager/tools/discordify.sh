target_mb=9

input="$1"
dir=$(dirname "$input")
filename=$(basename "$input")
name="${filename%.*}"

# https://trac.ffmpeg.org/wiki/FFprobeTips#Formatcontainerduration
duration=$(ffprobe -i "$input" -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 | cut -d. -f1)

# https://trac.ffmpeg.org/wiki/Encode/H.265#Two-PassEncoding
audio_kbitrate=128
bitrate=$(( (target_mb * 8388) / duration - audio_kbitrate ))
ffmpeg -y -i "$input" -c:v libx265 -b:v "${bitrate}k" -x265-params pass=1 -an -f null /dev/null
ffmpeg -y -i "$input" -c:v libx265 -b:v "${bitrate}k" -x265-params pass=2 -pix_fmt yuv420p -tag:v hvc1 -c:a aac -b:a "${audio_kbitrate}k" "${dir}/${name}-compressed.mp4"
rm -f x265_2pass.log x265_2pass.log.cutree
