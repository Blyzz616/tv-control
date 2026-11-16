// TV remote: quad-button enclosure (copied from big_quad_button.scad v7) + M5Stack Unit Scroll (U186)
// wheel and PCB built in between caps 2 and 3. Two mounting options: scroll_mount = "top" or "side".
// The Unit Scroll's own shell is replaced by a printed copy of its geometry fused to the lid, so the
// original wheel + PCB + bottom plate screw into the lid exactly as they did into M5's shell.
//
// Original header (big_quad_button.scad):
// Big QUAD Button enclosure: 2x M5Stack Unit Dual Button + Seeed XIAO ESP32-C6 (USB-C out the side)  -- v7 (+ seam groove, + optional tactile cap textures)
// base = v2 (unchanged), cap = v4 style (short skirt + retention flange) at the v2 hinge height,
// lid = v1 (no key groove) with the guide sleeves cut down to a 0.5 mm lip.
// Units: mm. Frame: enclosure centre at XY origin, Z=0 = bottom face of base.
// Long axis = Y. Grove/cable end = -Y. Cap slot A = -Y side, slot B = +Y side.
// Caps are rockers: they pivot on snap-in hinge posts that rise from the base
// (2&4 o'clock / 8&10 o'clock when viewed from the top with the Grove end at 3 o'clock)
// and a foot presses the M5 button. Caps snap in/out from the top; lid stays on.

/* [Part to render] */
part = "assembly"; // [assembly, section, lid, base, cap, cap_inlay, symbol_insert, art_insert, cap_preview, none]
// Rotate lid/cap into print orientation (top face on bed)
print_orient = true;
// Assembly only: show caps pressed
show_pressed = false;

/* [Cap artwork] */
// Which slot this cap is for (only matters for artwork orientation)
cap_slot = "A"; // [A, B]
cap_label = "";
cap_label_size = 9;
cap_label_font = "Liberation Sans:style=Bold";
// Optional SVG file (path relative to this .scad). Leave empty for none.
cap_svg = "";
// SVG is scaled so its width = this
cap_svg_size = 28;
// Engrave depth (also inlay thickness for multi-colour)
art_depth = 0.6;
// Extra rotation of the artwork (deg)
art_rotation = 0;

/* [Cap artwork layers (caps/tools/svg2scad.py)] */
// [[polygon_data, h_start, h_end, slope_angle], ...]. Heights are mm relative to the cap top
// (0 = flush, negative = recessed). The height runs linearly from h_start to h_end across the
// layer's own extent along slope_angle (0 = left->right, 90 = bottom->top, artwork upright).
// Later layers win where layers overlap. Set by the files in caps/.
art_layers = [];
art_size = 30;           // SVG viewBox width -> this many mm
art_pocket = 1.6;        // pocket depth in the cap; the insert's flat bottom sits on its floor
art_insert_clear = 0.1;  // insert clearance per side
art_insert_min = 0.6;    // thinnest allowed insert (warns below this)

/* [Cap texture] */
// Raised tactile texture on the cap top
texture = "none"; // [none, lines, waves, crosshatch]
texture_h = 0.5;       // height of the ridges
texture_pitch = 2.5;   // centre-to-centre spacing of ridges
texture_w = 1.0;       // ridge width
wave_amp = 1.2;        // waves: amplitude
wave_len = 8;          // waves: wavelength
tex_steps = 5;         // bevel steps over the ridge height
tex_side = 0.06;       // per-step inset of each ridge side (top width = texture_w - 2*tex_side*(tex_steps-1))

/* [Cap symbol (engraved)] */
symbol = "none"; // [none, fan, snowflake, lightsoff, timer_add, timer_query_hourglass, timer_query_eye, timer_query_qmark]
symbol_depth = 0.8;    // engraving depth
symbol_chamfer = 0.3;  // edge chamfer at the surface (no sharp edges)
symbol_size = 30;      // overall symbol size
insert_clear = 0.1;    // glue-in inserts: clearance per side
tick_w = 0.5;          // clock hour-tick width (ticks are left out of the glue-in inserts)

/* [Seam groove] */
seam_h = 0.4;          // groove height on each part (0.8 total where lid meets base)
seam_d = 0.6;          // groove depth into the wall

/* [Files] */
unit_stl = "ref/m5_dual_button_unit.stl"; // only used by assembly/section views
scroll_dir = "ref/scroll_parts/";          // U186 parts split from M5's Unit_Scroll.stl (housing frame)

