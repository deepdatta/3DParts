module teardrop(r1, r2=0.2, l, zrot=0, off=0) {
    rotate([0,0,zrot]) translate([off, 0])
    rotate([0,90])
    hull() {
        sphere(r=r1);
        translate([0,0,l-(r1+r2)]) sphere(r=r2);
    }
}

$fn=100;
module centerPiece() {
    
    trd = [0.3, 2.8, 13];  //teardrop r1, r2, l
    center_r = 2;
    
    translate([0,1.2]) sphere(center_r);
    
    teardrop(trd[0], trd[1], 12, 90, center_r+1);
    for (o=[[17,10], [15, 34], [13.5,61]]) {
        teardrop(trd[0], trd[1], o[0], o[1], center_r);
        mirror([1,0]) teardrop(trd[0], trd[1], o[0], o[1], center_r);
    }
}

module chandrapuliMold(h=8){
    length   = 70;
    len_line = 55;
    line_r = 0.6;
    big_r  = 28;
    off = 6;
    edge_w=1.5;
    
    
    module chandraPuliShape() {
        rotate([0,90]) translate([0,0,-len_line/2]) cylinder(r=line_r, h=len_line);
        
        translate([0, -off]) {
             rotate([0,0,12]) rotate_extrude(convexity=10, angle=156) {
                translate([big_r, 0, 0])  circle(r=line_r);
            }
             rotate([0,0,15]) rotate_extrude(convexity=10, angle=150) {
                translate([23, 0, 0])  circle(r=line_r);
            }
        }
        translate([0, 1]) centerPiece();
    }
    
    module base(thk, offset=0) {
        r = big_r+edge_w;
        linear_extrude(height=thk) {
            offset(delta=offset) intersection() {
                translate([0,-off]) circle(r=r);
                translate([-r, -edge_w]) square([r*2, r]);
            }
        }
    }
    difference() {
        translate([0,0,-h]) union() {
            base(h);
            base(3, 3);
        }
        chandraPuliShape();
    }
    
}
chandrapuliMold(5);