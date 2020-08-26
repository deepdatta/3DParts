use <libs/t_nuts.scad>

$fn = 50;
module bracket(zh=7) {
    r1 = 1;
    yh = 38; 
    bt = 2.5; //baseplate thickness
    
    m3_d = 3.1;
    m3_head_d = 6.72;
    m3_head_dpth = 1.86;
    
    difference() {
        union() {
            hull() {
                for(y=[-1, 1], z=[-1,1]) {
                    translate([0, y*(yh/2-r1), z*(zh/2-r1)]) rotate([0,90,0]) cylinder(r=r1, h=bt);
                }
            }
            translate([0,10,0]) tNut_2020_twist();
            
            //color("red")
            translate([11+bt,0,-zh/2]) difference() {
                scale([1.1,1.1,1]) usbAdapter(zh);
                translate([0,0,-0.1]) usbAdapter(zh+1);
            }
            
            % translate([11+bt,0,-20]) usbAdapter(40);
            
            // Corner fillers
            cfw = bt+1.5;
            for (y=[1,-1]) {
                translate([cfw/2,y*(yh/2-2.4),0]) cube([cfw, 3.4, zh], center=true);
                translate([cfw/2,y*(yh/2-3.4),0]) cube([cfw/2, 3.4, zh], center=true);
            }
         }
         
         // 2nd Screw hole
         translate([-(7-bt),-10,0]) rotate([0,90,0]) {
            hscrew=5;
            cylinder(d=m3_d, h=hscrew);
            translate([0,0,hscrew]) cylinder(d1=m3_d, d2=m3_head_d, h=m3_head_dpth);
            translate([0,0,hscrew+m3_head_dpth]) cylinder(d=m3_head_d, h=3);
        }
    }
}

module usbAdapter(z=2) {
    yh   = 33.3;
    x0   = 18;
    xmid = 22.7;
    cr   = 61;
       
    module half() {
        translate([0, -yh/2]) square([x0/2,yh]);
        translate([-(cr-xmid/2),0])
            difference() {
                circle(r=cr, $fn=100);
                translate([-(xmid-x0)/2,0]) square(cr*2, center=true);
            }
    }
    
    //color("red", 0.25)
    linear_extrude(height=z) {
        half();
        mirror([1,0,0]) half();
    }
    
    //translate([xmid/2 - 1, 0, z+1]) color("black") circle(r=1);
}


bracket();


//translate([3,0,-3]) cylinder(r=2, h=6);