/* [Scroll wheel: M5Stack Unit Scroll U186] */
// top = wheel rolls front/back on the lid; side = wheel pokes out of the -X long wall
scroll_mount = "top"; // [top, side, none]
// Extra gap added between the two halves (caps 1-2 | caps 3-4), per side. -1 = auto (top 3, side 5, none 0)
spread = -1;
// top only: X position of the shell's Grove end (shell is 32 mm long along X)
scroll_top_x0 = -12.6;
// clearance around the wheel in the lid/wall slot
scroll_slot_clear = 0.4;
// side only: how far the shell drops below the lid's bottom edge into the base
scroll_side_drop = 3;

/* [Hardware: M4 bolt + heat-set insert] */
bolt_len      = 15.6; // incl. head
bolt_head_d   = 6.7;
bolt_head_h   = 3.8;
bolt_clear_d  = 4.4;
insert_hole_d = 5.6; // CHECK against your insert's recommended hole
insert_len    = 8.1; // CHECK against your insert length

/* [XIAO ESP32-C6] */
xiao_l = 21;        // board length (USB-C end faces the +X wall)
xiao_w = 17.8;      // board width
xiao_pcb_t = 1.0;   // CHECK: PCB thickness
usb_overhang = 0.6; // CHECK: how far the USB-C receptacle sticks past the PCB edge
usb_h = 3.2;        // CHECK: USB-C receptacle height
usb_hole_w = 9.4;   // hole for the plug's metal shell (USB-C shell ~8.3 x 2.6, CHECK)
usb_hole_h = 3.6;
usb_recess_w = 11.5; // shallow recess on the outside for the plug's moulded body (CHECK against your cable)
usb_recess_h = 6.5;
usb_recess_d = 1.6;  // leaves 0.8 mm of wall around the hole so the plug seats fully
seat_z = 7.5;       // top of the board seat (keeps the USB opening clear of the seam)
esp_rim_h = 3.0;
solder_w = 3.0;     // shallow channels in the seat under each row of pins, for solder
solder_d = 3.0;
solder_in = 1.3;    // CHECK: distance from the board's long edge to the pin centres
// pad on the lid that presses down on the ESP32 module
press_w = 12;       // across the box (Y)
press_l = 10;       // along the board (X)
press_gap = 9.5;    // from the inside of the USB-C wall to the pad's near edge
press_drop = 14.5;  // hangs this far below the underside of the lid    // height of the locating wall around the board, above the seat

/* [Fit / clearances] */
cap_d        = 40;
cap_hole_clear = 0.25; // v1 lid radial clearance
hinge_rod_d  = 3.0;    // pivot rod on the cap
hinge_play   = 0.2;    // radial clearance rod-in-socket
hinge_mouth  = 2.4;    // snap mouth width (< rod dia = snap interference)
foot_gap     = 0.0;    // foot to M5 button cap at rest
cable_slot_w = 7;
cable_slot_h = 6;
lid_slot_w   = 6;    // v7 lid cable slot (rectangular)
lid_slot_h   = 1.5;

/* [Hidden] */
$fn = 96;
$no_ticks = false;
eps = 0.01;

// ---- M5 unit placement (from STL analysis) ----
unit_off   = [0, -6, 6.8];    // STL origin (centred) -> enclosure
unit_top_z = 5.1 + 6.8;       // grey shell top = 11.9
btn_top_z  = 9.2 + 3.0 + 6.8; // M5 cap top at rest = 19.0
btn_y      = [-7, 7];
unit_w = 24; unit_l = 48; unit_y0 = -30; unit_y1 = 18;

// ---- U186 shell frame (origin = shell min corner; shell 24 x 32 x 14.8, bottom plate z -2.3..1.2) ----
sc_shell = [24, 32, 14.8];
sc_wheel_c = [12.4, 22.4, 9.7];       // wheel centre (wheel spans x 4.1..20.7, d 13.8)
sc_shoulder = [7.7, 16.3];            // open gap between the shell's top shoulders (wheel sits here)
sp = spread >= 0 ? spread : (scroll_mount == "top" ? 3 : scroll_mount == "side" ? 5 : 0);

// ---- enclosure ----
W = 54; L = 206 + 2*sp; R_corner = 5; wall = 2.4;
base_h   = 6;
lid_top  = 30;
plate_t  = 3;
cap_y    = [-77-sp, -31-sp, 31+sp, 77+sp];     // 4 caps in a row
cap_rot  = [0, 180, 0, 180];        // foot of each cap points at its M5 button
// M5 units: [x, y, rotation]; Grove ports face the middle of the box
unit_pos = [[0,-48-sp,180], [0,48+sp,0]];
cap_r    = cap_d/2;
hole_r   = cap_r + cap_hole_clear;

