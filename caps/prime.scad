// Cap 4: prime (slot B keeps the artwork upright for this cap position)
// 1. Put your SVG at caps/svg/prime.svg
// 2. From caps/tools:
//      python svg2scad.py ../svg/prime.svg ../gen/prime.scad --prefix prime --layer main:all
//    (the a and the swoosh come out as one piece with two separate bodies)
// 3. Open this file in OpenSCAD:
//      part = "cap_preview"          everything together
//      part = "cap"                  print top face down
//      part = "piece", piece = n     print each piece flat side down, in its colour
include <gen/prime.scad>
include <../enclosure/tv_remote.scad>
part = "cap_preview";
piece = 0;
cap_slot = "B";
// [layer, parent (-1 = cap), bottom, top start, top end, slope angle, colour]  (mm, relative to the cap top)
art_pieces = [
    [prime_main, -1, -1.2, 0, 0, 0, "deepskyblue"],   // 0: a + swoosh
];
