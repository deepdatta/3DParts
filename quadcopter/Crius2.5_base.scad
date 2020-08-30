use <stickHolder.scad>

base_h = 2;
base_wall_h = 6;
base_wall_t = 2;
board_l = 40 + 0.2;
board_wall_gap = 1;

stick_d        = 3.6;
stick_holder_t = 2;
stick_holder_l = 10;

$fn=100;

module board_base() {
    l = board_l + board_wall_gap*2;
    wall_l = l + base_wall_t;
    
    difference() {
        union() {
            translate([-wall_l/2,-wall_l/2]) cube([wall_l, wall_l, base_h + base_wall_h]);
            
            stick_offset = l/2-1;
            for (i = [[-1, -1, 135], [-1, 1, 45], [1, -1, -135], [1, 1, -45]]) {
                translate([i[0]*stick_offset, i[1]*stick_offset]) 
                    stickHolder2(stick_d, stick_holder_l, stick_holder_t,
                                 z_rot=i[2], slot=0.5, riser=0.2);
                //stick_holder(i[0]*stick_offset, i[1]*stick_offset, i[2]);
            }
        }
        translate([-l/2,-l/2,base_h]) cube([l, l,base_wall_h+1]);
    }
    
    //Corner Standoffs
    s1_l = 6;
    s1_h = 2.25;
    for(x=[-1,1], y=[-1,1]) {
        translate([x*(l-s1_l)/2,y*(l-s1_l)/2,base_h + s1_h/2]) {
            cube([s1_l,s1_l, s1_h],center=true);
            //cylinder(d=3.5, h=2);
        }
    }
}

module corner_holes() {
    hole_offset = 2.5;
    for(x=[-1,1], y=[-1,1]) {
        offset = board_l/2 - hole_offset;
        translate([x * offset, y * offset, -0.01]) cylinder(d=2.5, h=base_wall_h);
    }
}

module battery_strap_holes() {
    l = 8;
    w = 1.5;
    h = base_h + 1;
    
    module 1hole(w, l, h) {
        translate([-w/2, -l/2]) {
            cube([w,l,h]);
            for (y=[0, l]) {
                translate([w/2,y]) cylinder(d=w, h=h); 
            }
        }
    }
    for (x=[8, -8]) {
        translate([x, 0]) 1hole(w, l, h);
        translate([0, x]) rotate([0,0,90]) 1hole(w, l, h);
    }
}

module frame() {
    difference() {
        board_base();
        {
            corner_holes();
            translate([0,0,-0.1]) battery_strap_holes();
        }
    }
}

frame();
//tryout();

module tryout() {
    x = 15;
    y = 100;
    intersection() {
        frame();
        rotate([0,0,45]) translate([-x/2, -y/2]) cube([x, y, 100]);
    }
}