// ---- inner wall around the unit ----
iw_t = 1.6; iw_clear = 0.25; iw_top = unit_top_z; grove_gap = 10;

// ---- cap ----
cap_top = lid_top + 3;
disk_t  = 3;
skirt_t = 1.5;
relief_top = 29.2; // post-top reliefs stop 0.8 mm below the lid top (invisible from above)
sleeve_lip = 0.5;                        // what is left of the v1 sleeves below the plate
flange_r = cap_r + 1.0;
flange_flat = 0.4;
flange_gap = 0.5;                        // vertical gap flange -> lip at rest
// flange cone crosses the hole radius at (plate underside - lip - gap)
skirt_bot = lid_top - plate_t - sleeve_lip - flange_gap - (flange_r - hole_r) - flange_flat;
foot_off = 16;
foot_r   = 3.5;

// ---- hinge (cap-local: foot toward +Y, hinge toward -Y) ----
// hinge posts sit fully inside the cap skirt (no gaps in the cap sides);
// 13 mm between them leaves room for the Grove plug under the inner caps
hx = 8.25;
hy = -11.5;
hz = 27.2;                       // pivot axis height
rod_r = hinge_rod_d/2;
sock_r = rod_r + hinge_play;
jaw_r = sock_r + 1.3;
post_w = 3.5; post_l = 6;
web_t = 1.6;
tie_z = [19, 21];    // gantry bar between the posts (top stays below the jaw flex slit)
arch_ang = 50;       // slope of the support gussets under the bar, from horizontal (prints without support)

boss_pos = [[21,97+sp],[-21,97+sp],[21,-97-sp],[-21,-97-sp],[21,54+sp],[-21,-54-sp]];   // 4 corners + 2 middle, diagonal
boss_r = 5;
pocket = [unit_w+0.5, unit_l+0.5, 2];

module rrect(x, y, r, h) {
    linear_extrude(h) offset(r) square([x-2*r, y-2*r], center=true);
}
module xcyl(r, len) { rotate([0,90,0]) cylinder(r=r, h=len, center=true); }

// ================= CAP (local frame) =================
module cap_body() {
    difference() {
        cap_core();
        if (symbol != "none") symbol_cut();
    }
    if (texture != "none") {
        // ridges built in thin steps so their sides slope and their ends are bevelled at the rim
        dh = texture_h/tex_steps;
        for (k=[0:tex_steps-1])
            translate([0,0,cap_top+k*dh-(k==0 ? 0.05 : 0)])
                linear_extrude(dh+(k==0 ? 0.05 : 0)+eps)
                    intersection() {
                        circle(r=cap_r-0.6-k*dh);
                        offset(delta=-k*tex_side) texture2d();
                    }
    }
}

module cap_core() {
    rod_len = 2*cap_r;                // edge to edge, merged into the skirt
    difference() {
        union() {
            difference() {
                union() {
                    translate([0,0,skirt_bot]) cylinder(r=cap_r, h=cap_top-skirt_bot);
                    translate([0,0,skirt_bot]) cylinder(r=flange_r, h=flange_flat);
                    translate([0,0,skirt_bot+flange_flat]) cylinder(r1=flange_r, r2=cap_r, h=flange_r-cap_r);
                }
                translate([0,0,skirt_bot-eps]) cylinder(r=cap_r-skirt_t, h=cap_top-disk_t-skirt_bot+eps);
            }
            translate([0, foot_off, btn_top_z+foot_gap]) {
                cylinder(r1=foot_r-0.8, r2=foot_r, h=0.8);
                translate([0,0,0.8]) cylinder(r=foot_r, h=cap_top-disk_t-(btn_top_z+foot_gap)-0.8+eps);
            }
            intersection() {
                cylinder(r=cap_r-0.2, h=100);
                translate([0, hy, 0]) {
                    translate([-rod_len/2, -web_t/2, hz]) cube([rod_len, web_t, cap_top-disk_t-hz+eps]);
                    translate([0,0,hz]) xcyl(rod_r, rod_len);
                }
            }
        }
        translate([0,0,cap_top-0.6]) difference() {
            cylinder(r=cap_r+1, h=1);
            cylinder(r1=cap_r, r2=cap_r-0.6-eps, h=0.6+eps);
        }
        translate([0,0,cap_top-art_depth]) linear_extrude(art_depth+1) art2d();
        if (len(art_layers) > 0)
            translate([0,0,cap_top-art_pocket]) linear_extrude(art_pocket+1) art_frame() for (l=art_layers) art_poly(l[0]);
    }
}

