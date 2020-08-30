$fn=50;

m_d = 7.33;
m_d2 = 3;
m_l  = 24.7;
m_l2 = 3;
m_len = m_l + m_l2;

f_d  = 9.9;
f_l1 = 5.25;
f_collar_d = 9.6;
f_collar_l = 1.85;
f_l2 = 8.3;
f_d3 = 3.2;
f_l3 = 4.25;
f_len = f_l1+f_collar_l+f_l2+f_l3;

f_y_off = 4;
f_x_off = 6;

thk = 1.5;
clip_z = 3;


module maleJack(extra_cutout=false) {
    cylinder(d=m_d, h=m_l);
    translate([0,0,m_l-1]) cylinder(d=m_d2, h=m_l2+1);
    
    //Wires
    color("red") translate([-m_d/2,0,m_l-8.5]) cylinder(r=1, h=8.5+m_l2+f_x_off+3);
    
    if (extra_cutout) {
        translate([0,0,m_l-1]) 
            difference() {
                cylinder(d=m_d, h=m_l2+f_x_off+1);
                translate([-m_d/2,0.5,0])cube([m_d,m_d/2,m_l2+f_x_off+2]);
            }
    }
}

module femaleJack(extra_cutout=false) {
    cylinder(d=f_d, h=f_l1);
    translate([0,0,f_l1-1]) cylinder(d=f_collar_d, h=f_collar_l+2);
    translate([0,0,f_l1+f_collar_l]) cylinder(d=f_d, h=f_l2);
    translate([0,0,f_l1+f_collar_l+f_l2-1]) {
        cylinder(d=f_d3, h=f_l3+1);
        translate([0, -1.5,0]) cube([f_d/2+1,3,5]);
    }
    //Wires
    color("red") 
    rotate([0,0,-30])translate([0, f_d/2,f_len-f_l3-2]) {
        cylinder(r=1, h=f_y_off+f_l3);
    }
    
    if (extra_cutout) {
        translate([0, 0, f_len-f_l3-1])
            difference() {
                cylinder(d=f_d, h=f_l3+f_y_off-2);
                translate([0.5,-f_d/2,0])cube([f_d,f_d/2,f_l3+f_y_off+1]);
            }
    }
    
    
}
module clip_pin(d, h, male=true) {
    h = male ? h-0.4 : h;
    cylinder(d=d, h=h-d/2);
    translate([0,0,h-d/2]) sphere(d=d);
}

module clip_lock(w, h, rot=0, d=0.6, male=true) {
    rot = (360+rot)%360;   // Normalize to quads
    tvals = [[0,0], [0,0], [w,0], [0,w]];
    t = male ? 0 : 0.1;
    //echo(tvals[rot/90]);
    translate([tvals[rot/90][0], tvals[rot/90][1]]) rotate([0,0,rot]) {
        difference() {
            translate([0,-t,0]) cube([w, d+t, h]);
            if (male) {
                translate([w/8, d/4, h-0.2]) cube([w*3/4, d/2 ,h+0.1]); //Pry slot
            }
        }
        translate([0,d, h-d/4]) rotate([0,90,0]) cylinder(d=d/2, h=w);
        
        if (!male) { // Pry gap
            translate([0, -t, h-0.5])
                hull() {
                    cube([w, d, 0.6]);   
                    translate([0,0,0.7]) cube([w, d/2, 0.2]);
                }
        }
    }
}

module clips(z, male=true) {
    for(p=[[1.5,0.5], [3.5, 3], [1.5, -7], [10,-7]]) {
        translate([m_l+p[0], -(m_d/2+p[1]), 0]) clip_pin(1.2, z, male);
    }
    for(p=[[15, -(m_d/2+thk), 0], [15, m_d/2+thk, 180],
           [m_len+f_x_off+f_d/2+thk, -20, 90], [m_len+f_x_off-f_d/2-thk, -20, -90],
           [m_len+f_x_off+f_d/2+thk, -8, 90], [28, m_d/2+thk, 180] ]) {
        translate([p[0], p[1], 0]) clip_lock(3, z, rot=p[2], male=male);
    }
}

