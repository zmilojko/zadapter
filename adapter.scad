// This sets the circles to be circles
$fn = 50;

// this is used to avoid rendering issues for coincident faces
eps = 0.01;

INNER_D = 20.5;

module male_connector(
            h=20,
            ending_cup_height=3,
            pin_extrude_len=3,
            pin_starts_from_rop=6,
            thickness=6
        ) {
    difference() {
        union() {
            // main cylinder
            color("red") cylinder(h=h-ending_cup_height, d=INNER_D);
            // top rounded cup
            color("blue") translate([0,0,h-ending_cup_height-eps]) cylinder(h=ending_cup_height, d1=INNER_D, d2=INNER_D-1);
            // pin bar
            pin_bar(pin_len=INNER_D+2*pin_extrude_len, top_pos=h-pin_starts_from_rop);
        }

        // drill the main hole
        translate([0,0,-eps]) color("green") cylinder(h=h+2*eps, d=INNER_D-thickness*2);

        // two roundings on the top, making continuous curve that can be printed upside down
        translate([0,0,h-2])  color("white") cylinder(h=2, d1=INNER_D-thickness, d2=INNER_D-3);
        translate([0,0,h-4+eps])  color("black") cylinder(h=2, d1=INNER_D-thickness*2, d2=INNER_D-thickness);
    }
}

module female_connector(
            h=30,
            transition_cup_height=5,
            extra_width=6,
            pin_len_incl_buffer_space=3.7
        ) {
    difference() {
        union() {
            // main cylinder
            color("red") cylinder(h=h-transition_cup_height, d=INNER_D+extra_width*2);
            // rounding cup that makes smooth transition to the other side of the adapter
            color("blue") translate([0,0,h-transition_cup_height-eps]) cylinder(h=transition_cup_height, d1=INNER_D+extra_width*2, d2=INNER_D);
        }
        color("yellow") kiinnike(pin_len=INNER_D+2*pin_len_incl_buffer_space);
        translate([0,0,-eps]) color("green") cylinder(h=h+2*eps, d=INNER_D);
        
    }
}

module pin_bar(pin_len=30, pin_d=3.6, top_pos = 0) {
    color("yellow") translate([0, 0, top_pos-pin_d/2+eps]) rotate([0, 90, 0]) cylinder(h=pin_len, d=pin_d, center=true);
}


module kiinnike(
            pin_len=40,
            pin_d=3.65,
            height=6
        ) {
    hull() {
        pin_bar(pin_len=pin_len, pin_d=pin_d, top_pos=pin_d/2);
        pin_bar(pin_len=pin_len, pin_d=pin_d, top_pos=pin_d/2+height-2);
    }
    hull() {
        pin_bar(pin_len=pin_len, pin_d=pin_d, top_pos=pin_d/2+height-2);
        rotate([0,0,10]) pin_bar(pin_len=pin_len, pin_d=pin_d, top_pos=pin_d/2+height);
    }
    hull() {
        rotate([0,0,10]) pin_bar(pin_len=pin_len, pin_d=pin_d, top_pos=pin_d/2+height);
        rotate([0,0,30]) pin_bar(pin_len=pin_len, pin_d=pin_d, top_pos=pin_d/2+height);
    }
    hull() {
        rotate([0,0,30]) pin_bar(pin_len=pin_len, pin_d=pin_d, top_pos=pin_d/2+height);
        rotate([0,0,30]) pin_bar(pin_len=pin_len, pin_d=pin_d, top_pos=pin_d/2+height-0.6);
    }
}

module probing_cylindar(extra_h=0, extra_diameter=0) {
    difference() {
        cylinder(h=20+extra_h, d=20+extra_diameter, center=false);
        translate([0,0,-eps]) cylinder(h=20+extra_h+2*eps, d=18+extra_diameter, center=false);
    }
}

//main body showing what is being printed();
translate([0,0,25+eps]) color("transparent") male_connector();
color("transparent") female_connector();