// ---- layered artwork (SVG polygons from caps/tools/svg2scad.py) ----
module art_poly(d) polygon(d[0], d[1]);
module art_frame() { rotate((cap_slot == "A" ? -90 : 90) + art_rotation) scale([art_size, art_size, 1]) children(); }
module art_layer_own(i) {
    difference() {
        art_poly(art_layers[i][0]);
        if (i < len(art_layers)-1) for (j=[i+1:len(art_layers)-1]) art_poly(art_layers[j][0]);
    }
}
// glue-in insert: flat bottom on the pocket floor, each layer's top on its own (sloped) plane
module art_insert() {
    zb = cap_top - art_pocket;
    for (i=[0:len(art_layers)-1]) {
        l = art_layers[i]; a = l[3];
        ss = [for (p=l[0][0]) p[0]*cos(a) + p[1]*sin(a)];
        s0 = min(ss); s1 = max(ss);
        k = s1 > s0 ? (l[2]-l[1])/(s1-s0) : 0;
        if (art_pocket + min(l[1], l[2]) < art_insert_min)
            echo(str("WARNING: art layer ", i, " insert is ", art_pocket + min(l[1], l[2]), " mm at its thinnest"));
        if (max(l[1], l[2]) > 0)
            echo(str("NOTE: art layer ", i, " stands ", max(l[1], l[2]), " mm proud of the cap top"));
        intersection() {
            translate([0,0,zb]) linear_extrude(art_pocket + max(l[1], l[2]) + 1)
                offset(delta=-art_insert_clear) art_frame() art_layer_own(i);
            art_frame() multmatrix([[1,0,0,0],[0,1,0,0],[k*cos(a), k*sin(a), 1, cap_top + l[1] - k*s0],[0,0,0,1]])
                translate([-2,-2,-50]) cube([4,4,50]);
        }
    }
}

module texture2d() {
    n = ceil(cap_r/texture_pitch)+1;
    if (texture == "lines")
        for (i=[-n:n]) translate([i*texture_pitch-texture_w/2, -cap_r-1]) square([texture_w, 2*cap_r+2]);
    if (texture == "crosshatch")
        for (a=[45,-45]) rotate(a) for (i=[-n:n]) translate([i*texture_pitch*1.6-texture_w/2, -cap_r-1]) square([texture_w, 2*cap_r+2]);
    if (texture == "waves") {
        steps = 120; L2 = cap_r+2;
        for (i=[-n:n]) {
            x0 = i*texture_pitch*1.3;
            pts = [for (k=[0:steps]) let(y=-L2+2*L2*k/steps) [x0+wave_amp*sin(360*y/wave_len)-texture_w/2, y]];
            pts2 = [for (k=[steps:-1:0]) let(y=-L2+2*L2*k/steps) [x0+wave_amp*sin(360*y/wave_len)+texture_w/2, y]];
            polygon(concat(pts, pts2));
        }
    }
}

module symbol_cut() {
    st = 4; dh = symbol_depth/st;
    for (k=[0:st])
        translate([0,0,cap_top-symbol_depth+k*dh-(k==st ? 0 : 0)])
            linear_extrude(k==st ? 1 : dh+eps)
                offset(delta=symbol_chamfer*k/st) symbol_placed();
}

// glue-in insert: the engraving volume shrunk by insert_clear, flush with the cap top
module symbol_insert() {
    $no_ticks = true;   // ticks stay cap colour
    st = 4; dh = symbol_depth/st;
    for (k=[0:st-1])
        translate([0,0,cap_top-symbol_depth+k*dh])
            linear_extrude(dh+(k<st-1 ? eps : 0))
                offset(delta=symbol_chamfer*k/st-insert_clear) symbol_placed();
}

module symbol_placed() {
    rot = (cap_slot == "A" ? -90 : 90) + art_rotation;   // upright with the cable end on your right
    rotate(rot) scale(symbol_size/30) symbol2d();
}

