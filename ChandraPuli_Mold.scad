module teardrop(r1, r2=0.2, l) {
    rotate([0,90])
    hull() {
        sphere(r=r1);
        translate([0,0,l-(r1+r2)]) sphere(r=r2);
    }
}

$fn=100;
module centerPiece() {
    
    trd = [0.3, 2, 11];  //teardrop r1, r2, l
    center_r = 2;
    
    translate([0,1.2]) sphere(center_r);
    scale([1.4,1])
    for(a=[15:25:180]) {
        rotate([0,0,a]) 
            translate([(center_r + 1),0]) teardrop(trd[0], trd[1], trd[2]);
    }
}

module chandrapuliMold(h=8){
    length   = 70;
    len_line = 55;
    line_r = 0.5;
    big_r  = 33;
    
    
    module chandraPuliShape() {
        rotate([0,90]) translate([0,0,-len_line/2]) cylinder(r=line_r, h=len_line);
        
        translate([0, -6]) {
             rotate([0,0,25]) rotate_extrude(convexity=10, angle=130) {
                translate([big_r, 0, 0])  circle(r=line_r);
            }
             rotate([0,0,15]) rotate_extrude(convexity=10, angle=150) {
                translate([22.5, 0, 0])  circle(r=line_r);
            }
        }
        translate([0, 0.8]) centerPiece();
    }
    
    difference() {
        translate([0,0,-h]) cylinder(r=big_r+2, h=h);
        chandraPuliShape();
    }
    
}
chandrapuliMold();