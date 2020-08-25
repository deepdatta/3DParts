include <configuration.scad>;
$fn=40;

//Fan Params
fan_hole_pitch = 32;
fan_width = 39.6;
fan_thickness = 10;
fan_radius = (fan_width/2)-1.2;	//Wall thickness = 1.2mm
fan_hole_offset = (fan_width - fan_hole_pitch)/2;

//Mount params
mount_thickness = 2;   // Overall thickness (mm)
mount_width = fan_width + 4;
fan_plate_hole_offset = fan_hole_offset + (mount_width-fan_width)/2;
mount_angle = 86;      // Angle to mount the fan at (degrees)
fan_mount_gap = 1;
fan_hotend_gap = 12;

hotend_radius = 8;
hotend_cutout_radius = 10;

module effector_plate()
{
	eff_plate_len = mount_thickness + fan_thickness
							+ fan_mount_gap + fan_hotend_gap;
	difference() {
		cube([mount_width, eff_plate_len, mount_thickness]);
		
		//Hotend hole
		translate([mount_width/2, eff_plate_len+hotend_radius, 0])
			cylinder (r=hotend_cutout_radius, h=mount_thickness);
	}
}

module fan_plate() {
	fan_plate_len = mount_thickness + fan_hole_offset 
							+ m3_wide_radius + 3*fan_mount_gap;
	screw_hole_y = fan_hole_offset + mount_thickness + fan_mount_gap;
	difference() {
		cube([mount_width, fan_plate_len, mount_thickness]);
		//Fan hole
		translate([mount_width/2,
					  fan_radius + mount_thickness + fan_mount_gap,
					  0])
			cylinder(r=fan_radius, h=mount_thickness);

		//Fan screw holes
		translate ([fan_plate_hole_offset, screw_hole_y, 0])
			cylinder(r=mr_wide_radius, mount_thickness);
		translate ([mount_width-fan_plate_hole_offset, screw_hole_y, 0])
			cylinder(r=mr_wide_radius, mount_thickness);
	}
}

module fan_mount() {
	union() {
		effector_plate();
		rotate (a=mount_angle, v=[1,0,0])
			fan_plate();
	}
}

rotate(a=270, v=[0,1,0]) // print on its side for strong angle joint
	fan_mount();