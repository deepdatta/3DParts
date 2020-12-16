// WeMos Base PCB Length
weMosBase_l  =28;
// WeMos Base PCB Width
weMosBase_w  =26.2;
// WeMos Base PCB Thickness
weMosBase_thk=1.75;

module wemosBase(l=weMosBase_l, w=weMosBase_w, thk=weMosBase_thk) {
    module pinHoles(d, zoff, h, color="silver") {
        color(color) for(yy=[1.75:2.5:20], xx=[1.25, w-1.25]) {
            translate([xx, l-yy, zoff]) cylinder(d=d, h=h);
        }
    }
    difference() {
        union() {
            color("Navy") cube([w, l, thk]);
            pinHoles(d=1.1, zoff=-0.01, h=thk+0.02);
        }
        
        translate([-0.01,-0.01,-0.01]) hull() {
            cube([2.5,1,thk+1]); 
            translate([0,5.2]) cube([1.5,1, thk+1]);
            translate([1.5,5.2]) cylinder(r=1, h=thk+1);
        }
        pinHoles(d=0.6, zoff=-0.02, h=thk+1);
    }
}

module wemosRelay(l=weMosBase_l, w=weMosBase_w, thk=weMosBase_thk) {
    
    r_w=15.1; r_l=19; r_h=15.5;
    wemosBase(l, w, thk);
    translate([(w-r_w)/2, l-r_l, thk]) 
         color("DodgerBlue") cube([r_w, r_l, r_h]);
    translate([(w-r_w)/2, 0, thk])
        color("RoyalBlue") cube([r_w, l-r_l, 10.5]);
}

//wemosRelay();