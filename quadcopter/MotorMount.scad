motor_d = 8;
motor_l = 20;

ring_wall_t = 2;
ring_h      = 3;
ring2_h     = 4;
base_beam_h = 1.4;
$fn=50;

module motor() {
    translate([0,0,-0.01]) color("red", 0.25) cylinder(d=motor_d+0.2, h=motor_l);
    translate([0,0,motor_l]) {
        color("grey", 0.25) cylinder(d=1, h=4);
        color("orange", "0.25") cylinder(d=3, h=0.5);
    }
}

module base_ring() {
    difference() {
        cylinder(d=motor_d + ring_wall_t, h=ring_h);
        motor();
    }
}

module top_ring() {
    d = motor_d + ring_wall_t/2;
    neck_h = ring2_h/4;
    h      =  ring2_h - neck_h;
    slot   = 1;
    difference() {
        union() {
            translate([0,0,ring_h]) cylinder(d1=motor_d + ring_wall_t, d2=d, h=neck_h);
            translate([0,0,ring_h+neck_h]) {
                difference() {
                    cylinder(d=d, h=h);
                    translate([0,0,h/2]) {
                        cube([slot,d+0.01,h+0.01], center=true);
                        cube([d+0.01,slot,h+0.01], center=true);
                    }
                }
            }
        }
        motor();
        
    }   
}

module base_beam() {
    base_beam_x = 3;
    base_beam_y = motor_d/2.5;
    y_off = (motor_d+ring_wall_t)/2 - 0.5;
    for(y=[-y_off, y_off-base_beam_y]) {
        translate([-base_beam_x/2, y,0]) 
            cube([base_beam_x, base_beam_y, base_beam_h]);
    }
}

module holder() {
    translate([0,0,-base_beam_h]) {
        base_ring();
        top_ring();
        base_beam();
    }
    
}

% motor();
holder();