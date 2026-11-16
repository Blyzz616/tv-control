// Cap 2: jellyfin (slot B — keeps the artwork upright for this cap position)
// 1. Put your SVG at caps/svg/jellyfin.svg
// 2. From caps/tools:  python svg2scad.py ../svg/jellyfin.svg ../gen/jellyfin.scad --prefix jellyfin --list   (then --layer main:index=N,M for the shapes you want)
// 3. Open this file in OpenSCAD. part = "cap" and "art_insert" give the two STLs to print;
//    "cap_preview" shows them together.
include <gen/jellyfin.scad>
include <../enclosure/tv_remote.scad>
part = "cap_preview";   // [cap, art_insert, cap_preview]
cap_slot = "B";
// [layer, height at start, height at end, slope angle]; mm relative to the cap top, 0 = flush
art_layers = [
    [jellyfin_main, 0, 0, 0],
];
