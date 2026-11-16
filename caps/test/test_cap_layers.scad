include <gen_test_layers.scad>
include <../../enclosure/tv_remote.scad>
part = "cap_preview";
cap_slot = "A";
art_layers = [
    [tlay_left,   0,    -0.8, 0],   // flush at its left edge, down 0.8 at its right edge
    [tlay_right, -0.4,  -1.0, 0],   // lower than the bridge, also sloping down to the right
    [tlay_bridge, 0,     0,   0],   // flush, drawn over both bars
];
