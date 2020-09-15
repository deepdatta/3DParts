use <threads.scad>

// Parametric Nuts and Bolts using the threads.scad from 
// https://dkprojects.net/openscad-threads/threads.scad


module example() {
    bolt("m5", length=10, head = "hex", quality=40);
    translate([9,0,0]) nut(diameter=5, pitch=0.8, outerDiameter=8, threadType="metric", v=1);
    
    translate([0, -10, 0]) bolt("m3", length=8);
    translate([8, -10, 0]) nut("m3");
    
    // Captive bolt slot
    translate([8, 10, 0])
        difference() {
            translate([-5,-5]) cube([10, 10, 6]);
            translate([0,0,6-4]) nut("m3", slot=true, thickness=4);
        }
}
//example();


fastener_specs = [
  ["name", "thread type", "thread diameter", "pitch", 
   "hex head thickess", "hex head & nut size", 
   "socket head diameter", "socket head thickness", "socket tool size", 
   "nut thickness", "button thickness"] , 
  
  ["m2",  "metric",  2, 0.4, 2.0, 4,   3.5, 2, 1.5, 1.6, 0.90],
  ["m3",  "metric",  3, 0.5, 2.0, 5.5, 5.5, 3, 2.5, 2.4, 1.04],
  ["m4",  "metric",  4, 0.7, 2.8, 7,   7.0, 4, 3.0, 3.2, 1.3],
  ["m5",  "metric",  5, 0.8, 3.5, 8,   8.5, 5, 4.0, 4.0, 2.08],
  ["m6",  "metric",  6, 1.0, 4.0, 10, 10.0, 6, 5.0, 5.0, 2.08],
  ["m8",  "metric",  8, 1.25,5.5, 13, 13.0, 8, 6.0, 6.5, 2.6],
  ["m10", "metric", 10, 1.5, 6.5, 17, 16.0, 10,8.0, 8.0, 3.12]
];

function getFastenerSpecs(name, def=[]) = let(idx=search([name], fastener_specs, index_col_num=0)) 
                                            (idx == [[]]) ? def : fastener_specs[idx[0][0]];

// external radius from flat distance
function hexRadius(hexSize) = hexSize/2/sin(60); 

// radius of circle inside hexagon
function hexInradius(hexSize) = hexSize * (2 / sqrt(3)); 

function override_default(val, newval, defval=-1) = (val == defval) ? newval : val;

module cut_chamfer(height, boltSize, quality = 64) { //hexagonal nuts insertion cutout
  $fn = quality;
  translate([0, 0, height/2])
    cylinder(r1 = boltSize/1.5, r2 = boltSize/2, h = height/2);
  cylinder(r1 = boltSize/2, r2 = boltSize/1.5, h = height/2);
}

