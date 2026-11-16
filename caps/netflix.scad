// Cap 3: netflix (slot A keeps the artwork upright for this cap position)
// 1. Put your SVG at caps/svg/netflix.svg
// 2. From caps/tools:
//      python svg2scad.py ../svg/netflix.svg ../gen/netflix.scad --prefix netflix --list
//      python svg2scad.py ../svg/netflix.svg ../gen/netflix.scad --prefix netflix --layer left:index=A --layer right:index=B --layer diag:index=C
//    (leave the background circle out)
// 3. Open this file in OpenSCAD:
//      part = "cap_preview"          everything together
//      part = "cap"                  print top face down
//      part = "piece", piece = n     print each piece flat side down, in its colour
include <gen/netflix.scad>
include <../enclosure/tv_remote.scad>
part = "cap_preview";
piece = 0;
cap_slot = "A";
// [layer, parent (-1 = cap), bottom, top start, top end, slope angle, colour]  (mm, relative to the cap top)
art_pieces = [
    // two-level pocket: legs sit deeper than the diagonal
    [netflix_left,  -1, -2.2,  0,   -0.8, 0, "darkred"],   // 0: flush on its left edge, down 0.8 on its right
    [netflix_right, -1, -2.2, -0.4, -1.0, 0, "darkred"],   // 1: below the diagonal, sloping down to the right
    [netflix_diag,  -1, -1.6,  0,    0,   0, "red"],       // 2: last, so it covers the legs where they overlap
];
