// This sets the circles to be circles
$fn = 50;

// this is used to avoid rendering issues for coincident faces
eps = 0.01;

INNER_D = 20.2;
PLUG_DELTA = 0.6; // this is total delta, so on both sides
                  // INNER_D is diameter of the mail plug, while
                  // hole diameter on femail is INNER_D+PLUG_DELTA
                  
HOSE_INNER_D=19.5;

PIN_FROM_TOP_GENERAL = 5.1; // This is for Temu Adapter and kits
PIN_FROM_TOP_BOAT = 6;      // This is for the boat adapter

RUBBER_SEAL_D = 19.2;
RUBBER_SEAL_THICKNESS = 2.55;
RUBBER_SEAL_THICKNESS_PRESSED = 2.25; // This is what we want to use, as we need some pressure
                                      // but not too much so pins don't break

KIINNIKE_HEIGHT=6;

module male_connector(
            h=20,
            ending_cup_height=3,
            pin_extrude_len=3,
            pin_starts_from_top=PIN_FROM_TOP_GENERAL,
            thickness=6
        ) {
    difference() {
        union() {
            // main cylinder
            color("red") cylinder(h=h-ending_cup_height, d=INNER_D);
            // top rounded cup
            color("blue") translate([0,0,h-ending_cup_height-eps]) cylinder(h=ending_cup_height, d1=INNER_D, d2=INNER_D-1);
            // pin bar
            pin_bar(pin_len=INNER_D+2*pin_extrude_len, top_pos=h-pin_starts_from_top);
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
            pin_len_incl_buffer_space=3.7,
            pin_from_top=PIN_FROM_TOP_GENERAL
        ) {
    translate([0,0,h]) rotate([180,0,0]) difference() {
        union() {
            // main cylinder
            color("red") cylinder(h=h-transition_cup_height, d=INNER_D+extra_width*2);
            // rounding cup that makes smooth transition to the other side of the adapter
            color("blue") translate([0,0,h-transition_cup_height-eps]) cylinder(h=transition_cup_height, d1=INNER_D+extra_width*2, d2=INNER_D);
        }
        
        color("yellow") kiinnike(pin_len=INNER_D+2*pin_len_incl_buffer_space);
        
        // main hole
        translate([0,0,-eps]) color("green") cylinder(h=h+2*eps, d=INNER_D-extra_width*2);
        // hole until the seal
        h_until_seal= KIINNIKE_HEIGHT+pin_from_top+RUBBER_SEAL_THICKNESS_PRESSED;
        translate([0,0,-eps]) color("green") cylinder(h=h_until_seal, d=INNER_D+PLUG_DELTA);
        
    }
}

module hose_plug(
            h=45,
            screw_extra=0.7,
            thread_ball_diameter=2,
            thickness=6,
        ) {
    difference() {
        union() {
            color("red") cylinder(h=h-3 , d=HOSE_INNER_D);
            color("blue") translate([0,0,h-3-eps]) cylinder(h=3, d1=HOSE_INNER_D, d2 = HOSE_INNER_D - 3);
            color("blue") translate([0,0,thread_ball_diameter/2]) spherical_thread(
                cyl_r = HOSE_INNER_D/2,          // radius of the helical path
                cyl_h = h-thread_ball_diameter-6,          // total height
                trace_r = thread_ball_diameter/2,       // radius of the trace tube
                steps = 200,            // how smooth the spiral is
                thread_sphere_fn = 12,   // sphere smoothness
                step_height = 6.7
            );
            //plug limiter or base
            color("purple") cylinder(h=4, d2=INNER_D+4, d1=INNER_D);
        }
        color("yellow") translate([0,0,-eps]) cylinder(h=h*2+2*eps, d=HOSE_INNER_D-2*thickness);
    }
}

module flip() {
    rotate([180,0,0]) children();
}

module pin_bar(pin_len=30, pin_d=3.5, top_pos = 0) {
    color("yellow") translate([0, 0, top_pos-pin_d/2+eps]) rotate([0, 90, 0]) cylinder(h=pin_len, d=pin_d, center=true);
}


module kiinnike(
            pin_len=40,
            pin_d=3.65,
            height=KIINNIKE_HEIGHT
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
    trace_r = 1.5,       // radius of the trace tube
    thread_count = 1,
    step_height = 8, // step between threads along the Z axis

    steps = 100,            // how smooth the spiral is
    thread_sphere_fn = 16   // sphere smoothness
) {
    turns=cyl_h/step_height;
    for (i = [0:steps]) {
        t = i / steps; // 0 -> 1
        //z = t * cyl_h;
        
        for (j = [0:thread_count-1]) {
            angle = t * turns * 360+(360/thread_count)*j;         // rotation around cylinder
            z = angle * step_height / 360;
            x = cyl_r * cos(angle);
            y = cyl_r * sin(angle);

            // Trace
            translate([x, y, z])
                sphere(r=trace_r, $fn = thread_sphere_fn);
        }
    }
}

module probing_cylindar(extra_h=0, extra_diameter=0) {
    difference() {
        cylinder(h=20+extra_h, d=20+extra_diameter, center=false);
        translate([0,0,-eps]) cylinder(h=20+extra_h+2*eps, d=18+extra_diameter, center=false);
    }
}

//main body showing what is being printed();
female_connector();
//color("transparent") {
//    
//    flip() hose_plug();
//    //flip() female_connector();
//}
