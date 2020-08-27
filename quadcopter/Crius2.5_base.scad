base_h = 2;
base_wall_h = 6;
base_wall_t = 2;
board_l = 40 + 0.2;

stick_d        = 3.6;
stick_holder_t = 2;
stick_holder_l = 10;

$fn=100;

module board_base() {
    l = board_l;
    wall_l = l + base_wall_t;
    
    difference() {
        union() {
            translate([-wall_l/2,-wall_l/2]) cube([wall_l, wall_l, base_h + base_wall_h]);
            
            stick_offset = board_l/2-1;
            for (i = [[-1, -1, 135], [-1, 1, 45], [1, -1, -135], [1, 1, -45]]) {
                stick_holder(i[0]*stick_offset, i[1]*stick_offset, i[2]);
            }
        }
        translate([-l/2,-l/2,base_h]) cube([l, l,base_wall_h+1]);
    }
    
    //Corner Standoffs
    s1_l = 5;
    s1_h = 2;
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
        translate([x * offset, y * offset, -0.01]) cylinder(d=2.6, h=base_wall_h);
    }
}

module battery_strap_holes() {
    bh_x = 10;
    bh_y = 1;
    bh_z = base_h + 0.02;
    for (y=[5, -5]) {
        translate([0,y,base_h/2]) {
            cube([bh_x, bh_y, bh_z], center=true);
            translate([-bh_x/2,0,0]) cylinder(d=bh_y, h=bh_z, center=true);
            translate([bh_x/2,0,0]) cylinder(d=bh_y, h=bh_z, center=true);
        }
    }
}

module stick_holder(x_off=0, y_off=0, z_rot=0) {
    holder_l = stick_holder_l;
    slot_l = 3;
    slot_width = 0.5;
    d = stick_d+stick_holder_t;
    riser = 0.5;
    
    translate([x_off, y_off, d/2+riser])
    rotate([-90,0,z_rot])
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

module frame() {
    difference() {
        board_base();
        {
            corner_holes();
            battery_strap_holes();
        }
    }
    
    
}

frame();