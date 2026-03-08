// Duct Reducer - 4" to 2-1/2"
// Replica of Powertec 70136 style reducer.
// Both ends slide inside the ducting.

// Dimensions (mm)
// Small end (2-1/2" duct)
small_od = 63.1;              // 2 31/64" OD
small_id = 58.7;              // 2 5/16" ID
small_tube_length = 34.9;     // 1 3/8"

// Large end (4" duct)
large_od = 100.4;             // 3 61/64" OD
large_id = 93.3;              // 3 43/64" ID
large_tube_length = 50.0;     // 1 31/32"

// Overall
total_height = 113.5;         // 4 15/32"

// Wall thickness (derived from dimensions)
wall = (small_od - small_id) / 2;  // ~2.2mm

// Calculated
cone_height = total_height - small_tube_length - large_tube_length;

// Lip/step at each end (prevents duct from sliding too far)
lip_height = 3;
lip_extra = 2;                // How much the lip extends beyond the tube OD

$fn = 100;

// Build the reducer
module duct_reducer() {
    difference() {
    union() {
        // Large tube (bottom)
        cylinder(d = large_od, h = large_tube_length);
        
        // Lip/step at large tube/cone junction (duct stop)
        translate([0, 0, large_tube_length - lip_height])
            cylinder(d = large_od + 2 * lip_extra, h = lip_height);
        
        // Conical transition
        translate([0, 0, large_tube_length])
            cylinder(d1 = large_od, d2 = small_od, h = cone_height);
        
        // Small tube (top)
        translate([0, 0, large_tube_length + cone_height])
            cylinder(d = small_od, h = small_tube_length);
    }
    
    // Hollow out the inside 
    // Large bore
    translate([0, 0, -1])
        cylinder(d = large_id, h = large_tube_length + 2);
    
    // Conical bore
    translate([0, 0, large_tube_length - 0.1])
        cylinder(d1 = large_id, d2 = small_id, h = cone_height + 0.2);
    
    // Small bore
    translate([0, 0, large_tube_length + cone_height - 0.1])
        cylinder(d = small_id, h = small_tube_length + 2);
    }
}

duct_reducer();