// symbols drawn in a 30 mm box, "up" = +Y
module symbol2d() {
    symbol2d_extra();
    timer_symbols();
    if (symbol == "fan") {
        difference() { circle(r=3.6); circle(r=1.6); }             // hub (no outer ring)
        for (a=[0:120:359]) rotate(a)                               // 3 swept blades
            hull() { translate([4.0,0.6]) circle(r=1.4); translate([9.4,3.0]) circle(r=3.2); translate([12.6,1.6]) circle(r=2.0); }
    }
    if (symbol == "snowflake") {
        w = 1.4;
        for (a=[0:60:359]) rotate(a) {
            translate([-w/2,0]) square([w,13.5]);                       // arm
            translate([0,13.5]) circle(d=w);
            for (p=[[7.0,4.0],[10.6,2.6]])                              // side branches
                translate([0,p[0]]) for (m=[-1,1]) rotate(m*50) { translate([-w/2,0]) square([w,p[1]]); translate([0,p[1]]) circle(d=w); }
        }
        circle(r=2.2);
    }
    if (symbol == "nolight") {
        bar_a = -45; bar_w = 2.2;
        difference() { circle(r=15); circle(r=12.8); }              // ring
        difference() {
            union() {                                               // solid bulb
                translate([0,-1.6]) {                                // centred under the slash
                hull() { translate([0,4.2]) circle(r=5.0); translate([-1.5,-3.4]) square([3.0,0.1]); }  // slim pear-shaped bulb
                translate([-1.9,-5.1]) offset(r=0.4) square([3.8,0.8]);   // socket rings
                translate([-1.5,-6.9]) offset(r=0.4) square([3.0,0.8]);
                translate([-0.8,-8.0]) offset(r=0.3) square([1.6,0.4]);   // tip
                }
            }
            rotate(bar_a) square([40, bar_w+2.4], center=true);     // gap around the slash
        }
        intersection() { rotate(bar_a) square([40, bar_w], center=true); circle(r=13.5); }
    }
}

module light_burst(rc=3.4, r0=4.4, r1=9.6, w=1.0, n=8) {   // rays start at the sun ring
    difference() { circle(r=rc+1.0); circle(r=rc); }                  // light source ring
    for (a=[0:360/n:359]) rotate(a+22.5) hull() { translate([0,r0]) circle(d=w); translate([0,r1]) circle(d=w); }
    for (a=[0:360/n:359]) rotate(a) hull() { translate([0,r0]) circle(d=w); translate([0,r0+(r1-r0)/2]) circle(d=w); }   // half-length rays
}
module clock_ring() {
    difference() { circle(r=15); circle(r=13.4); }                   // dial ring
    if (!$no_ticks) for (a=[0:30:359]) rotate(a) hull() { translate([0,10.2]) circle(d=tick_w); translate([0,11.8]) circle(d=tick_w); }  // 12 hour ticks
}
module timer_symbols() {
    if (symbol == "timer_add") {
        clock_ring();
        for (a=[0,90]) rotate(a) hull() { translate([0,-6.5]) circle(d=2.4); translate([0,6.5]) circle(d=2.4); }   // plus
    }
    if (symbol == "timer_query_hourglass") {
        clock_ring();
        scale(0.8) {
            difference() {
                polygon([[-4.6,6.8],[4.6,6.8],[0.6,0],[4.6,-6.8],[-4.6,-6.8],[-0.6,0]]);
                offset(delta=-1.2) polygon([[-4.6,6.8],[4.6,6.8],[0.6,0],[4.6,-6.8],[-4.6,-6.8],[-0.6,0]]);
            }
            for (y=[-7.6,7.6]) translate([-5.8,y-0.8]) offset(r=0.4) square([11.6,1.6], center=false);
            polygon([[-2.6,-6.0],[2.6,-6.0],[0,-2.8]]);                                 // sand
        }
    }
    if (symbol == "timer_query_eye") {
        clock_ring();
        difference() {
            intersection() { translate([0,-4.2]) circle(r=8.4); translate([0,4.2]) circle(r=8.4); }
            intersection() { translate([0,-4.2]) circle(r=7.1); translate([0,4.2]) circle(r=7.1); }
        }
        circle(r=2.2);
    }
    if (symbol == "timer_query_qmark") {
        clock_ring();
        translate([0,0.3]) text("?", size=13, font="Liberation Sans:style=Bold", halign="center", valign="center");
    }
}

module symbol2d_extra() {
    bar_w = 2.2;
    if (symbol == "lightsoff" || symbol == "lightsoff_noring") {
        if (symbol == "lightsoff") difference() { circle(r=15); circle(r=12.8); }
        difference() { light_burst(); rotate(-45) square([40, bar_w+2.4], center=true); }
        intersection() { rotate(-45) square([40, bar_w], center=true); circle(r=symbol=="lightsoff" ? 13.5 : 12); }
    }
    if (symbol == "power") {
        difference() {
            difference() { circle(r=11); circle(r=8.8); }
            translate([-3.4,0]) square([6.8,20]);
        }
        hull() { translate([0,2]) circle(d=2.2); translate([0,13]) circle(d=2.2); }
    }
}

module art2d() {
    rot = (cap_slot == "A" ? -90 : 90) + art_rotation; // upright with the cable end on your right
    rotate(rot) {
        if (cap_label != "")
            text(cap_label, size=cap_label_size, font=cap_label_font, halign="center", valign="center");
        if (cap_svg != "")
            resize([cap_svg_size, 0], auto=true) import(cap_svg, center=true);
    }
}
module cap_inlay() { translate([0,0,cap_top-art_depth]) linear_extrude(art_depth) art2d(); }

