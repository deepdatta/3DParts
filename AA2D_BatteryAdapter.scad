// Length of AA Battery including contacts (49.2-50.5)
AA_Length = 50.5;
// Diameter of AA Battery (13.5 - 14.5)
AA_Dia    = 14.1;
// Length of D Battery including contacts (59.5-61.5)
D_Length = 60.5;
// Diameter of D Battery (34.2-32.3)
D_Dia    = 33;
// Length  of the top contact on D Battery
D_Positive_Len = 1.5;
// Diameter  of the top contact on D Battery
D_Positive_Dia = 9.5;

Penny_Dia = 19.2+0.5;
Penny_H = 1.7;
$fn=100;

module DBody(h, contacts=false) {
    module AAShell(h) {
        cut_y = 10;
        r = AA_Dia/2;
        lip_r = 1.12;
        circle(r=r);
        difference() {
            c_y=3.2;
            c_x=2.7;
            polygon([[0,0], [-r, cut_y], [-r, -cut_y]]);
            translate([-r+c_x,-(cut_y-c_y)]) circle(r=lip_r);
            translate([-r+c_x,(cut_y-c_y)]) circle(r=lip_r);
        }
    }
    
    x=2.85;
    linear_extrude(height=h, convexity=10) {
        difference() {
            circle(d=D_Dia);
            for(za=[0, 120, 240]) {
                rotate([0,0,za])
                    translate([-(AA_Dia/2+x),0]) AAShell();
            }
            #translate([D_Dia/2,0]) circle(r=2);
            
        }
    }
    if(contacts) {
        %for(za=[0, 120, 240]) {
            rotate([0,0,za])
                translate([-(AA_Dia/2+x),0, h-1]) cylinder(d=5, h=1);
        }
    }
}

module Top(h, screw_dia, screw_dia_major) {
    h1=6;
    module Top1(h) {
        difference() {
            DBody(h,true);
            cylinder(d=screw_dia, h=h+1);
            translate([0,0,h-Penny_H/2]) cylinder(d=Penny_Dia, h=Penny_H);
        }
    }
    module Top2(h) {
        difference() {
            cylinder(d=D_Dia, h=h);
            cylinder(d=screw_dia_major, h=h+1);
            translate([0,0,h-Penny_H/2]) cylinder(d=Penny_Dia, h=Penny_H);
            translate([D_Dia/2,0,-0.1]) cylinder(r=2, h=h+1);
        }
    }
    
    Top1(h1);
    echo("Top_height", h1+h);
    translate([-D_Dia - 1, 0, h]) Top2(h);
}

module Bottom(h, screw_dia) {
    difference() {
        DBody(h);
        cylinder(d=screw_dia, h=h+1);
        translate([0,0,h-Penny_H/2]) cylinder(d=Penny_Dia+0.1, h=Penny_H);
    }
}

module holeGuide(h, screw_dia) {
    difference() {
        cylinder(d=Penny_Dia+6, h=h);
        translate([0,0,h-Penny_H*0.75]) cylinder(d=Penny_Dia, h=Penny_H);
        cylinder(d=screw_dia, h=h+1);
    }
}
    
top_height = D_Length - D_Positive_Len - AA_Length - 2*Penny_H;   

Top(top_height, 2, 3.1);
translate([D_Dia+1,0]) Bottom(6, 2);
//translate([0, D_Dia+1]) holeGuide(4, 2.1);
