$fn=50;

sphere_d = 15;
d1 = 6.25;
h1 = 16.5;
d2 = 4.75;
h2 = 13;
d3 = 3.3;
h3 = 5;
d4 = 4.8;
h4 = 13;

d0 = 3.5;
insert = 2;

module shaft() {
    cylinder(d=d1, h=h1);
    translate([0,0,h1]) cylinder(d=d2, h=h2);
    translate([0,0,h1+h2]) cylinder(d=d3, h=h3);
    translate([0,0,h1+h2+h3]) cylinder(d=d4, h=h4);
    translate([0,0,h1+h2+h3+h4]) sphere(d=d4);
}

module ball() {
    flatface=2.5;
    translate([(sphere_d+d1)/2+0.1, 0, sphere_d/2-flatface]) 
    difference() {
        sphere(d=sphere_d);
        { 
            translate([0,0,sphere_d/2-insert]) cylinder(d=d1+0.2, h=insert+1);    
            translate([0,0,-sphere_d/2]) cube([sphere_d,sphere_d, flatface*2], center=true);
        }
    }
}


module shaft2() {
    module shaftHalf() {
        rotate([0,90,0])
        difference() {
            union() {
                shaft();
                translate([0,0,-insert]) cylinder(d=d0, h=insert);
            }
            translate([0,-d1/2,-(d0+0.1)]) cube([d1, d1, insert+h1+h2+h3+h4+10]);
        }
    }
    
    shaftHalf();
    translate([0, d1+0.1, 0]) shaftHalf();
}

module ball2() {
    flatface = 2.5;
    i2  = 1;
    translate([(sphere_d+d1)/2+0.1, 0, sphere_d/2-flatface]) 
    difference() {
        sphere(d=sphere_d);
        { 
            translate([0,0,sphere_d/2-(insert+i2+0.2)]) cylinder(d=d0+0.2, h=insert+i2+1);  
            translate([0,0,sphere_d/2-i2]) cylinder(d=d1+0.2, h=i2+1);   
            translate([0,0,-sphere_d/2]) cube([sphere_d,sphere_d, flatface*2], center=true);
        }
    }
}

shaft2();
translate([0,18,0]) ball2();