// ================= HINGE POSTS (cap-local, on the base) =================
module hinge_posts() {
    for (s=[-1,1]) translate([s*hx, hy, 0]) difference() {
        union() {
            translate([-post_w/2, -post_l/2, base_h-eps]) cube([post_w, post_l, hz-base_h+eps]);
            translate([0,0,hz]) xcyl(jaw_r, post_w);
            // foot fillet
            translate([0,0,base_h-eps]) linear_extrude(3, scale=[post_w/(post_w+2), post_l/(post_l+2)])
                square([post_w+2, post_l+2], center=true);
        }
        translate([0,0,hz]) xcyl(sock_r, post_w+1);
        translate([-post_w, -hinge_mouth/2, hz]) cube([2*post_w, hinge_mouth, 10]);
        // relief slit so the jaws flex
        translate([-post_w, -0.4, hz-sock_r-4.5]) cube([2*post_w, 0.8, 5]);
    }
    // gantry bar, plus two gussets under it forming an inverted V that meets the bar's
    // underside, so the bar never prints over air; the opening below is full width for the Grove plug
    gi = hx - post_w/2;                      // half-gap between the posts' inner faces
    spring = tie_z[0] - gi*tan(arch_ang);    // where the gussets leave the posts
    translate([-hx, hy-1.5, tie_z[0]]) cube([2*hx, 3, tie_z[1]-tie_z[0]]);
    // each gusset: post face -> bar underside centre, overlapping post and bar by 0.5 mm so they fuse
    for (m=[-1,1]) translate([0, hy+1.5, 0]) rotate([90,0,0]) linear_extrude(3)
        scale([m,1]) polygon([[-gi-0.5, spring-0.5*tan(arch_ang)], [0.3, tie_z[0]+0.3*tan(arch_ang)],
                              [0.3, tie_z[0]+0.5], [-gi-0.5, tie_z[0]+0.5]]);
}

// ================= LID =================
module lid() {
    difference() {
        union() {
            difference() {
                lid_body();
                if (scroll_mount != "none") scroll_xform() scroll_wheel_env();   // lid plate / wall must not touch the wheel
            }
            if (scroll_mount != "none") difference() {
                scroll_xform() import(str(scroll_dir, "housing.stl"));
                scroll_lid_clip();
            }
        }
        if (scroll_mount != "none") scroll_xform() scroll_slot();
    }
}

module lid_body() {
    difference() {
        union() {
            difference() {
                translate([0,0,base_h]) rrect(W, L, R_corner, lid_top-base_h);
                translate([0,0,base_h-eps]) rrect(W-2*wall, L-2*wall, R_corner-wall, lid_top-plate_t-base_h+eps);
            }
            // v1 sleeves, cut down to a 0.5 mm lip
            for (i=[0:len(cap_y)-1]) translate([0,cap_y[i],lid_top-plate_t-sleeve_lip]) cylinder(r=hole_r+2, h=plate_t+sleeve_lip);
            for (p=boss_pos) translate([p[0],p[1],base_h]) cylinder(r=boss_r, h=lid_top-base_h-eps);
            esp_press();
        }
        for (i=[0:len(cap_y)-1]) translate([0,cap_y[i],lid_top-plate_t-sleeve_lip-1]) cylinder(r=hole_r, h=plate_t+sleeve_lip+2);
        // small reliefs where the v2 hinge-post tops reach into the lid plate
        for (i=[0:len(cap_y)-1]) translate([0,cap_y[i],0]) rotate(cap_rot[i])
            for (s=[-1,1]) translate([s*hx-(post_w+1)/2, hy-(post_l+1)/2, lid_top-plate_t-sleeve_lip-1])
                cube([post_w+1, post_l+1, relief_top-(lid_top-plate_t-sleeve_lip-1)]);
        for (p=boss_pos) translate([p[0],p[1],base_h-eps]) {
            cylinder(d=insert_hole_d, h=insert_len+0.5);
            cylinder(d=bolt_clear_d, h=bolt_len-bolt_head_h-(base_h-4.0)+1.5);
        }
        // outer seam groove (lid half)
        translate([0,0,base_h-eps]) seam_ring(seam_h+eps);
        // USB-C: stadium hole for the shell + rounded recess for the plug body
        translate([W/2-wall-1, 0, usb_cz()]) rotate([0,90,0]) linear_extrude(wall+2)
            hull() for (m=[-1,1]) translate([0, m*(usb_hole_w-usb_hole_h)/2]) circle(d=usb_hole_h);
        translate([W/2-usb_recess_d, 0, usb_cz()]) rotate([0,90,0]) linear_extrude(usb_recess_d+1)
            offset(r=1.5) square([usb_recess_h-3, usb_recess_w-3], center=true);
    }
}

