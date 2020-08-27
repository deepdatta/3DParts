motor_d = 8;
motor_l = 20;

ring_wall_t = 2;
ring_h      = 4.5;
ring2_h     = 6;
base_beam_h = 1.4;

slot   = 0.5;

stick_d = 3.6;
stick_holder_t = 1.5;
$fn=50;

module motor() {
    translate([0,0,-0.01]) color("red", 0.25) cylinder(d=motor_d, h=motor_l);
    translate([0,0,motor_l]) {
        color("grey", 0.25) cylinder(d=1, h=5);
        color("orange", "0.25") cylinder(d=3, h=0.5);
    }
}

module base_ring() {
    d = motor_d + ring_wall_t;
    difference() {
        cylinder(d=d, h=ring_h);
        {
            motor();
            rotate([0,0,180]) 
                translate([-slot/2,0,-0.01]) cube([slot,d,ring_h + 0.01]);
        }
    }
}

module top_ring() {
    d = motor_d + ring_wall_t/2;
    neck_h = ring2_h/4;
    h      = ring2_h - neck_h;
    
    difference() {
        translate([0,0,ring_h]) {
            difference() {
                union() {
                    cylinder(d1=motor_d + ring_wall_t, d2=d, h=neck_h);
                    translate([0,0,neck_h]) cylinder(d=d, h=h);
                }
                for (s = [[60, h], [-60, h], [-180, ring2_h]]) {
                    rotate([0,0,s[0]]) 
                        translate([-slot/2,0,ring2_h-s[1]])
                            cube([slot,d,s[1]+0.01]);
                }
            }
        }
        motor();
    }   
}

module base_beam() {
    base_beam_y = 3;
    base_beam_x = motor_d/2.5;
    x_off = (motor_d+ring_wall_t)/2 - 0.5;
    for(x=[-x_off, x_off-base_beam_x]) {
        translate([x, -base_beam_y/2, 0]) 
            cube([base_beam_x, base_beam_y, base_beam_h]);
    }
}

module stick_holder(y_shift) {
    holder_l = 8;
    slot_l = 3;
    slot_width = 0.5;
    d = stick_d+stick_holder_t;
    riser = 0.5;
    
    translate([0,(motor_d+ring_wall_t)/2-y_shift,d/2+riser])
    rotate([-90,0,0])
    difference() {
        union() {
            cylinder(d=d, h=holder_l);
            translate([0,(stick_d+stick_holder_t/2+riser)/2,holder_l/2])
                cube([slot_width*4, riser+stick_holder_t/2, holder_l], center=true);
        }
        union() {
            cylinder(d=stick_d, h=holder_l+0.01);
            translate([0,0,holder_l-slot_l/2])
                cube([slot_width, d+riser+1, slot_l+1], center=true);
        }
    }
}

module c_clip1() {
    h = 2;
    t = 2;
    d = motor_d + ring_wall_t;
    slot_x = stick_d + stick_holder_t + 2;
    difference() {
        cylinder(d=d + t, h=h);
        translate([0,0, -0.01]) {
            cylinder(d=d, h=h+0.1);
            translate([-slot_x/2,0,0]) cube([slot_x, d, h +0.1]);
        }
    }
}

module holder() {
    translate([0,0,-base_beam_h]) {
        base_ring();
        top_ring();
        base_beam();
        stick_holder(0.8);
    }
 }

% motor();
holder();
translate([0, - motor_d*1.2, 0]) c_clip1();