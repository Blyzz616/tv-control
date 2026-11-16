// Cap 1: youtube (slot A keeps the artwork upright for this cap position)
// 1. Put your SVG at caps/svg/youtube.svg
// 2. From caps/tools:
//      python svg2scad.py ../svg/youtube.svg ../gen/youtube.scad --prefix youtube --layer tv:fill=#fff:solid --layer play:fill=#fff:holes
//    (tv = the rounded TV outline with its hole filled; play = the triangle cut out of it)
// 3. Open this file in OpenSCAD:
//      part = "cap_preview"          everything together
//      part = "cap"                  print top face down
//      part = "piece", piece = n     print each piece flat side down, in its colour
include <gen/youtube.scad>
include <../enclosure/tv_remote.scad>
part = "cap_preview";
piece = 0;
cap_slot = "A";
// [layer, parent (-1 = cap), bottom, top start, top end, slope angle, colour]  (mm, relative to the cap top)
art_pieces = [
    [youtube_tv,   -1, -1.6, 0, 0, 0, "red"],     // 0: TV shape, sits in the cap
    [youtube_play,  0, -0.8, 0, 0, 0, "white"],   // 1: play triangle, sits in piece 0
];