function usb_cz() = seat_z + xiao_pcb_t + usb_h/2;
function board_x1() = W/2 - wall - usb_overhang;
function board_x0() = board_x1() - xiao_l;

module seam_ring(h) {
    linear_extrude(h) difference() {
        offset(R_corner+2) square([W-2*R_corner, L-2*R_corner], center=true);
        offset(R_corner-seam_d) square([W-2*R_corner, L-2*R_corner], center=true);
    }
}

// ================= BASE =================
module inner_wall_u() {   // unit frame: unit centred, Grove end at -Y
    ix = unit_w/2 + iw_clear; iy0 = -unit_l/2 - iw_clear; iy1 = unit_l/2 + iw_clear;
    translate([0,0,base_h-eps]) linear_extrude(iw_top-base_h+eps) difference() {
        translate([-ix-iw_t, iy0-iw_t]) square([2*(ix+iw_t), iy1-iy0+2*iw_t]);
        translate([-ix, iy0]) square([2*ix, iy1-iy0]);
        translate([-grove_gap/2, iy0-iw_t-1]) square([grove_gap, iw_t+2]);
    }
}

module solder_channels() {
    for (m=[-1,1]) translate([board_x0()+0.8, m*(xiao_w/2-solder_in)-solder_w/2, seat_z-solder_d])
        cube([xiao_l-1.6, solder_w, solder_d+1]);
}

module esp_press() {
    if (scroll_mount == "top") {
        // the scroll shell sits over the module, so press on the USB-C receptacle end instead
        x0 = scroll_top_x0 + sc_shell[1] + 0.6;
        z0 = seat_z + xiao_pcb_t + usb_h;
        translate([x0, -press_w/2, z0]) cube([W/2-wall-x0+eps, press_w, lid_top-plate_t-z0+eps]);
    } else {
        x1 = W/2 - wall - press_gap;
        translate([x1-press_l, -press_w/2, lid_top-plate_t-press_drop]) cube([press_l, press_w, press_drop+eps]);
    }
}

// ================= SCROLL (U186) =================
// shell frame -> enclosure
module scroll_xform() {
    if (scroll_mount == "top")         // shell top flush with lid top, Grove end toward -X, wheel rolls along X
        translate([scroll_top_x0, sc_shell[0]/2, lid_top-sc_shell[2]]) rotate([0,0,-90]) children();
    else if (scroll_mount == "side")   // shell top flush with the -X outer wall, wheel axis vertical.
        // The shell + bottom plate are 24 mm tall this way up, so they drop 3 mm into a pocket in the base
        // to stay clear of the lid plate (shell is part of the lid; lid still lifts straight off).
        translate([-W/2+sc_shell[2], -sc_shell[1]/2, base_h-scroll_side_drop]) rotate([0,-90,0]) children();
}
// opening above the wheel, between the shell shoulders, through the lid plate / wall
module scroll_slot() {
    c = scroll_slot_clear;
    translate([sc_shoulder[0], sc_wheel_c[1]-6.9-c, 11.5]) cube([sc_shoulder[1]-sc_shoulder[0], 13.8+2*c, 10]);
}
// wheel swept volume + clearance (only removed from the lid body, never from the printed shell)
// stops 1.4 mm below the outer surface so only the slot shows from outside
module scroll_wheel_env() {
    c = scroll_slot_clear;
    intersection() {
        translate([3.6, sc_wheel_c[1], sc_wheel_c[2]]) rotate([0,90,0]) cylinder(d=13.8+2*c+1, h=17.6);
        translate([-1, -1, -10]) cube([30, 40, 10+sc_shell[2]-1.4]);
    }
}
// side: the part of the shell that would sit inside the base's outer wall is left off
module scroll_lid_clip() {
    if (scroll_mount == "side") translate([-W/2-1, -L/2, -1]) cube([wall+1+0.3, L, base_h+1]);
}
// keep the base's locating ridge out of the side-mounted shell
module scroll_base_clear() {
    if (scroll_mount == "side")
        translate([-W/2+wall, -sc_shell[1]/2-0.3, base_h-scroll_side_drop-0.3]) cube([sc_shell[2]+2.3-wall+0.3, sc_shell[1]+0.6, 10]);
}
module scroll_parts() {   // the reused M5 parts, for assembly views
    scroll_xform() {
        color("orange") import(str(scroll_dir, "wheel.stl"));
        color("red") import(str(scroll_dir, "hub_part.stl"));
        color("green") import(str(scroll_dir, "corner_part.stl"));
        color("tan") import(str(scroll_dir, "bottom.stl"));
    }
}

