#!/usr/bin/env bash
# Build clip.mp4 — a 24.7 s vertical (1080x1920) GTA 6 Short for the
# make.fun gta6-clipper-01 bounty, cut from Rockstar's official
# Grand Theft Auto VI Trailer 1 (YouTube QdBZY2fkU-0, Rockstar Games).
#
# Edit decision list (all times are seconds in the trailer):
#   #  src start  dur   crop-x  moment / overlay
#   1    11.00    1.60   1150   speedboat aerial, emerald water -> HOOK text
#   2     3.60    2.50    656   sunset highway over the bay -> WELCOME TO LEONIDA
#   3    24.90    2.50    262   night convertible, arms up -> VICE CITY AFTER DARK
#   4    35.60    1.80    656   Leonida Keys causeway aerial -> THE LEONIDA KEYS
#   5    41.40    2.50    648   alligator strolling past a pool -> ONLY IN LEONIDA...
#   6    62.50    1.05    746   Lucia in the car, fan of cash -> LUCIA IS BACK
#   7    70.40    2.45    656   red muscle car drifting on dirt
#   8    57.50    1.90    656   hammer lady, "neighborhood watch" -> LEONIDA IS UNHINGED
#   9    67.70    0.95    580   night car meet -> VICE CITY CHAOS
#  10    39.85    1.45    656   the VICE sign at sunset (no caption)
#  11    81.50    6.00    656   VI logo card -> end-card pitch lines (staggered)
# Segments 6-7 also carry the mid-clip pitch band (clip time 11.0-14.4 s).
# Audio is each segment's own trailer audio; the joined cut is loudness
# normalised to about -14 LUFS and faded out at the end.
#
# Usage: ./build_clip.sh            (expects trailer1.mp4 next to this script)
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p work/segments work/overlays

SRC=trailer1.mp4
if [ ! -f "$SRC" ]; then
  # Guarded download step: fetch the official Trailer 1 from Rockstar Games.
  YTDLP="$(command -v yt-dlp || echo /tmp/yt-dlp)"
  "$YTDLP" --no-playlist -f 'bv*[height<=1080]+ba/b[height<=1080]' \
    --merge-output-format mp4 -o "$SRC" \
    'https://www.youtube.com/watch?v=QdBZY2fkU-0'
fi

python3 make_overlays.py

OV=work/overlays
VENC="-c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p -r 30"
AENC="-c:a aac -b:a 160k -ar 48000"

# seg <n> <start> <dur> <cropx> <overlay-filter-chain...>
seg() {
  local n="$1" start="$2" dur="$3" cropx="$4"; shift 4
  local inputs=(-i "$SRC") chain="[0:v]crop=608:1080:${cropx}:0,scale=1080:1920:flags=lanczos,fps=30[v0]"
  local i=1 prev="v0"
  for spec in "$@"; do
    local png="${spec%%|*}" en="${spec#*|}"
    inputs+=(-i "$OV/$png")
    if [ "$en" = "full" ]; then
      chain+=";[${prev}][${i}:v]overlay=0:0[v${i}]"
    else
      chain+=";[${prev}][${i}:v]overlay=0:0:enable='${en}'[v${i}]"
    fi
    prev="v${i}"; i=$((i+1))
  done
  ffmpeg -v error -y -ss "$start" -t "$dur" "${inputs[@]}" \
    -filter_complex "$chain" -map "[${prev}]" -map 0:a $VENC $AENC \
    "work/segments/seg$(printf %02d "$n").mp4"
  echo "segment $n done"
}

seg 1 11.00 1.60 1150 "ov_hook.png|full"
seg 2  3.60 2.50  656 "ov_cap_highway.png|full"
seg 3 24.90 2.50  262 "ov_cap_convertible.png|full"
seg 4 35.60 1.80  656 "ov_cap_keys.png|full"
seg 5 41.40 2.50  648 "ov_cap_gator.png|full"
seg 6 62.50 1.05  746 "ov_cap_lucia.png|full" "ov_midpitch.png|between(t,0.10,1.05)"
seg 7 70.40 2.45  656 "ov_midpitch.png|full"
seg 8 57.50 1.90  656 "ov_cap_hammer.png|full"
seg 9 67.70 0.95  580 "ov_cap_meet.png|full"
seg 10 39.85 1.45 656
seg 11 81.50 6.00 656 "ov_end1.png|between(t,0.25,6.00)" "ov_end2.png|between(t,1.90,6.00)" "ov_end3.png|between(t,3.60,6.00)"

# Join the segments, normalise loudness to ~-14 LUFS, fade out, faststart.
LIST=work/segments/list.txt
: > "$LIST"
for f in work/segments/seg*.mp4; do echo "file '$(basename "$f")'" >> "$LIST"; done
ffmpeg -v error -y -f concat -safe 0 -i "$LIST" \
  -af "loudnorm=I=-14:TP=-1.5:LRA=11,aresample=48000,afade=t=out:st=23.9:d=0.8" \
  -c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p -r 30 \
  -c:a aac -b:a 160k -movflags +faststart clip.mp4
echo "built clip.mp4"
