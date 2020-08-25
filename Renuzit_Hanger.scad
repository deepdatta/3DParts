$fn=50;

renuzit_d  = 68;
ring_width = 5;
ring_thickness = 4;
pi = 3.14159;

small_rod_dia = 3.5; //3.25 actual
big_rod_dia = 7; //6.75 actual
hook_width = 8;
hook_len  =15;
hook_thickness = 2;

module hanger_ring()
{
	//Distance of string holes from center
	rh = (renuzit_d + ring_width)/2;
	difference() {
		cylinder(d=renuzit_d+ring_width*2, h=ring_thickness);
		translate([0,0,15]) sphere(d=renuzit_d+5);
		for (theta=[0:60:360]) {
			translate ([rh*sin(theta), rh*cos(theta),0])
				translate([0,0,-0.1]) cylinder(r=1.2, h=ring_thickness+1);
		}
	}
}

module hook(rod_dia)
{   
    difference() {
        hole_d=3;
        cube ([hook_thickness, hook_len, hook_width]); 
        translate([-1, hook_len-hole_d, hook_width/2]) rotate([0,90,0]) 
            cylinder (d=hole_d, h=hook_thickness+2);
    }
    
	translate ([-rod_dia/2,0,0])
		difference() {
			cylinder(r=rod_dia/2+hook_thickness, h=hook_width);
            translate([0,0,-0.1]) {
                cylinder(r=rod_dia/2,h=hook_width+1);
                translate([-rod_dia/2,0,0])
                    cube([rod_dia, rod_dia*2, hook_width+1]);
            }
		}
	/*translate ([0, hook_len,0]) {
		difference() {
			cube ([8, hook_thickness, hook_width]);
			
				cylinder (r=1.5, h= hook_thickness+4);
		}
	}*/
	
	
}

translate([-12, 0, 0]) hook(small_rod_dia);
translate([10, 0, 0]) hook(small_rod_dia);
translate([0, 0, 0]) hook(big_rod_dia);
hanger_ring();
