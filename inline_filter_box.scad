// Inline Solder Fume Filter Box
// Designed for a Bosch R2543 or MANN-FILTER FP 21 000-2 Cabin Air Filter and 4-inch (100mm) ducting.
// Features a two-part clamshell design (main body and lid) with a lofted transition.

// Filter dimensions
filter_length = 158; 
filter_width = 150; 
filter_thickness = 32; 

// Duct parameters
duct_diameter = 100;
duct_attachment = "outside";  // Options: "outside" (slides OVER print) or "inside" (slides INTO print)
duct_clearance = 0.5;         // Tolerance to ensure the duct fits easily
wall_thickness = 3;

// Flange parameters
flange_length = 35;           // Protruding cylindrical flange length
lip_thickness = 2;            // Additional radius for duct clamp retention lip
lip_length = 5;               // Length of the retention lip at the end of the flange
ledge_width = 2;              // 2mm internal ledge for the filter to rest against

// Transition parameters
transition_length = 80;       // Length of the funnel-shaped smooth transition
bolt_flange_width = 15;       // Width of the rim for bolting the main body to the lid
bolt_hole_diameter = 3.5;     // Diameter for M3 screws and nuts to clamp the clamshell
insert_diameter = 4.16;       // Diameter of the hole for M3 brass-threaded inserts (heat-set)
insert_depth = 5;             // Depth of the threaded insert
screw_head_diameter = 5.3;    // Diameter of the cylindrical recess for a socket head cap screw
screw_head_depth = 3;         // Depth of the screw head recess
flange_thickness = 8;         // Flange thickness required to safely sink the screws and inserts

// Display mode
show_assembled = false;       // true = assembled view, false = print layout

// Printability parameters
split_for_printing = false;   // Set to true to cut the model securely into interlocking halves
puzzle_tolerance = 0.2;       // Clearance for the puzzle joints

$fn = 100; // High resolution for cylindrical/smooth features

// Top Level Assembly
// If show_assembled=true, the lid is placed on top of the main body.
// If split_for_printing=true, each part is split into interlocking halves.

if (show_assembled) {
    // Assembled view
    build_main_body();
    translate([0, 0, filter_thickness + wall_thickness])
        build_lid();

} else if (split_for_printing) {
    // Offset distances for laying out parts
    offset_y = filter_width/2 + 20;
    offset_x = filter_length + 20;

    // Body halves
    translate([0, offset_y, 0]) 
        intersection() { puzzle_mask("left"); build_main_body(); }
        
    translate([0, -offset_y, 0]) 
        intersection() { puzzle_mask("right"); build_main_body(); }
    
    // Lid halves
    translate([offset_x, offset_y, 0]) 
        intersection() { puzzle_mask("left"); build_lid(); }
        
    translate([offset_x, -offset_y, 0]) 
        intersection() { puzzle_mask("right"); build_lid(); }
        
} else {
    // Generate undivided models side by side
    translate([0, 0, 0]) build_main_body();
    translate([filter_length + 20, 0, 0]) build_lid();
}


// Modules

module build_main_body() {
    // Calculate flange diameters based on attachment mode
    f_od = (duct_attachment == "outside") ? (duct_diameter - duct_clearance) : (duct_diameter + duct_clearance + 2 * wall_thickness);
    f_id = (duct_attachment == "outside") ? (f_od - 2 * wall_thickness) : (duct_diameter + duct_clearance);

    difference() {
        union() {
            // Main shell
            translate([-filter_length/2 - wall_thickness, -filter_width/2 - wall_thickness, 0])
                cube([filter_length + 2 * wall_thickness, filter_width + 2 * wall_thickness, filter_thickness + wall_thickness]);
            
            // Flange
            translate([-filter_length/2 - bolt_flange_width, -filter_width/2 - bolt_flange_width, filter_thickness + wall_thickness - flange_thickness])
                cube([filter_length + 2 * bolt_flange_width, filter_width + 2 * bolt_flange_width, flange_thickness]);
            
            // Transition
            translate([0, 0, 0]) rotate([180, 0, 0])
                funnel_hull(
                    rect_l = filter_length + 2 * wall_thickness, 
                    rect_w = filter_width + 2 * wall_thickness, 
                    circle_d = f_od,
                    height = transition_length
                );
                
            // Duct
            translate([0, 0, -transition_length - flange_length])
                cylinder(d = f_od, h = flange_length);
                
            // Lip
            if (duct_attachment == "outside") {
                translate([0, 0, -transition_length - flange_length])
                    cylinder(d = f_od + 2 * lip_thickness, h = lip_length);
            }
        }
        
        // Internal cavities
        
        // Filter slot
        translate([-filter_length/2, -filter_width/2, wall_thickness])
            cube([filter_length, filter_width, filter_thickness + 1]);
            
        // Internal transition
        translate([0, 0, wall_thickness + 0.01]) rotate([180, 0, 0])
            funnel_hull(
                rect_l = filter_length - 2 * ledge_width, 
                rect_w = filter_width - 2 * ledge_width, 
                circle_d = f_id,
                height = transition_length + wall_thickness + 0.02
            );
            
        // Duct passage
        translate([0, 0, -transition_length - flange_length - 0.1])
            cylinder(d = f_id, h = flange_length + 0.2);
            
        // Bolt holes
        generate_bolt_holes(
            z_pos = filter_thickness + wall_thickness - flange_thickness - 1, 
            depth = flange_thickness + 2, 
            with_insert_trap = true, 
            insert_z = filter_thickness + wall_thickness - flange_thickness - 0.1
        );
    }
}

