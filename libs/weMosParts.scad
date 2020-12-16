module wemosBase() {
    thk=1.75;
    w=26.2;
    l=28;
    module pinHoles(d, zoff, h, color="silver") {
        color(color) for(yy=[1.75:2.5:20], xx=[1.25, wb_w-1.25]) {
            translate([xx, wb_l-yy, zoff]) cylinder(d=d, h=h);
        }
    }
    difference() {
        union() {
            color("Navy") cube([wb_w, wb_l, wb_thk]);
            pinHoles(d=1.1, zoff=-0.01, h=wb_thk+0.02);
        }
        
        translate([-0.01,-0.01,-0.01]) hull() {
            cube([2.5,1,wb_thk+1]); 
            translate([0,5.2]) cube([1.5,1, wb_thk+1]);
            translate([1.5,5.2]) cylinder(r=1, h=wb_thk+1);
        }
        pinHoles(d=0.6, zoff=-0.02, h=wb_thk+1);
    }
}
module wemosRelay() {
    r_w=15.1; r_l=19; r_h=15.5;
    wemosBase();
    translate([(wb_w-r_w)/2, wb_l-r_l, wb_thk]) 
         color("DodgerBlue") cube([r_w, r_l, r_h]);
    translate([(wb_w-r_w)/2, 0, wb_thk])
        color("RoyalBlue")cube([r_w,wb_l-r_l,10.5]);
}