module esp_seat() {
    x0 = board_x0(); x1 = board_x1(); c = 0.2; rim = 1.2;
    translate([x0-c-rim, -xiao_w/2-c-rim, base_h-eps]) cube([23.0-(x0-c-rim), xiao_w+2*(c+rim), seat_z-base_h+eps]);
    translate([0,0,seat_z-eps]) linear_extrude(esp_rim_h+eps) difference() {
        translate([x0-c-rim, -xiao_w/2-c-rim]) square([23.0-(x0-c-rim), xiao_w+2*(c+rim)]);
        translate([x0-c, -xiao_w/2-c]) square([30, xiao_w+2*c]);
    }
}

module base() {
    difference() {
        union() {
            rrect(W, L, R_corner, base_h);
            difference() {
                translate([0,0,base_h-eps]) rrect(W-2*wall-0.5, L-2*wall-0.5, R_corner-wall-0.25, 1.5);
                translate([0,0,base_h-1]) rrect(W-2*wall-0.5-2.4, L-2*wall-0.5-2.4, R_corner-wall-1.45, 4);
                for (p=boss_pos) translate([p[0],p[1],base_h-1]) cylinder(r=boss_r+0.5, h=4);
            }
            for (u=unit_pos) translate([u[0],u[1],0]) rotate(u[2]) inner_wall_u();
            for (i=[0:len(cap_y)-1]) translate([0,cap_y[i],0]) rotate(cap_rot[i]) hinge_posts();
            esp_seat();
        }
        for (u=unit_pos) translate([u[0],u[1],base_h-pocket[2]]) rotate(u[2]) rrect(pocket[0], pocket[1], 2, pocket[2]+1);
        solder_channels();
        scroll_base_clear();
        // outer seam groove (base half)
        translate([0,0,base_h-seam_h]) seam_ring(seam_h+eps);
        for (p=boss_pos) translate([p[0],p[1],-eps]) {
            cylinder(d=bolt_head_d+0.5, h=4.0);
            cylinder(d=bolt_clear_d, h=base_h+2);
        }
    }
}

module unit() { for (u=unit_pos) color("grey") translate([u[0],u[1],unit_off[2]]) rotate(u[2]) import(unit_stl); }
module xiao() { color("green") translate([board_x0(), -xiao_w/2, seat_z]) cube([xiao_l, xiao_w, xiao_pcb_t]); }

// rocker angle for pressed state: foot moves down 0.6 + gap
press_ang = atan((0.6+foot_gap)/(foot_off-hy));
module caps_all(pressed=false) { for (i=[0:len(cap_y)-1]) cap_placed(i, pressed); }
module cap_placed(i, pressed=false) {
    translate([0,cap_y[i],0]) rotate(cap_rot[i])
        translate([0,hy,hz]) rotate([pressed ? -press_ang : 0,0,0]) translate([0,-hy,-hz]) cap_body();
}

if (part == "lid") {
    if (print_orient) translate([0,0,lid_top]) rotate([180,0,0]) lid(); else lid();
} else if (part == "base") {
    base();
} else if (part == "cap") {
    if (print_orient) translate([0,0,cap_top]) rotate([180,0,0]) cap_body(); else cap_body();
} else if (part == "symbol_insert") {
    // printed visible-face down
    if (print_orient) translate([0,0,cap_top]) rotate([180,0,0]) symbol_insert(); else symbol_insert();
} else if (part == "art_insert") {
    // printed flat bottom down, as modelled
    translate([0,0,-(cap_top-art_pocket)]) art_insert();
} else if (part == "cap_preview") {
    color("dimgray") cap_body(); color("red") art_insert();
} else if (part == "cap_inlay") {
    if (print_orient) translate([0,0,cap_top]) rotate([180,0,0]) cap_inlay(); else cap_inlay();
} else if (part == "none") {
} else if (part == "section") {
    difference() {
        union() {
            color("tan") base(); color("lightblue", 0.9) lid(); unit();
            color("royalblue") caps_all(show_pressed); xiao(); scroll_parts();
        }
        translate([0,-150,-10]) cube([100,300,100]);
    }
} else {
    color("tan") base(); color("lightblue", 0.5) lid(); unit();
    color("royalblue") caps_all(show_pressed); xiao(); scroll_parts();
}