module build_lid() {
    // Calculate flange diameters based on attachment mode
    f_od = (duct_attachment == "outside") ? (duct_diameter - duct_clearance) : (duct_diameter + duct_clearance + 2 * wall_thickness);
    f_id = (duct_attachment == "outside") ? (f_od - 2 * wall_thickness) : (duct_diameter + duct_clearance);

    difference() {
        union() {
            // Flange
            translate([-filter_length/2 - bolt_flange_width, -filter_width/2 - bolt_flange_width, 0])
                cube([filter_length + 2 * bolt_flange_width, filter_width + 2 * bolt_flange_width, flange_thickness]);
            
            // Transition
            translate([0, 0, wall_thickness])
                funnel_hull(
                    rect_l = filter_length + 2 * wall_thickness, 
                    rect_w = filter_width + 2 * wall_thickness, 
                    circle_d = f_od,
                    height = transition_length
                );
                
            // Duct
            translate([0, 0, wall_thickness + transition_length])
                cylinder(d = f_od, h = flange_length);
                
            // Lip
            if (duct_attachment == "outside") {
                translate([0, 0, wall_thickness + transition_length + flange_length - lip_length])
                    cylinder(d = f_od + 2 * lip_thickness, h = lip_length);
            }
        }
        
        // Internal cavities
        
        // Internal transition
        translate([0, 0, -0.01])
            funnel_hull(
                rect_l = filter_length, 
                rect_w = filter_width, 
                circle_d = f_id,
                height = transition_length + wall_thickness + 0.02
            );
            
        // Duct passage
        translate([0, 0, wall_thickness + transition_length - 0.1])
            cylinder(d = f_id, h = flange_length + 0.2);
            
        // Bolt holes
        generate_bolt_holes(
            z_pos = -0.5, 
            depth = flange_thickness + 1, 
            with_screw_trap = true, 
            screw_z = flange_thickness - screw_head_depth
        );
    }
}

// Helper Modules

module funnel_hull(rect_l, rect_w, circle_d, height) {
    hull() {
        // Base rectangular profile centered on Z=0
        translate([-rect_l/2, -rect_w/2, 0])
            cube([rect_l, rect_w, 0.01]);
            
        // Top circular profile at Z=height
        translate([0, 0, height - 0.01])
            cylinder(d = circle_d, h = 0.01);
    }
}

module generate_bolt_holes(z_pos, depth, with_insert_trap = false, insert_z = 0, with_screw_trap = false, screw_z = 0) {
    offset_x = filter_length/2 + bolt_flange_width/2;
    offset_y = filter_width/2 + bolt_flange_width/2;
    
    // Define 8 hole positions around the flange
    hole_positions = [
        [ offset_x,  offset_y],  // Corners
        [-offset_x,  offset_y],
        [ offset_x, -offset_y],
        [-offset_x, -offset_y],
        [ offset_x,  0],         // Mid-points on length
        [-offset_x,  0],
        [ 0,  offset_y],         // Mid-points on width
        [ 0, -offset_y]
    ];
    
    for (pos = hole_positions) {
        // The clearance hole for the screw shaft
        translate([pos[0], pos[1], z_pos])
            cylinder(d = bolt_hole_diameter, h = depth);
            
        // Cylindrical hole to melt in the threaded insert (only if requested)
        if (with_insert_trap) {
            translate([pos[0], pos[1], insert_z])
                cylinder(d = insert_diameter, h = insert_depth + 0.5);
        }
        
        // Cylindrical recess to sink the socket head cap screw (only if requested)
        if (with_screw_trap) {
            translate([pos[0], pos[1], screw_z])
                cylinder(d = screw_head_diameter, h = screw_head_depth + 1);
        }
    }
}

module puzzle_mask(side) {
    size = 1000;         // Defines bounding box large enough to encase half the model
    tooth_size = 40;     // Y-axis period of the dovetail
    neck = 10;           // Narrowest part of the dovetail neck
    bulb = 25;           // Widest part of the dovetail bulb
    depth = 15;          // X-axis penetration of the dovetail
    
    // We construct a continuous polygon traversing up the Y-axis forming dovetail tabs
    base_points = [
        for (y = [-size : tooth_size : size]) 
            each [
                [0, y], 
                [0, y + (tooth_size - neck)/2], 
                [depth, y + (tooth_size - bulb)/2], 
                [depth, y + (tooth_size + bulb)/2], 
                [0, y + (tooth_size + neck)/2]
            ]
    ];
    
    if (side == "right") {
        right_points = concat(base_points, [[size, size], [size, -size]]);
        translate([0, 0, -size/2])
        linear_extrude(height = size)
            offset(delta = -puzzle_tolerance/2) // Shrink slightly to provide fit clearance
            polygon(right_points);
    } else { // "left"
        left_points = concat(base_points, [[-size, size], [-size, -size]]);
        translate([0, 0, -size/2])
        linear_extrude(height = size)
            offset(delta = -puzzle_tolerance/2)
            polygon(left_points);
    }
}
