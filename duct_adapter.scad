// Duct Adapter - 3-Piece System (Threaded)
// ==============================================
// Problem: Printed filter box has a 106mm OD flange with a 110mm lip.
//          The 100mm flex duct can't slide over the lip.
//
// Solution:
//   1. SPLIT CAPTURE RING (x2 halves) - Fits around the flange behind
//      the lip. Threaded inserts on the back face.
//   2. ADAPTER SLEEVE - Bolts through its flange plate into the ring
//      inserts, holding both ring halves AND the sleeve in place.
//      The flex duct screws OVER the sleeve tube via spiral thread.
//
// The sleeve bolts span BOTH ring halves, so no lugs are needed!

// --- Existing printed part dimensions ---
existing_flange_od = 106;     // Flange tube OD
existing_lip_od = 110;        // Retention lip OD
existing_lip_length = 5;      // Lip axial length
existing_flange_length = 35;  // Total flange length (ghost only)

// --- General ---
clearance = 0.4;
wall = 3;

// --- Capture Ring ---
ring_body_width = 12;         // Radial wall thickness
ring_depth = 12;              // Total axial depth (tuned for 14mm screws)
groove_depth = 6;             // Groove depth for the lip

// --- Adapter Sleeve ---
duct_diameter = 100;
duct_fit_clearance = 3;       // Tube = 97mm, slides easily into 100mm duct
sleeve_length = 40;
sleeve_wall = 3;
sleeve_flange = 5;            // Flange plate thickness (must be > screw_head_depth)

// --- Thread on sleeve tube (for screwing the duct on) ---
thread_pitch = 12;            // Matches spacing between duct wire guides
thread_ridge_height = 1.5;    // Ridge OD = 97 + 2*1.5 = 100mm, matches duct ID exactly
thread_turns = 3;             // Number of spiral turns
thread_width = 6;             // Cross-section width of the ridge (leaves 6mm gap in 12mm pitch)

// --- Hardware ---
bolt_hole_diameter = 3.5;
insert_diameter = 4.16;
insert_depth = 5;
screw_head_diameter = 5.3;
screw_head_depth = 3;
num_sleeve_bolts = 6;         // MUST be even so bolts are symmetric on both halves

$fn = 100;

// --- Calculated Dimensions ---
ring_back_id = existing_flange_od + clearance;
ring_front_id = existing_lip_od + clearance;
ring_od = ring_front_id + 2 * ring_body_width;

sleeve_od = duct_diameter - duct_fit_clearance;
sleeve_id = sleeve_od - 2 * sleeve_wall;
// Bolt circle sits in the middle of the ring wall
sleeve_bolt_circle_r = (ring_front_id + ring_od) / 4; // radius, not diameter

// --- Display Mode ---
show_assembled = false;        // true = verify fit, false = print layout

if (show_assembled) {
    // Ghost of the existing flange (transparent reference)
    %ghost_flange();

    // Ring halves: assembled behind the lip
    translate([0, 0, -(ring_depth - groove_depth)]) {
        capture_ring_half();
        mirror([1, 0, 0]) capture_ring_half();
    }

    // Sleeve: bolts onto the ring front face
    translate([0, 0, groove_depth])
        adapter_sleeve();

} else {
    // Print layout
    translate([0, ring_od/2 + 10, 0]) capture_ring_half();
    translate([0, -(ring_od/2 + 10), 0]) mirror([0, 1, 0]) capture_ring_half();
    translate([ring_od + 30, 0, 0]) adapter_sleeve();
}


// ==========================================
// MODULES
// ==========================================

