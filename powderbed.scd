// All units are in mm

isExploded = 0;

// Descibe the solid model of the scissor jack work space
   jackBaseWidth = 130;
   jackBaseLength = 380;
   jackBaseHeight = 10;

   jackMin = 100;
   jackMax = 420;
   jackWidth = 70;
   jackLength = 440;

   jackShaftHeight = 200;
   jackHeadHeight = 400;
   jackHeadWidth = 45;
   jackHeadLength = 70;



frameBottomHeight = 17;

frameSideWidth = 17;
frameSideLength = 791;
frameSideHeight = 390;

frameMiddleWidth = 17;
frameMiddleLength = 260;
frameMiddleHeight = 370;

pistonWidth = 17;
pistonHeight = (frameSideLength - frameMiddleWidth*3)/2;
pistonLength =  frameMiddleLength;


frameSideBottomWidth = 17;
frameSideBottomLength = frameMiddleWidth + (pistonHeight - jackBaseWidth)/2;
frameSideBottomHeight = 260;

frameMiddleBottomWidth = 17;
frameMiddleBottomLength = frameSideLength - (frameMiddleWidth*2 + pistonHeight + jackBaseWidth);
frameMiddleBottomHeight = 260;

module powderbed_piston() {
   color([0.2, 0.4, 0.9])
     cube([pistonHeight, pistonLength, pistonWidth]);
}

module jack_clearance() {

   translate([jackBaseWidth/-2, 0, 0]) {
   color([0.5, 0.3, 0.4])
     cube([jackBaseWidth, jackBaseLength, jackBaseHeight]);
   color([0.5, 0.3, 0.4])
     translate([(jackBaseWidth-jackWidth)/2, (jackBaseLength - jackLength)/2, 0])
       cube([jackWidth, jackLength, jackShaftHeight]);
   color([0.5, 0.3, 0.4])
     translate([(jackBaseWidth-jackHeadWidth)/2, (jackBaseLength - jackHeadLength)/2, 0])
         cube([jackHeadWidth, jackHeadLength, jackHeadHeight]);
     translate([(jackBaseWidth - pistonHeight)/2, (jackBaseLength - pistonLength)/2, jackHeadHeight])
		   powderbed_piston();
      
   };
}


module powderbed_frame_side() {
  cube([frameSideLength, frameSideWidth, frameSideHeight]);
}


module powderbed_frame_middle() {
  color([0.5, 0.1, 0.2])
  cube([frameMiddleWidth, frameMiddleLength, frameMiddleHeight]);
}

module powderbed_frame_middle_bottom() {
  color([0.8, 0.7, 0.9])
  cube([frameMiddleBottomLength, frameMiddleBottomHeight, frameMiddleBottomWidth]);
}

module powderbed_frame_side_bottom() {
  color([0.8, 0.0, 0.2])
  cube([frameSideBottomLength, frameSideBottomHeight, frameSideBottomWidth]);
}

angleIronWidth = 1;
angleIronHeight = 30;

angleIronSideLength = 915;
angleIronEndLength = 305;

module angle_iron(length = 100)
{
   translate([0, -angleIronWidth, -angleIronHeight])   
   cube([length, angleIronWidth, angleIronHeight]);

   rotate([90, 0, 0])
     cube([length, angleIronWidth, angleIronHeight]);
}

module powerbed_angleiron_side() {
   color([0.1, 0.2, 0.3])
   angle_iron(length =angleIronSideLength );
}

module powderbed_angleiron_end() {
   color([0.3, 0.9, 0.2])
     angle_iron(length =angleIronEndLength);
}

// Describe the solid model of the powerbed frame
// NOTE: This is NOT with the accounting of the jack!
module powderbed_frame() {
  powderbed_frame_side();

  translate([frameSideLength - angleIronSideLength, 0, frameSideHeight])
    powerbed_angleiron_side();

  translate([frameSideLength - angleIronSideLength, (frameMiddleLength + frameSideWidth * 2) + angleIronWidth, frameSideHeight])
    rotate([90, 0, 0])
    powerbed_angleiron_side();

  translate([frameSideLength, ((frameSideWidth*2 + frameMiddleLength) - angleIronEndLength)/2, frameSideHeight])
    rotate([0, 0, 90])
    powderbed_angleiron_end();

  translate([frameSideLength - angleIronSideLength, ((frameSideWidth*2 + frameMiddleLength) - angleIronEndLength)/2, frameSideHeight])
    rotate([90, 0, 90])
    powderbed_angleiron_end();

  translate([0, frameSideWidth, frameSideHeight - frameMiddleHeight])
    powderbed_frame_middle();

  translate([0, frameSideWidth + frameMiddleLength, 0])
    powderbed_frame_side();

  translate([frameMiddleWidth + pistonHeight, frameSideWidth, frameSideHeight - frameMiddleHeight])
    powderbed_frame_middle();

  translate([frameSideLength - frameMiddleWidth, frameSideWidth, frameSideHeight - frameMiddleHeight])
    powderbed_frame_middle();

   translate([0, frameSideWidth, frameSideHeight - frameMiddleHeight - frameSideBottomWidth])
    powderbed_frame_side_bottom();

   translate([frameSideBottomLength + jackBaseWidth, frameSideWidth, frameSideHeight - frameMiddleHeight - frameSideBottomWidth])
      powderbed_frame_middle_bottom();

   translate([frameSideBottomLength + jackBaseWidth*2 + frameMiddleBottomLength, frameSideWidth, frameSideHeight - frameMiddleHeight - frameSideBottomWidth])
       powderbed_frame_side_bottom();
}

jackHeightOffset = -(jackMax-jackMin);

if (isExploded) {
    rotate([0, 0, 90])
    powderbed_frame_middle();

    translate([10, 0, 0])
       powderbed_frame_side();

    translate([10 +frameSideLength + 10, 0, 0])
    rotate([90,0,0])
       powderbed_piston();

    rotate([-90, 0, 0]) translate([10, 10, 0])
       powderbed_frame_side_bottom();

     rotate([-90, 0, 0]) translate([200, 10, 0])
       powderbed_frame_middle_bottom();
  
} else {
    powderbed_frame();

   translate([frameMiddleWidth + pistonHeight/2, (frameMiddleLength+frameSideWidth*2-jackBaseLength)/2, jackHeightOffset]) jack_clearance();
   translate([frameMiddleWidth*2 + pistonHeight*1.5, (frameMiddleLength+frameSideWidth*2-jackBaseLength)/2, jackHeightOffset]) jack_clearance();
}
