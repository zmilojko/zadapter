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

module hose_plug(
            h=25,
            screw_extra=0.7
        ) {
    color("red") cylinder(h=h, d=INNER_D);
    color("blue") spherical_thread(
        cyl_r = INNER_D/2,          // radius of the helical path
        cyl_h = h,          // total height
        turns = 2,           // number of turns
        trace_r = 1.5,       // radius of the trace tube

        steps = 100,            // how smooth the spiral is
        thread_sphere_fn = 16   // sphere smoothness
    );
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

//Following is made by ChatGPT. It works, but it renders suoperslow if smooth.
// Smoothness is defined by two parameters and both are set low for development but
// should be increased when generating output.
module spherical_thread(
    cyl_r = 20,          // radius of the helical path
    cyl_h = 80,          // total height
    turns = 4,           // number of turns
    trace_r = 1.5,       // radius of the trace tube

    steps = 100,            // how smooth the spiral is
    thread_sphere_fn = 16   // sphere smoothness
) {
    for (i = [0:steps]) {
        t = i / steps;                   // 0 -> 1
        angle = t * turns * 360;         // rotation around cylinder
        z = t * cyl_h;                   // height
        x = cyl_r * cos(angle);
        y = cyl_r * sin(angle);

        // Trace
        translate([x, y, z])
            sphere(r=trace_r, $fn = thread_sphere_fn);

        angle2 = t * turns * 360 + 180;         // rotation around cylinder
        z = t * cyl_h;                   // height
        x2 = cyl_r * cos(angle2);
        y2 = cyl_r * sin(angle2);

        translate([x2, y2, z])
            sphere(r=trace_r, $fn = thread_sphere_fn);
    }
}

module probing_cylindar(extra_h=0, extra_diameter=0) {
    difference() {
        cylinder(h=20+extra_h, d=20+extra_diameter, center=false);
        translate([0,0,-eps]) cylinder(h=20+extra_h+2*eps, d=18+extra_diameter, center=false);
    }
}

//main body showing what is being printed();

hose_plug();

//translate([0,0,25+eps]) color("transparent") male_connector();
//color("transparent") female_connector();