module boltHead(head="socket", diameter=3, hexHeadThickness=2, hexHeadDiameter=5.5, 
                socketHeadDiameter=5.5, socketHeadThickness=3, socketToolSize=2.5,
                buttonThickness = 1.04, tolerance=0, quality = 24, list=false) {
  $fn = quality; // elements for each curve
  o = 0.001; // overage to make cuts complete

  // list available heads here
  headTypes = [ "socket", "button", "conical", "flatSocket", "flatHead", "grub", "hex", "set"]; 
  

  if (list) {
    echo ("Available head types:");
    for (i = headTypes) {
      echo(str("     ", i));
    }
  }
 
  // check for valid head type
  head = search([head], headTypes) == [[]] ? headTypes[0] : head;

  if (head == "socket") { // hex socket head
    // minkwoski() adds 2*sphere radius to the head adjust variables to deal with this
    headThick = socketHeadThickness-(1/8 * socketHeadDiameter)+tolerance;
    headRad = (socketHeadDiameter + tolerance)/2;
    minSphere = headRad * 1/8; // radius for minkowski sphere
   
    transZ = quality >= 24 ? 1 : 0; // set to 0 if quality is less than 24

    // move the head to the origin, move just under origin to ensure union 
    translate([0, 0, ((1/8 * socketHeadDiameter)/2*transZ)-o*5]) 
    difference() {
      if (quality >= 24) { // if low quality, disable minkowski
        minkowski() { // create a nicely rounded head
          sphere(r = minSphere);
          cylinder ( h = headThick, r = headRad - minSphere);
        } // end minkowski
      } else { // for low rez head - add back in difference from minkowski
        cylinder(h = headThick + minSphere*2, r = headRad);
      }
      // hex tool socket
      translate([0, 0, headThick/2])
        cylinder( r = hexRadius(socketToolSize), $fn = 6, h = headThick*.8);
      translate([0, 0, headThick/4])
        cylinder( r1 = 0, r2=hexRadius(socketToolSize), $fn = 6, h = headThick/4+0.01); 
    } // end difference
  } // end if socket


  if (head == "conical") {
    // minkwoski() adds 2*sphere radius to the head adjust variables to deal with this
    headThick = socketHeadThickness*1.5 -(1/32*socketHeadDiameter)/2+tolerance;
    headR2 = (socketHeadDiameter*.8 -1/32*socketHeadDiameter)/2+tolerance/2;
    headR1 = (socketHeadDiameter+tolerance)/2;
    minSphere = 1/32 * headR1/2;
   
    transZ = quality >= 24 ? 1 : 0; // set to 0 if quality is less than 24
    
    // move the head to the origin - this is *slightly* below the axis
    translate([0, 0, minSphere*transZ-o*5])
    difference() {
      if (quality >= 24) {
        minkowski() { // add rounded edges to head
          sphere(r = minSphere);
          cylinder(h = headThick, r2 = headR2, 
                  r1 = headR1);
        } // end minkowski
      } else {
       cylinder(h = headThick, r2 = headR2, r1 = headR1); 
      }
      translate([0, 0, headThick*.25])
        cylinder(r = hexRadius(socketToolSize), h = headThick*.8, $fn = 6);
    }
  } // end if conical


  if (head == "hex") {
    headThick = hexHeadThickness+tolerance;
    headRadius = hexRadius(hexHeadDiameter)+tolerance;
    intersection(size) {
      cylinder (r = headRadius, h = headThick, $fn = 6); // six sided head
      cut_chamfer(height = headThick, boltSize = hexHeadDiameter+tolerance*2, quality = quality);
    } 
  } // end if hex

  if (head == "flatSocket" || head == "flatHead") { 
    headThick = socketHeadThickness+tolerance;
    headR1 = (diameter+tolerance)/2;
    headR2 = (socketHeadDiameter+tolerance)/2;
    //headRad = 
    translate([0, 0, -socketHeadThickness*.75])
    difference() {
      cylinder(r1 = headR1, r2 = headR2, h = headThick*.75);
      translate([0, 0, headThick*.75/2+o])
        // hex tool socket
        cylinder(r = hexRadius(socketToolSize), h = headThick/2, $fn=6);
    }
  } // end if flatSocket


  // don't do anything for type grub

  if (head == "button") {
    c = socketHeadDiameter; // chord length 
    f = buttonThickness*1.25; // height of button  * 1.25 rough aproximation of proper size 

    //headRadius = ((pow(c,2)/4)-pow(f,2))/2*f;
    // r = radius of sphere that will be difference'd to make the button
    r = ( pow(c,2)/4 + pow(f,2) )/(2*f); 

    d = r - f; // displacement to move sphere

    difference() {
      translate([0, 0, -d])
      sphere(r = r, $fn = quality);  
      translate([0, 0, -r])
        cube(r*2, center = true);
      translate([0, 0, f/3])
      cylinder(r = hexRadius(socketToolSize), h = f, $fn = 6);
      
    } // end difference
  } // end if button

}

