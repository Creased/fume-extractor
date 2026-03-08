// Rectangular Nozzle - 2-1/2" with safety grid
// Replica of Powertec 70204 rectangular nozzle.
// Fits inside 2-1/2" ducting.

// Dimensions (mm)
// Base tube (2-1/2" duct)
base_od = 62.3;               // ø2 29/64"
base_id = 58.3;               // ø2 19/64"
base_length = 40.1;           // 1 37/64"

// Rectangular opening
rect_width = 150.4;           // 5 63/64"
rect_height = 86.9;           // 3 27/64"

// Overall
total_height = 80.2;          // 3 5/32"
cone_height = total_height - base_length; // 40.1mm

// Shape
wall = (base_od - base_id) / 2; // ~2mm
corner_radius = 5;            // Rounded corners for the rectangle

// Safety grid
grid_bar_w = 2;               // Width/Thickness of grid bars
grid_spacing = 6.5;           // Distance between bar centers (tighter grid)
grid_tolerance = 0.2;         // Clearance for friction fit into the nozzle base
grid_insert_h = 4;            // Height of the grid's outer retention ring
grid_wall = 1.5;              // Thickness of the grid's outer retention ring

$fn = 100;


// Display Options
show_nozzle = true;
show_grid = true;
assemble_parts = false;


// Build
if (show_nozzle) {
    nozzle_body();
}

if (show_grid) {
    if (assemble_parts && show_nozzle) {
        // Position grid inside the nozzle base
        translate([0, 0, base_length - grid_insert_h])
            grid_insert();
    } else {
        // Lay out flat for printing
        translate([show_nozzle ? 80 : 0, 0, 0])
            grid_insert();
    }
}


// Modules

module nozzle_body() {
    difference() {
        union() {
            // Base tube
            cylinder(d = base_od, h = base_length);
            
            // Transition
            translate([0, 0, base_length])
                transition_hull(base_od, rect_width, rect_height, corner_radius, cone_height);
        }
        
        // Hollow out the inside
        translate([0, 0, -0.1]) {
            // Base bore
            cylinder(d = base_id, h = base_length + 0.1);
            
            // Conical hollow
            translate([0, 0, base_length])
                transition_hull(base_id, rect_width - 2*wall, rect_height - 2*wall, max(0.1, corner_radius - wall), cone_height + 0.2);
        }
    }
}

// Transition from a circle to a rounded rectangle
module transition_hull(d1, w2, h2, r2, height) {
    hull() {
        // Bottom: circle
        cylinder(d = d1, h = 0.1);
        
        // Top: rounded rectangle
        translate([0, 0, height - 0.1])
            rounded_rect(w2, h2, r2, 0.1);
    }
}

// Centered rounded rectangle
module rounded_rect(w, h, r, height) {
    w_inner = w - 2*r;
    h_inner = h - 2*r;
    
    linear_extrude(height)
    hull() {
        translate([ w_inner/2,  h_inner/2]) circle(r = r);
        translate([-w_inner/2,  h_inner/2]) circle(r = r);
        translate([ w_inner/2, -h_inner/2]) circle(r = r);
        translate([-w_inner/2, -h_inner/2]) circle(r = r);
    }
}

// Safety grid as a standalone insert (friction-fit into the base tube)
module grid_insert() {
    insert_od = base_id - grid_tolerance;
    insert_id = insert_od - 2 * grid_wall;
    
    num_x = floor(rect_width / grid_spacing);
    num_y = floor(rect_height / grid_spacing);
    
    union() {
        // Outer retention ring
        difference() {
            cylinder(d = insert_od, h = grid_insert_h);
            translate([0, 0, -0.1])
                cylinder(d = insert_id, h = grid_insert_h + 0.2);
        }
        
        // Inner grid bars (using 2D squares extruded to drastically speed up CSG rendering)
        intersection() {
            // Drop bars so their centers are vertically centered in the ring
            translate([0, 0, grid_insert_h / 2 - grid_bar_w / 2])
                linear_extrude(height = grid_bar_w) {
                    // Horizontal bars (along X)
                    for (y = [-num_y/2 - 1 : num_y/2 + 1]) {
                        translate([-rect_width/2 - 10, y * grid_spacing - grid_bar_w/2])
                            square([rect_width + 20, grid_bar_w]);
                    }
                    // Vertical bars (along Y)
                    for (x = [-num_x/2 - 1 : num_x/2 + 1]) {
                        translate([x * grid_spacing - grid_bar_w/2, -rect_height/2 - 10])
                            square([grid_bar_w, rect_height + 20]);
                    }
                }
            
            // Clip the bars perfectly to the inside of the retention ring geometry
            // Plus 1mm on diameter to penetrate the ring by 0.5mm for a strong 3D-printable bond
            translate([0, 0, -10])
                cylinder(d = insert_id + 1, h = 20);
        }
    }
}
