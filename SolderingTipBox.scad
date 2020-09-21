tipBase_dia = 6.6;
tipBase_h   = 30;
tipTop_h    = 15;



function hexWide(d) = d * cos(30);
function hexSide(d) = d * sin(30);

module tipHole() {
    $fn=50;
    cylinder(d=tipBase_dia, h=tipBase_h);
    translate([0,0,tipBase_h-0.1]) cylinder(d=tipBase_dia-0.2, h=tipTop_h+0.1);
}

module box1(xn=4, yn=4, trimTop=false) {
    $fn=100;
    wall_thk   = 0.82;
    bottom_thk = 3;
    slot_h = 5;
    slot_w = 0.8;
    outerWallX_thk = 1.6;
    outerWallY_thk = 1.6;
    
    out_d = tipBase_dia + wall_thk;
    gap_y = out_d;
    gap_x = out_d * cos(30);
    
    xw = xn*gap_x + outerWallX_thk*2;
    yw = (yn + (trimTop ? 0 : 0.5))*gap_y + outerWallY_thk*2;
    r1 = 4;
    r2 = 10;
    yoff = 0.4;
    
    bottom_h = bottom_thk + tipBase_h - 0.4;
    
    module boxy(xw, yw, rr1, rr2, h, off, zoff) {
        r1 = rr1; 
        r2 = (xn%2)  ? rr1 : rr2;
        r3 = rr1;
        r4 = trimTop ? rr1 : rr2;
        hull() {
        translate([r1,r1,zoff])       cylinder(r=r1-off, h=h);
        translate([xw-r2,r2,zoff])    cylinder(r=r2-off, h=h);
        translate([xw-r3,yw-r3,zoff]) cylinder(r=r3-off, h=h);
        translate([r4, yw-r4,zoff])   cylinder(r=r4-off, h=h);
        }
    }
    
    module holes(xoff=0, yoff=0) {
        xoff = xoff + outerWallX_thk + tipBase_dia/2;
        yoff = yoff + outerWallY_thk + tipBase_dia/2;
        for (xx=[0:xn-1]) {
            yoff = ((xx % 2) ? gap_y/2 : 0) + yoff;
            yn = (trimTop && (xx % 2)) ? yn-1 : yn;
            for(yy=[0:yn-1]) {
                translate([xx*gap_x+xoff, yy*gap_y+yoff, bottom_thk])
                    tipHole();
            }
        }
    }
    
    module bottom() {
        difference() {
            union() {
                h = bottom_h;
                slot_w = slot_w + 0.1;
                //cube([xn*gap_x+xoff*2, (yn+0.5)*gap_y+yoff*2, ]);
                boxy(xw, yw, r1, r2, h-slot_h, 0, 0);
                color("orange") boxy(xw, yw, r1, r2, slot_h, slot_w, h-slot_h);
            }
            
            holes(yoff=yoff);
        }
    }
    
    module top() {
        h    = tipTop_h + bottom_thk + slot_h + 0.4;
        zoff = bottom_h - slot_h;
        translate([0,0,-(zoff+h)])
        difference() {
            boxy(xw, yw, r1, r2, h, 0, zoff);
            
            boxy(xw, yw, r1, r2, slot_h+0.1, slot_w, zoff-0.1);
            holes(yoff=yoff);
        }
    }
    
    bottom();
    translate([-1,0]) rotate([0,180,0]) top();
}

/*
module box1() {
    box1Wall_thk   = 2;
    box1Bottom_thk = 2;
    
    xn=4;
    yn=4;
    
    hex_d = tipBase_dia + box1Wall_thk;
    hex_y = hexWide(hex_d);
    hex_x = hex_d + hexSide(hex_d);
    
    module single() {
        difference() {
            cylinder(d=tipBase_dia+box1Wall_thk, h=tipBase_h+box1Bottom_thk, $fn=6);
            translate([0,0,box1Bottom_thk]) tipHole();
        }
    }
    
    module bottom() {
        for (xx=[1:xn]) {
            off = ((xx % 2) ? hex_y/2 : 0) -hex_y/2;
            for(yy=[1:yn]) {
                translate([xx*hex_x/2, yy*hex_y+off]) single();
            }
        }
    }
    
    bottom();
    //single();
    //translate([0,hex_y])single(); 
    //#translate([hex_x/2, hex_y/2])single();
}*/

box1(4,4,trimTop=true);

