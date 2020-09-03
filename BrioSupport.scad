module stl() {
    intersection() {
        import(file="One-Piece_Brio_Stacker_Track.stl", convexity = 10);
        //translate([0, -80]) cube([100,100,10]); //bottom_slice
        //translate([0,-8,0]) cube([100, 4, 100]); // side;
    }
    
    translate([1.5, -3, -1]) color("red") cube([75,15,2.5]);
}

leg_span = 75;
leg_w = 15;
leg_h = 61;
leg_wall_thk = 3;
leg_top_thk  = 2.5;
leg_arch_r = 18;
cantilever_w = 5;
cantilever_h = 6;

track_w = 40;
track_h = 12;

module trackPiece(l=50, w=track_w, h=track_h) {
    //l=50;
    rail_depth=3;
    rail_w=5.6;
    rail_gap=19.1;
    
    connector_l = 17.5;
    connector_w = 6.5;
    connector_d = 11.5;
    
    module connector(male=true) {
        w  = male ? connector_w : connector_w + 1.25;
        d  = male ? connector_d : connector_d + 1.25;
        hh = male ? h : h+2;
        z  = male ? 0 : -1;
        translate([z,-w/2, z]) cube([connector_l-d/2-z, w, hh]);
        translate([connector_l-d/2,0, z])cylinder(d=d, h=hh, $fn=25);
    }
    
    difference() {
        union() {
            translate([0, -w/2]) cube([l, w,h]);
            translate([l,0]) connector();
        }
        
        for(yy=[-rail_gap/2-rail_w, rail_gap/2]) {
            translate([-1, yy, h-rail_depth]) cube([l+2, rail_w, rail_depth+1]);
        }
        connector(male=false);
    }
}

module leg() {
    $fn=50;
    w       = leg_w;
    h       = leg_h;
    thk     = leg_wall_thk;
    top_thk = leg_top_thk;
    
    difference() {  //Leg vertical
        union() {
            cube([w,w,h]);
            translate([w, w-thk, h-cantilever_h]) 
                cube([cantilever_w,thk,cantilever_h]);
        }
        translate([thk, thk, -1]) {
            cube([w, w-thk*2, h-top_thk+1]);
            cube([w, w, h-top_thk-leg_arch_r]);
        }
        translate([leg_arch_r+thk, thk+1, h-leg_arch_r-cantilever_h+1]) 
            rotate([-90, 0, 0]) cylinder(r=leg_arch_r, h=w);
    }
}

module screw_hole(h1=10, h2=10) {
    $fn=50;
    head_d = 6.5;
    thread_d = 3;
 
    cylinder(d=head_d, h1);
    translate([0,0,h1-1]) cylinder(d=thread_d, h2+1);
}

module support(minimal_cantilever=false, screw_hole=true, legs=true) {
    side_drop = 12;
    side_arch_r = 40;
    side_arch_w = 1.5*leg_wall_thk;
    
    $fn=50;
    if (legs) {
        leg();
        translate([0,leg_span]) mirror([0,1,0]) leg();
    }
    
    corner_r = 5;
    translate([0,0,leg_h-leg_top_thk]) difference() { // Cantilever
        hull() {
            for(yy=[corner_r, leg_span-corner_r]) {
                translate([0, yy-corner_r]) cube([2,2*corner_r,leg_top_thk]);
                translate([leg_w+cantilever_w-corner_r,yy]) 
                    cylinder(r=corner_r,h=leg_top_thk);
            }
        }
        if (minimal_cantilever) {
            translate([side_arch_w, leg_w, -1])
                cube([leg_w+cantilever_w-side_arch_w+1,
                      leg_span-2*leg_w, leg_top_thk+2]);
        }
    }
    
    difference() {
        tol=0.2;
        union() {
            translate([leg_wall_thk+tol, leg_wall_thk, leg_h]) // Top block
                cube([leg_w-(leg_wall_thk+tol), leg_span-2*leg_wall_thk, track_h]);
        
            translate([0, leg_w+tol, leg_h-side_drop]) //Side Block
                cube([side_arch_w, leg_span-2*(leg_w+tol), side_drop+track_h]);
        }
        translate([-1,leg_span/2, leg_h-leg_top_thk-side_arch_r]) rotate([0,90])
            cylinder(r=side_arch_r, h=side_arch_w+2, $fn=100);  //Side arch
        if (screw_hole) {
            translate([-1,leg_span/2, leg_h+track_h/2-1]) 
                rotate([0,90,0]) screw_hole(h1=11);
        }
    }
    
}

//translate([12,-100]) rotate([0,0,90]) stl();

module onePiece45() {
    w=45;
    color("green") {
        support(true, screw_hole=false);
        translate([w+2*leg_w,0,0]) mirror([1,0,0])support(true, screw_hole=false);
        translate([w/2+leg_w,12,leg_h]) rotate([0,0,90]) trackPiece(w=w);
    }
}

color("green") support();
//%translate([track_w/2+leg_w,12,leg_h]) rotate([0,0,90]) trackPiece();
//onePiece45();

//color("red") cube([15,75,2.5]);