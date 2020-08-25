
h = 20;
$fn=50;

module guide() {
    do = 12;
    di = 10.2;
    base_t1 = 1.5;
    difference() {
        union() {
            cylinder(d=do, h=h); 
            translate([0,-5,0])     cylinder(d=do, h=base_t1);
            translate([-do/2,-5,0]) cube([do,do,base_t1]);
            translate([-do/2-2,3,0]) cube([do+4,5,base_t1]);
        }
        {
            translate([0,0,-0.1]) cylinder(d=di, h=h+2);
            translate([-do/2-0.5,-do/2, 8]) cube([1,do,h]);
            translate([5,0,15]) rotate([0,-30,0]) cube([10, do, 25], center=true);
        }
    }
}

guide();