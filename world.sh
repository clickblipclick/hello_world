#!/bin/sh
# hello world
#
# The world, for visitors who arrive by terminal and have no page to put it on.
# It is the same world: the same waves decide where the land is, the light
# comes from the same corner, and the moon keeps the same hours. Only the
# weather has been left behind, weather being difficult to pipe.
#
#   curl -s https://helloworldandthen.com/world.sh | sh
#
# You were right to read this first. It draws, and it waits, and that is all
# it does. It writes nothing down, asks for nothing, and takes nothing away;
# there is nothing here to take. Control-C stops it. The world carries on
# elsewhere, in the usual way, without you.
#
# If what it is drawing on is not a terminal -- a file, a pipe, a printer --
# the world holds still for one picture and leaves. It has done this before.
#
#   sh world.sh           it turns until told otherwise
#   sh world.sh still     one picture, whatever it is being drawn on
#   sh world.sh | lpr     the same picture, on paper, at your own expense

still=0
[ -t 1 ] || still=1
[ "$1" = still ] && still=1

if [ "$still" = 0 ]; then
  # Put the cursor away while the world is out, and give it back afterwards.
  printf '\033[?25l\033[2J'
  trap 'printf "\033[?25h\n  goodbye world. it has not stopped; you have.\n\n"; exit 0' INT TERM
fi

awk -v still="$still" '
function land(lat, lon) {
  return sin(lon * 2 + 1) * cos(lat * 3) + sin(lon * 5 + lat * 2) * 0.5 + cos(lon * 3 - lat * 4 + 2) * 0.4 > 0.35
}
function asin(v) { return atan2(v, sqrt(1 - v * v)) }
function put(x, y, c) { if (x >= 0 && x < CW && y >= 0 && y < H) cell[x, y] = c }

# The Shade: a small round night under the moon, when the moon is out in front.
function shaded(nx, ny,   z, x, sx, sy, sr) {
  z = sin(ma); x = cos(ma) * 1.32
  if (z <= 0.15) return 0
  sx = x + 0.1; sy = x * 0.2 - z * 0.3 + 0.08; sr = 0.1 + z * 0.08
  return (nx - sx) * (nx - sx) + (ny - sy) * (ny - sy) < sr * sr
}

# The Caret: one ship, keeping to the water by looking a little way ahead.
function sail(   a, b, l, c, x, y, u, i) {
  for (i = 0; i < 6; i++) {
    a = slat + sin(head) * 0.09; b = slon + cos(head) * 0.09 / cos(slat)
    if (land(a, b) || a > 1.1 || a < -1.1) head += 0.04 * helm
    else {
      slat += sin(head) * 0.001; slon += cos(head) * 0.001 / cos(slat)
      head += (rand() - 0.5) * 0.03
      if (rand() < 0.002) helm = -helm
    }
  }
  l = slon - spin; c = cos(slat)
  if (c * cos(l) <= 0) return
  x = OFF + int((c * sin(l) + 1) / 2 * W); y = int((sin(slat) + 1) / 2 * H)
  u = cell[x, y]
  if (u == "~" || u == "-" || u == ".") cell[x, y] = "^"
}

# The At: round the back and out again. It is drawn last when it is in front, and not at all when it is behind.
function moon(   x, z, y) {
  x = cos(ma) * 1.32; z = sin(ma); y = x * 0.2 - z * 0.3
  if (z < 0 && x * x + y * y < 1.02) return
  put(OFF + int((1 + x) / 2 * W), int((1 + y) / 2 * H), "@")
}

function draw(   x, y, nx, ny, r2, nz, lat, lon, light, c, out) {
  for (y = 0; y < H; y++) for (x = 0; x < CW; x++) cell[x, y] = " "
  for (y = 0; y < H; y++) {
    for (x = 0; x < W; x++) {
      nx = (x + 0.5) / W * 2 - 1; ny = (y + 0.5) / H * 2 - 1
      r2 = nx * nx + ny * ny
      if (r2 > 1) continue
      nz = sqrt(1 - r2)
      lat = asin(ny); lon = atan2(nx, nz) + spin
      light = shaded(nx, ny) ? 0 : nx * -0.5 + ny * -0.4 + nz * 0.75
      if (lat > 1.25 || lat < -1.25) c = light > 0.3 ? "*" : "+"
      else if (land(lat, lon)) c = light > 0.55 ? "#" : light > 0.2 ? "o" : ":"
      else c = light > 0.5 ? "~" : light > 0.15 ? "-" : "."
      cell[OFF + x, y] = c
    }
  }
  sail(); moon()
  out = ""
  for (y = 0; y < H; y++) {
    for (x = 0; x < CW; x++) out = out cell[x, y]
    sub(/ +$/, "", out)
    out = out (still ? "" : "\033[K") "\n"
  }
  return out
}

BEGIN {
  W = 44; H = 22; OFF = 9; CW = W + OFF * 2
  srand()
  spin = rand() * 6.28; ma = rand() * 6.28
  slat = 0.2; slon = rand() * 6.28; head = rand() * 6.28; helm = 1
  while (land(slat, slon)) slon += 0.1

  if (still) {
    printf "\n%*s\n\n%s\n", OFF + 27, "hello world", draw()
    print "  It was turning until you asked. This is where it had got to."
    print ""
    exit
  }
  days = 0
  while (1) {
    printf "\033[H\n%*s\033[K\n\033[K\n%s\033[K\n", OFF + 27, "hello world", draw()
    printf "  day %d. it turns on its own. control-c lets go of it.\033[K\n", days + 1
    fflush()
    if (system("sleep 0.1 2>/dev/null || sleep 1") != 0) exit
    spin += 0.072; ma += 0.027
    days = int(turned / 6.2832); turned += 0.072
  }
}
'

[ "$still" = 0 ] && printf '\033[?25h'
exit 0
