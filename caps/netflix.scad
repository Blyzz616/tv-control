// Cap 3: netflix (slot A — keeps the artwork upright for this cap position)
// 1. Put your SVG at caps/svg/netflix.svg
// 2. From caps/tools:  python svg2scad.py ../svg/netflix.svg ../gen/netflix.scad --prefix netflix --list   (then --layer left:index=A --layer right:index=B --layer diag:index=C)
// 3. Open this file in OpenSCAD. part = "cap" and "art_insert" give the two STLs to print;
//    "cap_preview" shows them together.
include <gen/netflix.scad>
include <../enclosure/tv_remote.scad>
part = "cap_preview";   // [cap, art_insert, cap_preview]
cap_slot = "A";
// [layer, height at start, height at end, slope angle]; mm relative to the cap top, 0 = flush
art_layers = [
    [netflix_left,  0,    -0.8, 0],   // flush on its left edge, down 0.8 at its right edge
    [netflix_right, -0.4, -1.0, 0],   // below the diagonal, also sloping down to the right
    [netflix_diag,  0,     0,   0],   // drawn last, so it covers the legs where they overlap
];
