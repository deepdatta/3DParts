use <../libs/hexagon_lattice.scad>

//translate([0,-60]) import(file="micro105-bottom-v4-bottom-battery.stl");

mm_radius = 60;  //motor mount radius
motor_d   = 7;
motor_mount_t = 1.5; //motor mount thickness
board_ll = 40;  // Actual board length
board_l  = board_ll + 2; // Size of baseplate

leg_x=0.7;
leg_y=2;

module tube(od, id, h=1, center=false, $fn=50) {
    difference() {
        cylinder(d=od, h=h, center=center);
        translate([0,0,-0.1]) cylinder(d=id, h=h+2, center=center);
    }
}

module motorMount(d=7, h=8, thickness=1.5) {
    base_beam_h = 1.2;
    base_beam_w = 1.5;
    slot_w      = 2;
    od = d+thickness*2;
 
    $fn=50;
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
    
    module plate(side, h, r=3) {
        hull() {
            for(x=[-1,1], y=[-1, 1]) {
                translate([x*(side/2-r), y*(side/2-r)])
                    cylinder(r=r, h=h, $fn=100);
            }
        }
    }
    module edge() {
        difference() {
            plate(board_l, h=h);
            translate([0,0,-1]) plate(lattice_l, h=h+2);
        }
    }
         
    module lattice() {
        difference() {
            plate(board_l, lattice_t);
            translate([0,-1.9])
                hexagon_lattice(7, 12, zh=lattice_t+2, side=3.5, 
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
            for (x=[1, -1]) { // Battery mount
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
    clip_d=w;
    rib_d = motor_d + 2*motor_mount_t + 2.5;
    module wire_clip(h=1.5) {
        clip_w=1;
        rise = 0.5;
        slot=0.8;
        rotate([0,90,-90]) difference() {
            translate([-rise,0,0]) {
                tube(od=clip_d, id=clip_d-clip_w, h=h);
                translate([0, -clip_d/2]) cube([rise,clip_d, h]);
            }
            translate([-rise,-(clip_d-clip_w)/2,-1])
                cube([clip_d, clip_d-clip_w, h+2]);
            translate([-(rise+clip_d/2+1),-slot/2,-1])
                cube([rise+clip_d, slot, h+2]);
            
        }
    }
    module arm1(clip=false) {
        x_off = -19.5;
        intersection() {
            translate([-r+x_off,0]) {
                tube(od=2*r, id=2*(r-w), h=h, $fn=150);
                if (clip) {
                    aa=10; ao=2;
                    for(a=[aa, -aa]) {
                        rotate([0,0,a]) 
                            translate([r-w/2,0,h]) wire_clip();
                    }
                }
            }
            cylinder(r=mm_radius-1, h=4*h, $fn=150);
        }
        
        //Rib around motorMount
        rotate([0,0,45]) translate([-mm_radius, 0]) 
        difference() {
            cylinder(d=rib_d, h=h);
            translate([rib_d/5, -rib_d/2, -1]) cube([rib_d, rib_d, h+2]);
        }
    }
    
    difference() {
        union() {
            for(a=[0:90:270]) {
                rotate([0,0,a]) arm1(clip=(a%180 == 0));
            }
        }
        for (a=[45:90:360]) {
            rotate([0,0,a]) {
                translate([mm_radius, 0, -1])
                    cylinder(d=motor_d, h=h+2); // Clear motor holes
                translate([mm_radius/1.25, 0, -1]) { // Leg holes
                    for (yy=[-leg_x/2, leg_x/2]) {
                        translate([0,yy]) cylinder(d=leg_y,h=h+2);
                    }
                }
                    
            }
        }
    }
}

module criusFrame() {
    board_mount(h=3);
    arms(3);
    
    for(a=[45:90:360]) {
        rotate([0,0,a]) translate([mm_radius, 0])
            motorMount(d=motor_d, thickness=motor_mount_t);
    }
}   

module leg(frame_h=3) {
    $fn=50;
    leg_h = 12;
    foam_w = 1;
    frame_h = frame_h + foam_w;
    translate([0,0,leg_y/2]) rotate([-90,0,0]) {
        hull() {
            for (xx=[-leg_x/2, leg_x/2]) {
                translate([xx,0]) cylinder(d=leg_y,h=frame_h);
            } 
        }
        hull() {
            for (xx=[-leg_x-1, leg_x+1]) {
                translate([xx,0,frame_h]) cylinder(d=leg_y,h=1);
            } 
        }
        hull() {
            for (xx=[-leg_x-2, leg_x+2]) {
                translate([xx,0,-1]) cylinder(d=leg_y,h=1);
            } 
        }
        hull() {
            translate([0,0,-2]) cylinder(d=leg_y,h=1);
            translate([0,0, -(leg_h-3)]) sphere(d=1);
        }
    }
}

module leg2(frame_h=3) {
    $fn=50;
    h1 = 1.5;
  
    
    translate([0,0,leg_y/2]) rotate([90,0,0]) {
        hull() {
            for (xx=[-leg_x-1, leg_x+1]) {
                translate([xx,0]) cylinder(d=leg_y,h=h1);
            } 
        }
        hull() {
            for (xx=[-leg_x/2, leg_x/2]) {
                translate([xx,0,h1]) cylinder(d=leg_y,h=frame_h);
            } 
        }
        
        hull() {
            for (xx=[-leg_x-2, leg_x+2]) {
                translate([xx,0,h1+frame_h]) 
                    cylinder(d=leg_y,h=h1);
            } 
        }
        
        w=0.8;
        d=5;
        g=2;
        n=4;
        off = h1+frame_h+h1-g+w/2+1;
        for(i=[1:n]) {
            translate([0,0,off + i*(w+g)]) {
                xx = i%2 ? -1 : 1;
                cube([d, leg_y,w], center=true);
                translate([xx*d/2, 0, -(w+g)/2]) rotate([90,0]) 
                    difference() {
                        tube(od=g+2*w, id=g, h=leg_y, center=true);
                        translate([-xx*(w+g)/2,0,-0.2]) 
                            cube([w+g, g, leg_y+1], center=true);
                    }
            }
        }
        
        hull() {
            translate([0,0,off+(w+g)*n]) cylinder(d=leg_y,h=1);
            translate([0,0,off+(w+g)*n+4]) sphere(d=1);
        }
    }
}

module leg3(frame_h=3) {
    $fn=50;
    h1 = 1.5;
  
    
    translate([0,0,leg_y/2]) rotate([90,0,0]) {
        hull() {
            for (xx=[-leg_x-1, leg_x+1]) {
                translate([xx,0]) cylinder(d=leg_y,h=h1);
            } 
        }
        hull() {
            for (xx=[-leg_x/2, leg_x/2]) {
                translate([xx,0,h1]) cylinder(d=leg_y,h=frame_h);
            } 
        }
        
        hull() {
            for (xx=[-leg_x-1, leg_x+1]) {
                translate([xx,0,h1+frame_h]) 
                    cylinder(d=leg_y,h=h1);
            } 
        }
    }
        
    translate([0, -5-frame_h-2*h1+1])
    scale([0.6,1]) tube(od=10, id=9.1, h=leg_y);    
        
    
}


criusFrame();
translate([-60, 0]) leg3();


//o=20;translate([-o,o]) rotate([0,0,45]) color("blue") cube([2, 30, 5]);
