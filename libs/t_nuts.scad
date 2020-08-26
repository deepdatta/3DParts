module tNut_2020_twist() {
    translate([0,-5.5,-3])
    difference() {
        translate([-1.8,0,0]) 
            import(file="T-nut_clip_20x20.stl");
        translate([1,-3,-0.01])cube([8,16,7]);
    }
}


//tNut_2020_twist();