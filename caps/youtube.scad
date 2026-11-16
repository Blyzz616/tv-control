// Cap 1: youtube (slot A — keeps the artwork upright for this cap position)
// 1. Put your SVG at caps/svg/youtube.svg
// 2. From caps/tools:  python svg2scad.py ../svg/youtube.svg ../gen/youtube.scad --prefix youtube --layer main:fill=#fff
// 3. Open this file in OpenSCAD. part = "cap" and "art_insert" give the two STLs to print;
//    "cap_preview" shows them together.
include <gen/youtube.scad>
include <../enclosure/tv_remote.scad>
part = "cap_preview";   // [cap, art_insert, cap_preview]
cap_slot = "A";
// [layer, height at start, height at end, slope angle]; mm relative to the cap top, 0 = flush
art_layers = [
    [youtube_main, 0, 0, 0],
];
