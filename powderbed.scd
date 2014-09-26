module jack_clearance() {
   cube([130, 380, 10]);
   translate([35, -20, 0])
     cube([60, 420, 200]);
   translate([(130-45)/2, (380 - 70)/2, 0])
     cube([45, 70, 400]);
}

module powderbed_frame() {
  cube([800, 17, 390]);

  translate([0, 17, 20])
    cube([17, 260, 370]);

  translate([0, 17 + 260, 0])
    cube([800, 17, 390]);

  translate([17 + 374, 17, 20])
    cube([17, 260, 370]);

  translate([17 + 374 + 17 + 375, 17, 20])
    cube([17, 260, 370]);
}


difference() {  
 powderbed_frame();
 translate([(400-130)/2, 0, 20])
    jack_clearance();
 translate([400+(400-130)/2, 0, 20])
    jack_clearance();
}