// All units are in mm

// Descibe the solid model of the scissor jack work space
module jack_clearance() {
   baseWidth = 130;
   baseLength = 380;
   baseHeight = 10;

   jackMin = 100;
   jackMax = 420;
   jackWidth = 70;
   jackLength = 440;

   jackShaftHeight = 200;
   jackHeadHeight = 400;
   jackHeadWidth = 45;
   jackHeadLength = 70;

   translate([baseWidth/-2, 0, 0]) {
     cube([baseWidth, baseLength, baseHeight]);
     translate([(baseWidth-jackWidth)/2, (baseLength - jackLength)/2, 0])
       cube([jackWidth, jackLength, jackShaftHeight]);
     translate([(baseWidth-jackHeadWidth)/2, (baseLength - jackHeadLength)/2, 0])
         cube([jackHeadWidth, jackHeadLength, jackHeadHeight]);
   };
}

frameBottomWidth = 17;

frameSideWidth = 17;
frameSideLength = 800;
frameSideHeight = 390;

module powderbed_frame_side() {

  difference() {  
    cube([frameSideLength, frameSideWidth, frameSideHeight]);
    translate([frameSideLength/4, 0, frameBottomWidth])
       jack_clearance();
    translate([frameSideLength/4*3, 0, frameBottomWidth])
       jack_clearance();
  }
}

frameMiddleWidth = 17;
frameMiddleLength = 260;
frameMiddleHeight = 370;

module powderbed_frame_middle() {

  cube([frameMiddleWidth, frameMiddleLength, frameMiddleHeight]);
}

// Describe the solid model of the powerbed frame
// NOTE: This is NOT with the accounting of the jack!
module powderbed_frame() {
  powderbed_frame_side();

  translate([0, frameSideWidth, frameSideHeight - frameMiddleHeight])
    powderbed_frame_middle();

  translate([0, frameSideWidth + frameMiddleLength, 0])
    powderbed_frame_side();

  translate([frameMiddleWidth + floor(frameSideLength/2 - frameMiddleWidth*1.5), frameSideWidth, frameBottomWidth])
    powderbed_frame_middle();

  translate([frameSideLength - frameMiddleWidth, frameSideWidth, frameBottomWidth])
    powderbed_frame_middle();
}

powderbed_frame();
