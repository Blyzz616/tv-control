// nested pieces: frame sits in the cap, the cut-out shape sits in the frame
include <gen_test_nested.scad>
include <../../enclosure/tv_remote.scad>
part = "cap_preview";
cap_slot = "A";
art_pieces = [
    [tnest_frame, -1, -1.6, 0, 0, 0, "red"],     // 0: frame, holes filled
    [tnest_inner,  0, -0.8, 0, 0, 0, "white"],   // 1: the hole shape, sits in piece 0
];
