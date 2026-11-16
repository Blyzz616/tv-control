// two-level pocket: the bridge sits at one depth, the bars deeper, bars sloped
include <gen_test_layers.scad>
include <../../enclosure/tv_remote.scad>
part = "cap_preview";
cap_slot = "A";
art_pieces = [
    [tlay_left,   -1, -2.2,  0,   -0.8, 0, "darkred"],   // flush on its left edge, down 0.8 on its right
    [tlay_right,  -1, -2.2, -0.4, -1.0, 0, "darkred"],
    [tlay_bridge, -1, -1.6,  0,    0,   0, "red"],       // last: covers the bars where they overlap
];