module bolt(name="m3", threadType="", length=10, diameter=-1, head="socket",
            pitch=-1, hexHeadThickness=-1, hexHeadDiameter=-1, 
            socketHeadDiameter=-1, socketHeadThickness=-1, socketToolSize=-1,
            buttonThickness=-1, center=false,
            quality=24, tolerance=0, list=false, v=false) {
  
    spec = getFastenerSpecs(name);
   
    _threadType         = override_default(threadType, spec[1], "");
    diameter            = override_default(diameter, spec[2]);
    pitch               = override_default(pitch, spec[3]);
    hexHeadThickness    = override_default(hexHeadThickness, spec[4]);
    hexHeadDiameter     = override_default(hexHeadDiameter, spec[5]);
    socketHeadDiameter  = override_default(socketHeadDiameter, spec[6]);
    socketHeadThickness = override_default(socketHeadThickness, spec[7]);
    socketToolSize      = override_default(socketToolSize, spec[8]);
    buttonThickness     = override_default(buttonThickness, spec[10]);
    z_off = center ? -length/2 : 0;
        
    threadTypes = ["metric", "english"];
    threadType = search([_threadType], threadTypes) == [[]] ? threadTypes[0] : _threadType;
    adjustedLength = (head == "flatSocket" || head == "flatHead") ? 
                     length - socketHeadThickness*.75 : length;
    
    if (v) {
        echo(threadType=threadType);
        echo("diameter: ", diameter, " + ", tolerance);
        echo(pitch=pitch);
        echo(hexHeadThickness=hexHeadThickness);
        echo(hexHeadDiameter=hexHeadDiameter);
        echo(socketHeadDiameter=socketHeadDiameter);
        echo(socketHeadThickness=socketHeadThickness);
        echo(socketToolSize=socketToolSize);
        echo(buttonThickness=buttonThickness);
    }
  
    if (list) { // list available thread types 
        echo("Available thread types");
        for (k = threadTypes) {
            echo(str("     ", k));
        }
    }

    translate([0,0,z_off]) {
        if (threadType == "metric") {
            metric_thread (diameter=diameter, pitch=pitch, length=adjustedLength);
        }
        translate([0, 0, adjustedLength])
            boltHead(head, diameter, hexHeadThickness, hexHeadDiameter, 
                     socketHeadDiameter, socketHeadThickness, socketToolSize,
                     buttonThickness, tolerance, quality, list);
    }
 }
 
 module nut(name="m3", threadType="", diameter=-1, pitch=-1,
            outerDiameter=-1, thickness=-1, chamfer=true, slot=false,
            quality = 24, tolerance = 0, 
            list = false, v = false) {

    spec = getFastenerSpecs(name);
                
    _threadType   = override_default(threadType, spec[1], "");
    diameter      = override_default(diameter, spec[2]);
    pitch         = override_default(pitch, spec[3]);
    outerDiameter = override_default(outerDiameter, spec[5]);
    thickness     = override_default(thickness, spec[9]);
        
    threadTypes = ["metric", "english"];
    threadType = search([_threadType], threadTypes) == [[]] ? threadTypes[0] : _threadType;
        
    if (v) {
        echo(threadType=threadType);
        echo("diameter: ", diameter, " + ", tolerance);
        echo(pitch=pitch);
        echo(outerDiameter=outerDiameter);
        echo(thickness=thickness);
    }
  
    if (list) { // list available thread types 
        echo("Available thread types");
        for (k = threadTypes) {
            echo(str("     ", k));
        }
    }
  
    $fn = quality;
  
    height = thickness+tolerance + (slot ? 1 : 0);
    radius = hexRadius(outerDiameter+tolerance/2);
    boltSize = outerDiameter+tolerance;
    
    chamfer = slot ? false: chamfer;

    difference() {
        intersection() {
            cylinder(r = radius, h = height, $fn = 6);
            if (chamfer) {
                cut_chamfer(height = height, boltSize = boltSize);
            }
        }
        if (!slot) {
            translate([0, 0, -(height*1.1 - height)/2])
                metric_thread (diameter=diameter, pitch=pitch, length=height+2, internal=true);
        }
    }
}

module echoFastenerSpec(name) {
    spec = getFastenerSpecs(name);
    if (spec != [] ) {
        for (i=[1:len(spec)]) {
            echo(str(fastener_specs[0][i], ": ", spec[i]));
        }
    } else {
        echo ("Spec not found for ", name);
    }
}
