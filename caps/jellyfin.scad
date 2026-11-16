// Cap 2: jellyfin (slot B keeps the artwork upright for this cap position)
// 1. Put your SVG at caps/svg/jellyfin.svg
// 2. From caps/tools:
//      python svg2scad.py ../svg/jellyfin.svg ../gen/jellyfin.scad --prefix jellyfin --list
//      python svg2scad.py ../svg/jellyfin.svg ../gen/jellyfin.scad --prefix jellyfin --layer outer:index=N --layer inner:index=M
//    (leave the background square out; the outer fin keeps its hole)
// 3. Open this file in OpenSCAD:
//      part = "cap_preview"          everything together
//      part = "cap"                  print top face down
//      part = "piece", piece = n     print each piece flat side down, in its colour
include <gen/jellyfin.scad>
include <../enclosure/tv_remote.scad>
part = "cap_preview";
piece = 0;
cap_slot = "B";
// [layer, parent (-1 = cap), bottom, top start, top end, slope angle, colour]  (mm, relative to the cap top)
art_pieces = [
    [jellyfin_outer, -1, -1.2, 0, 0, 0, "mediumpurple"],   // 0: outer fin
    [jellyfin_inner, -1, -1.2, 0, 0, 0, "deepskyblue"],    // 1: inner fin
];
