use <../libs/hexagon_lattice.scad>

//translate([0,-60]) import(file="micro105-bottom-v4-bottom-battery.stl");

mm_radius = 60;  //motor mount radius
motor_d   = 7;
motor_mount_t = 1.5; //motor mount thickness
board_ll = 40;  // Actual board length
board_l  = board_ll + 2; // Size of baseplate

module tube(od, id, h=1, $fn=50) {
    difference() {
        cylinder(d=od, h=h);
        translate([0,0,-1]) cylinder(d=id, h=2*h);
    }
}

module motorMount(d=7, h=8, thickness=1.5, zrot=45) {
    base_beam_h = 1.2;
    base_beam_w = 1.5;
    slot_w      = 2;
    od = d+thickness*2;
 
    $fn=50;
    rotate([0,0,zrot])
    difference() {
        cylinder(d=od, h=h);
        translate([0,0,base_beam_h]) cylinder(d=d, h=h);
        intersection() {
            translate([0,0,-1]) cylinder(d=d, h=h);
            cube([od, d-base_beam_w*2, h], center=true);
        }
        translate([-(od+1)/2, -slot_w/2, -1]) cube([thickness+1, slot_w, h+2]);
    }
}

module board_mount(h=3) {
    edge_t = 3;
    lattice_t = 1.5;   //Thickness of the hexagonal lattice
    hole_offset = 2.5; //distance of hole from edge;
    hole_d = 2.5;
    batt_gap = 20;
    batt_l   = 8;
    batt_w   = 1.5;
    
    lattice_l = board_l-edge_t;
    
    module edge() {
        translate([0,0,h/2])
            difference() {
                cube([board_l, board_l, h], center=true);
                cube([lattice_l, lattice_l, 2*h], center=true);
            }
    }
         
    module lattice() {
        translate([0,0,lattice_t/2])
            difference() {
                cube([board_l, board_l, lattice_t], center=true);
                translate([0,-1.9])
                    hexagon_lattice(7, 12, zh=2*h, side=3.5, 
                                    gap=1.5, center=true);
            }
    }
    
    module standoffs() {
        sl=6;
        sh=lattice_t + 2.5;
        offset = board_ll/2 - hole_offset;
        for(x=[-1,1], y=[-1,1]) {
            translate([x * offset, y * offset]) 
                cylinder(d=sl, h=sh, $fn=50);
        }
    }
    
    module battery_strap_hole(l, w, h) {
        translate([-w/2, -l/2]) {
            cube([w,l,h]);
            for (y=[0, l]) {
                translate([w/2,y]) cylinder(d=w, h=h, $fn=25); 
            }
        }
    }
    
    module corner_holes() {
        $fn=25;
        offset = board_ll/2 - hole_offset;
        for(x=[-1,1], y=[-1,1]) {
            translate([x * offset, y * offset, -0.1]) 
                cylinder(d=hole_d, h=h+5);
        }
    }
    
    difference() {
        union() {
            edge();
            lattice();
            standoffs();
            for (x=[1, -1]) {
                translate([x*batt_gap/2, 0]) {
                    battery_strap_hole(batt_l+1, batt_w+2.5, lattice_t);
                    for (y=[1,-1]) {
                        pinx=3; piny=2;
                        translate([-batt_w+x*pinx, y*(batt_l/2)-piny/2])
                            cube([pinx, piny, lattice_t]);
                    }
                }
            }
        }
        
        corner_holes();
        for (x=[batt_gap/2, -batt_gap/2]) {
            translate([x, 0, -1]) battery_strap_hole(batt_l, batt_w, h+2);
        }
    }
}

module arms(h=3) {
    $fn=50;
    r=mm_radius-16; 
    w=2.8;
    clip_d=w*2;
    rib_d = motor_d + 2*motor_mount_t + 2.5;
    mm_rad_x = cos(45)*mm_radius;
    mm_rad_y = sin(45)*mm_radius;
    
    module wire_clip(h=1.5) {
        translate([clip_d/4,0]) rotate([0,90,-90]) difference() {
            tube(od=clip_d, id=clip_d-1.5, h=h);
            translate([0,-clip_d/2,-0.5])cube([clip_d, clip_d, h+2]);
            translate([-clip_d/2,0,-0.5])cube([clip_d, clip_d, h+2]);
        }
    }
    module arm1(clip=false) {
        x_off = -19.5;
        difference() {
            translate([-r+x_off,0]) {
                tube(od=2*r, id=2*(r-w), h=h, $fn=150);
                if (clip) {
                    aa=10; ao=2;
                    for(a=[[aa, 0], [aa+ao, 180],
                           [-aa, 180], [-aa-ao, 0]]) {
                        rotate([0,0,a[0]]) 
                            translate([r-w+clip_d/4,0,h])
                                rotate([0,0,a[1]]) wire_clip();
                    }
                }
            }
            
            //Cut to motor mount
            translate([-(mm_rad_x+2*r)-motor_d/2,-r, -1])
                cube([2*r, 2*r, h+2]);
        }
        
        //Rib around motorMount
        translate([-mm_rad_x, mm_rad_y]) rotate([0,0,-45])
        difference() {
            cylinder(d=rib_d, h=h);
            translate([rib_d/5, -rib_d/2, -1]) cube([rib_d, rib_d, h+2]);
        }
        
    }
    
    difference() {
        union() {
            for(a=[0:90:270]) {
                echo(a);
                rotate([0,0,a]) arm1(clip=(a%180 == 0));
            }
        }
        for (a=[45:90:360]) {
            translate([cos(a)*mm_radius, sin(a)*mm_radius, -1])
                cylinder(d=motor_d, h=h+2);
        }
    }
}

module criusFrame() {
    
    
    board_mount(h=3);
    arms(3);
    
    for (a=[45, -45, 135, -135]) {
        translate([cos(a)*mm_radius, sin(a)*mm_radius])
            motorMount(d=motor_d, thickness=motor_mount_t, zrot=a);
    }
}   

criusFrame();

//o=20;translate([-o,o]) rotate([0,0,45]) color("blue") cube([2, 30, 5]);
