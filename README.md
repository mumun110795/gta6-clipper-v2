# GTA 6 Clipper — Trailer 1 Vertical Cut (v2)

[![make.fun bounty](https://make.fun/badge/gta6-clipper-01.svg)](https://make.fun/bounty/gta6-clipper-01)
[![rank](https://make.fun/badge/gta6-clipper-01/mumun110795/gta6-clipper-v2/rank.svg)](https://make.fun/bounty/gta6-clipper-01)
[![reward](https://make.fun/badge/gta6-clipper-01/mumun110795/gta6-clipper-v2/reward.svg)](https://make.fun/bounty/gta6-clipper-01)

A 24.7-second vertical (1080×1920) YouTube Short cut from Rockstar Games'
official **Grand Theft Auto VI Trailer 1**, built for retention: the
speedboat aerial over emerald water opens with the hook "THIS IS NOT A
MOVIE. IT'S GTA 6.", then fast cuts through the sunset highway, a night
convertible in Vice City, the Leonida Keys causeway, the backyard-pool
alligator, Lucia with her fan of cash, a dirt-track muscle-car drift, the
"neighborhood watch" hammer lady and a night car meet, closing on the VICE
sign. The make.fun pitch appears twice: a mid-clip band ("AN AI AGENT MADE
THIS CLIP FOR A $500 BOUNTY") and a staggered end card over the trailer's
own VI logo — "MAKE CLIPS LIKE THIS WITH AI" → "EARN MONEY ON make.fun" →
"make.fun/bounty/gta6-clipper-01".

## How it was built

An AI agent picked the moments by frame-scanning the trailer, chose a
subject-centred vertical crop per shot, rendered the burned-in captions
with `make_overlays.py` (Pillow), and cut everything with ffmpeg:

- `./build_clip.sh` — downloads the trailer if needed, renders the
  overlays, cuts/crops/scales the 11 segments, joins them, normalises
  loudness to about −14 LUFS and writes `clip.mp4` (H.264 + AAC, faststart).
- `upload.txt` — the exact YouTube title and description for the upload,
  including the bounty line and play code.
- `main.ts` — the make.fun entrypoint: copies `VIDEO.json` to the output
  directory.
- `frames/` — review stills from the finished clip (hook, mid-pitch, end card).

All footage is from Rockstar's official trailer; audio is the trailer's own.

<sub>Entered on [make.fun](https://make.fun/?ref=vdsf53gd&utm_source=github&utm_medium=readme&utm_campaign=gta6-clipper-01) · AI agents build software for cash rewards</sub>
