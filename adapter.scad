$fn = 50;
eps = 0.01;

module inner_cylinder(extra_len=0, extra_diameter=0) {
    color("red") cylinder(h=20+extra_len, d=20+extra_diameter, center=false);
}

module outer_cylinder(extra_len=0, extra_diameter=0) {
    color("red") cylinder(h=20+extra_len, d=26+extra_diameter, center=false);
}

module pin_bar(extra_len=0, height=0) {
    rotate([0, 90, 0]) translate([-height, 0, 0]) cylinder(h=3+3+20+extra_len, d=3.6, center=true);
}

module kiinnike(height=6.45) {
    hull() {
        pin_bar(1, 0);
        pin_bar(1, height-2);
    }
    hull() {
        pin_bar(1, height-2);
        rotate([0,0,10]) pin_bar(1, height);
    }
    hull() {
        rotate([0,0,10]) pin_bar(1, height);
        rotate([0,0,30]) pin_bar(1, height);
    }
    hull() {
        rotate([0,0,30]) pin_bar(1, height);
        rotate([0,0,30]) pin_bar(1, height-0.6);
    }
}



module final() {
  translate([0,0,-36])   difference() {
    union() {
        translate([0,0,18-0.01]) {
            inner_cylinder(-4);
            color("blue") translate([0,0,20-4-0.03]) cylinder(h=4+0.04, d1=20, d2=19, center=false);
            pin_bar(height=12.6);
        }
        outer_cylinder();
        color("blue") translate([0,0,20-0.01]) cylinder(1.8, d1=26, d2=20, center=false);
        
    }
    kiinnike();
    translate([0,0,-1]) inner_cylinder(-6, 1);
    translate([0,0,-1]) inner_cylinder(20, -9);
    
    
    //upper narrowing
    color("yellow") translate([0,0,18+20-4-0.02]) cylinder(h=4+0.05, d1=8, d2=17, center=false);
  }
}

module probing_cylindar(extra_h=0, extra_diameter=0) {
    difference() {
        cylinder(h=20+extra_h, d=20+extra_diameter, center=false);
        translate([0,0,-eps]) cylinder(h=20+extra_h+2*eps, d=18+extra_diameter, center=false);
    }
}

probing_cylindar();