module jacks(extra_cutout=false) {
    translate([0,0,0]) 
        rotate([0,90,0]) 
            maleJack(extra_cutout);
    translate([(m_len+f_x_off), -(f_len+f_y_off),0]) 
        rotate([-90,-90,0])
            femaleJack(extra_cutout);
}

module cover_half() {
    x_off = 14;
    z_w   = f_d/2 + thk;
    ro = z_w;//8;
    ri = 3;

    union() {
        y_off = -(f_y_off + f_len-1);
        difference() {
            hull() {
                r_x = m_len+f_x_off+f_d/2; // Right edge of female jack
                translate([x_off, m_d/2, -z_w])
                    cube([1,thk,z_w]);      // TopLeft
                translate([r_x+thk-ro, m_d/2+thk - ro, -z_w]) 
                    //cylinder(r=ro, h=z_w);   // TopRight
                    translate([0,0,z_w]) difference() {
                        sphere(r=ro);
                        translate([0,0,ro/2])cube([2*ro,2*ro,ro], center=true);
                    }
                translate([x_off, y_off, -z_w]) 
                    cube([1,1,z_w]);        // BottomLeft
                translate([r_x, y_off, -z_w])
                    cube([thk,1,z_w]);      // BottomRight
            }
            hull() {
                x_off = x_off-0.1;//To get clean cuts
                y_off = y_off-0.1; 
                z_w = z_w + 1;
                r_x = m_len+f_x_off-f_d/2; // Left edge of female jack
                translate([x_off, -(m_d/2+thk+1), -z_w]) cube([1,1,z_w+1]);// TopLeft
                translate([r_x-thk-ri, -(m_d/2+thk+ri), -z_w]) cylinder(r=ri, h=z_w+1);// TopRight
                translate([x_off, y_off, -z_w]) cube([1,1,z_w+1]);     // BottomLeft
                translate([r_x-thk-1, y_off, -z_w]) cube([1,1,z_w+1]); // BottomRight
                
            }
        }
    }
}

module cover_bottom() {
    difference() {
        cover_half();
        jacks();
        translate([m_len+f_x_off-1.7,-2,1.7]) sphere(r=5.5);
    }
    //%jacks();
    clips(clip_z);
}

module cover_top() {
    difference() {
        mirror([0,0,1]) cover_half();
        jacks(true);
        translate([m_len+f_x_off+0.5,-3,0]) sphere(r=4.5);
        translate([0,0,-0.1]) clips(clip_z, male=false);
    }
    //%jacks();
}

module cover() {
    cover_bottom();
    translate([m_len*3,0,0]) rotate([0,180,0])
        cover_top();
}


// Tryout
module tryout() {
    xh=6;
    yh=6;
    zh=9;
    
    module half1() {
        translate([0,0,-zh/2]) cube([xh,yh, zh/2]);
    }
    
    module clips1(z, male=true) {
        for(p=[2,4]) {
            translate([p, p]) clip_pin(1.2, z, male);
        }
        off=(xh-3)/2;
        for(p=[[off, 0, 0], [off, yh, 180],
              [0, off, -90], [xh, off, 90] ]) {
            translate([p[0], p[1], 0]) clip_lock(3, z, rot=p[2], male=male);
        }
    }
    
    module top_half1() {
        difference() {
            mirror([0,0,1]) half1();
            translate([0,0,-0.1]) clips1(clip_z, male=false);
        }
    }
    module bottom_half1() {
        half1();
        clips1(clip_z);
    }
    
    translate([-10, 0, 0])bottom_half1();
    translate([-11, 0, 0])rotate([0,180,0])
        top_half1();
}

tryout();
//cover();