// One half of the capture ring (semicircle, X+ side)
module capture_ring_half() {
    difference() {
        union() {
            // Back section: narrower bore, hooks behind the lip
            half_ring(ring_back_id, ring_od, ring_depth - groove_depth);

            // Front section: wider bore, accommodates the lip
            translate([0, 0, ring_depth - groove_depth])
                half_ring(ring_front_id, ring_od, groove_depth);
        }

        // Sleeve bolt holes through the ring body.
        // Inserts on BACK face (Z=0), clearance from insert to front.
        for (i = [0 : num_sleeve_bolts - 1]) {
            angle = i * (360 / num_sleeve_bolts);
            bx = sleeve_bolt_circle_r * cos(angle);
            by = sleeve_bolt_circle_r * sin(angle);
            if (bx > 0.1) {
                // Insert hole on back face (Z=0)
                translate([bx, by, -0.1])
                    cylinder(d = insert_diameter, h = insert_depth + 0.1);
                // Clearance hole from insert to front face
                translate([bx, by, insert_depth])
                    cylinder(d = bolt_hole_diameter, h = ring_depth - insert_depth + 0.1);
            }
        }
    }
}

// Helper: a semicircular ring (X+ half only)
module half_ring(id, od, h) {
    difference() {
        cylinder(d = od, h = h);
        translate([0, 0, -0.1])
            cylinder(d = id, h = h + 0.2);
        // Remove X- half
        translate([-od, -od/2, -0.1])
            cube([od, od, h + 0.2]);
    }
}

// Adapter sleeve: flange + threaded tube. Bolts hold ring halves together.
module adapter_sleeve() {
    difference() {
        union() {
            // Flange plate (spans both ring halves)
            cylinder(d = ring_od, h = sleeve_flange);

            // Tube for flex duct
            translate([0, 0, sleeve_flange])
                cylinder(d = sleeve_od, h = sleeve_length);

            // Spiral thread on the tube (duct screws on by twisting)
            translate([0, 0, sleeve_flange])
                spiral_thread(sleeve_od, thread_pitch, thread_ridge_height, thread_width, thread_turns);
        }

        // Hollow centre
        translate([0, 0, -0.1])
            cylinder(d = sleeve_id, h = sleeve_flange + sleeve_length + 0.2);

        // Bolt holes (clearance + counterbore)
        for (i = [0 : num_sleeve_bolts - 1]) {
            angle = i * (360 / num_sleeve_bolts);
            translate([sleeve_bolt_circle_r * cos(angle), sleeve_bolt_circle_r * sin(angle), 0]) {
                // Clearance hole
                translate([0, 0, -0.1])
                    cylinder(d = bolt_hole_diameter, h = sleeve_flange + 0.2);
                // Counterbore for screw head (on the outer face)
                translate([0, 0, sleeve_flange - screw_head_depth])
                    cylinder(d = screw_head_diameter, h = screw_head_depth + 0.1);
            }
        }
    }
}

// Ghost of the existing printed flange (transparent reference)
module ghost_flange() {
    flange_bore = existing_flange_od - 2 * 3;
    difference() {
        union() {
            translate([0, 0, -existing_flange_length + existing_lip_length])
                cylinder(d = existing_flange_od, h = existing_flange_length);
            cylinder(d = existing_lip_od, h = existing_lip_length);
        }
        translate([0, 0, -existing_flange_length + existing_lip_length - 0.1])
            cylinder(d = flange_bore, h = existing_flange_length + 0.2);
    }
}

// Spiral thread ridge on a tube surface.
// Creates a helical ridge that the flex duct grips when twisted on.
// Thread direction: LEFT-HAND (matches duct wire direction)
module spiral_thread(tube_od, pitch, ridge_h, ridge_w, turns) {
    thread_length = turns * pitch;
    segments_per_turn = 36;
    total_segments = turns * segments_per_turn;
    
    for (i = [0 : total_segments - 1]) {
        angle1 = -(i * 360 / segments_per_turn);
        angle2 = -((i + 1) * 360 / segments_per_turn);
        z1 = i * pitch / segments_per_turn;
        z2 = (i + 1) * pitch / segments_per_turn;
        r = tube_od / 2 + ridge_h / 2;
        
        hull() {
            translate([r * cos(angle1), r * sin(angle1), z1])
                sphere(d = ridge_w, $fn = 12);
            translate([r * cos(angle2), r * sin(angle2), z2])
                sphere(d = ridge_w, $fn = 12);
        }
    }
}
