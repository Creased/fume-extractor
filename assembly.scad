// Full System Assembly
// Visualizes the complete vertical stack from suction nozzle to exhaust.

use <inline_filter_box.scad>
use <duct_adapter_direct.scad>
use <duct_reducer.scad>
use <rectangular_nozzle.scad>

$fn = 60;

// --- Options ---
assemble_all = false; // Set to true to collapse the exploded view

// Geometry Calculations
e = assemble_all ? 0 : 50;

// Filter Box (Anchor)
filter_main_z = 0;
z_filter      = filter_main_z + 3 + e;
lid_z         = filter_main_z + 35 + 2*e;

// Top Stack
top_adapter_ring_z = lid_z + 118 + 3*e;
top_adapter_z      = lid_z + 118 + 4*e;

top_joint_z        = top_adapter_z + 45 + 5*e;
top_coupling_z     = top_joint_z;
fan_z              = top_joint_z + 6*e;

exhaust_z          = fan_z + 260 + 7*e; 
carbon_filter_z    = exhaust_z + 110 + 8*e;

// Bottom Stack
bottom_adapter_ring_z = filter_main_z - 115 - 1*e;
bottom_adapter_z      = filter_main_z - 115 - 2*e;

bottom_joint_z        = bottom_adapter_z - 45 - 3*e;
bottom_coupling_z     = bottom_joint_z;

reducer_z             = bottom_joint_z - 4*e;
reducer_small_z       = reducer_z - 113.5;
top_coupler_z         = reducer_small_z + 45 - 5*e;
hose_top              = top_coupler_z - 52 - 6*e;
hose_length           = 250;
hose_bottom           = hose_top - hose_length;

bottom_coupler_z      = hose_bottom - 52 - 7*e;
nozzle_z              = bottom_coupler_z + 45 - 8*e;


// Carbon Filter
translate([0, 0, carbon_filter_z])
    carbon_filter();


// Exhaust Flex Hose (100mm)
color("DimGray", 0.4) {
    translate([0, 0, exhaust_z])
        flex_hose(d = 103, h = 150, pitch = 8); 
}
translate([0, 0, exhaust_z + 5]) metal_clamp(115);
translate([0, 0, exhaust_z + 150 - 25]) metal_clamp(115);

// Inline Fan
translate([0, 0, fan_z]) 
    vivosun_fan();


// Top Rubber Coupling
translate([0, 0, top_coupling_z]) rubber_coupling();


// Top Adapter
color("DarkSlateGray") {
    translate([0, 0, top_adapter_z]) adapter_sleeve();
    
    translate([0, 0, top_adapter_ring_z]) {
        capture_ring_half();
        mirror([1, 0, 0]) capture_ring_half();
    }
}


// Inline Filter Box
color("Wheat") {
    translate([-158/2, -150/2, z_filter]) 
        cube([158, 150, 32]);
}

color("White", 0.6) {
    translate([0, 0, filter_main_z]) build_main_body(); 
    translate([0, 0, lid_z])         build_lid(); 
}


// Bottom Adapter
color("DarkSlateGray") {
    translate([0, 0, bottom_adapter_z]) rotate([180, 0, 0]) adapter_sleeve();
    
    translate([0, 0, bottom_adapter_ring_z]) rotate([180, 0, 0]) {
        capture_ring_half();
        mirror([1, 0, 0]) capture_ring_half();
    }
}


// Bottom Rubber Coupling
translate([0, 0, bottom_coupling_z]) rubber_coupling();


// Duct Reducer (100mm to 63mm)
color("Black") {
    translate([0, 0, reducer_z])
        rotate([180, 0, 0]) duct_reducer();
}


// Suction Flex Hose (63.1mm)
color("DimGray", 0.4) {
    translate([0, 0, hose_bottom])
        flex_hose(d = 63.6, h = hose_length, pitch = 5); 
}

// Quick Couplers
translate([0, 0, top_coupler_z]) quick_coupler();
translate([0, 0, bottom_coupler_z]) rotate([180, 0, 0]) quick_coupler();


// Rectangular Nozzle
color("DimGray") {
    translate([0, 0, nozzle_z]) rotate([180, 0, 0]) {
        nozzle_body();
        color("Orange")
        translate([0, 0, 40.1 - 4]) grid_insert(); // Insert is positioned relative to base
    }
}


// Helper Modules

module flex_hose(d, h, pitch) {
    loops = floor(h / pitch);
    for (i = [0 : loops - 1]) {
        translate([0, 0, i * pitch])
            rotate_extrude()
            translate([d/2, 0])
                circle(d = pitch * 1.5, $fn = 16);
    }
}

module vivosun_fan() {
    color("Black", 0.85) {
        // Bottom flange
        cylinder(d=100, h=40);
        // Bottom transition
        translate([0,0,40]) cylinder(d1=100, d2=190, h=60);
        // Main body (contains the motor)
        translate([0,0,100]) cylinder(d=190, h=100);
        // Top transition
        translate([0,0,200]) cylinder(d1=190, d2=100, h=60);
        // Top flange
        translate([0,0,260]) cylinder(d=100, h=40);
        
        // Controller/logo box on the side
        color("DarkSlateGray") 
        translate([80, -25, 120]) cube([25, 50, 60]);
    }
}

module carbon_filter() {
    color("DimGray") {
        // Bottom Flange
        cylinder(d=100, h=40);
        // Transition
        translate([0, 0, 40]) cylinder(d1=100, d2=175, h=20);
        // Main perforated body
        color("Silver")
        translate([0, 0, 60]) cylinder(d=175, h=240);
        // Top cap
        translate([0, 0, 300]) cylinder(d=175, h=10);
    }
}

module rubber_coupling() {
    // 100mm ID, ~106mm OD, 60mm height
    translate([0, 0, -30]) { // Center it vertically
        color("#222222") 
        difference() {
            cylinder(d=106, h=60);
            translate([0,0,-1]) cylinder(d=100.2, h=62);
        }
        // Metal bands
        color("Silver") {
            translate([0,0, 10]) difference() { cylinder(d=108, h=10); translate([0,0,-1]) cylinder(d=105, h=12); }
            translate([0,0, 40]) difference() { cylinder(d=108, h=10); translate([0,0,-1]) cylinder(d=105, h=12); }
            // Worm gear housing representations
            translate([53, 0, 15]) rotate([90,0,0]) cube([8, 12, 10], center=true);
            translate([53, 0, 45]) rotate([90,0,0]) cube([8, 12, 10], center=true);
        }
    }
}

module metal_clamp(id=105) {
    color("Silver") {
        difference() { cylinder(d=id+4, h=8); translate([0,0,-0.1]) cylinder(d=id, h=8.2); }
        // Worm gear screw housing
        translate([id/2 + 2, 0, 4]) rotate([90,0,0]) cube([8, 12, 10], center=true);
    }
}

module quick_coupler() {
    color("#111111") {
        // Upper smooth insert (goes into duct_reducer / nozzle)
        translate([0, 0, -45]) cylinder(d=58, h=45);
        
        // Stopper flange
        translate([0, 0, -50]) cylinder(d=75, h=5);
        translate([0, 0, -52]) cylinder(d=67, h=2);
        
        // Lower threaded part (screws onto the hose)
        translate([0, 0, -85]) cylinder(d=67, h=33);
    }
}
