// Duct Adapter - Direct Connection (No Thread)
// 3-piece system with a retention lip for direct connection
// to an inline fan or rigid ducting.

// Existing printed part dimensions
existing_flange_od = 106;
existing_lip_od = 110;
existing_lip_length = 5;
existing_flange_length = 35;

// General
clearance = 0.4;
wall = 3;

// Capture Ring
ring_body_width = 12;
ring_depth = 12;
groove_depth = 6;

// Adapter Sleeve
duct_diameter = 100;
duct_fit_clearance = 0.5;     // Slight clearance for easy insertion
sleeve_length = 40;
sleeve_wall = 3;
sleeve_flange = 5;

// Retention lip
sleeve_lip_thickness = 2;
sleeve_lip_length = 5;

// Hardware
bolt_hole_diameter = 3.5;
insert_diameter = 4.16;
insert_depth = 5;
screw_head_diameter = 5.3;
screw_head_depth = 3;
num_sleeve_bolts = 6;

$fn = 100;

// Calculated Dimensions
ring_back_id = existing_flange_od + clearance;
ring_front_id = existing_lip_od + clearance;
ring_od = ring_front_id + 2 * ring_body_width;

sleeve_od = duct_diameter - duct_fit_clearance;
sleeve_id = sleeve_od - 2 * sleeve_wall;
sleeve_bolt_circle_r = (ring_front_id + ring_od) / 4;

// Display Mode
show_assembled = false;

if (show_assembled) {
    %ghost_flange();
    translate([0, 0, -(ring_depth - groove_depth)]) {
        capture_ring_half();
        mirror([1, 0, 0]) capture_ring_half();
    }
    translate([0, 0, groove_depth])
        adapter_sleeve();
} else {
    translate([0, ring_od/2 + 10, 0]) capture_ring_half();
    translate([0, -(ring_od/2 + 10), 0]) mirror([0, 1, 0]) capture_ring_half();
    translate([ring_od + 30, 0, 0]) adapter_sleeve();
}


// Modules

module capture_ring_half() {
    difference() {
        union() {
            half_ring(ring_back_id, ring_od, ring_depth - groove_depth);
            translate([0, 0, ring_depth - groove_depth])
                half_ring(ring_front_id, ring_od, groove_depth);
        }

        for (i = [0 : num_sleeve_bolts - 1]) {
            angle = i * (360 / num_sleeve_bolts);
            bx = sleeve_bolt_circle_r * cos(angle);
            by = sleeve_bolt_circle_r * sin(angle);
            if (bx > 0.1) {
                translate([bx, by, -0.1])
                    cylinder(d = insert_diameter, h = insert_depth + 0.1);
                translate([bx, by, insert_depth])
                    cylinder(d = bolt_hole_diameter, h = ring_depth - insert_depth + 0.1);
            }
        }
    }
}

module half_ring(id, od, h) {
    difference() {
        cylinder(d = od, h = h);
        translate([0, 0, -0.1])
            cylinder(d = id, h = h + 0.2);
        translate([-od, -od/2, -0.1])
            cube([od, od, h + 0.2]);
    }
}

module adapter_sleeve() {
    difference() {
        union() {
            // Flange plate
            cylinder(d = ring_od, h = sleeve_flange);

            // Tube
            translate([0, 0, sleeve_flange])
                cylinder(d = sleeve_od, h = sleeve_length);

            // Retention lip
            translate([0, 0, sleeve_flange + sleeve_length - sleeve_lip_length])
                cylinder(d = sleeve_od + 2 * sleeve_lip_thickness, h = sleeve_lip_length);
        }

        // Hollow centre
        translate([0, 0, -0.1])
            cylinder(d = sleeve_id, h = sleeve_flange + sleeve_length + 0.2);

        // Bolt holes
        for (i = [0 : num_sleeve_bolts - 1]) {
            angle = i * (360 / num_sleeve_bolts);
            translate([sleeve_bolt_circle_r * cos(angle), sleeve_bolt_circle_r * sin(angle), 0]) {
                translate([0, 0, -0.1])
                    cylinder(d = bolt_hole_diameter, h = sleeve_flange + 0.2);
                translate([0, 0, sleeve_flange - screw_head_depth])
                    cylinder(d = screw_head_diameter, h = screw_head_depth + 0.1);
            }
        }
    }
}

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
