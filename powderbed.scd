// All units are in mm
inchTOmm = 25.4;

isExploded = 1;

// Width of the MDF material
mdfWidth = 17;

// Width of the powderbox sheet-metal material
smWidth = 1/16 * inchTOmm;

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


frameBottomHeight = mdfWidth;

frameSideWidth = mdfWidth;
frameSideLength = 800;
frameSideHeight = 390;

frameMiddleWidth = mdfWidth;
frameMiddleLength = 260;
frameMiddleHeight = 370;

pistonWidth = mdfWidth;
pistonHeight = (frameSideLength - frameMiddleWidth*3)/2;
pistonLength =  frameMiddleLength;


frameSideBottomWidth = mdfWidth;
frameSideBottomLength = frameMiddleWidth + (pistonHeight - jackBaseWidth)/2;
frameSideBottomHeight = 260;

frameMiddleBottomWidth = mdfWidth;
frameMiddleBottomLength = 2 * mdfWidth * 2 + frameMiddleWidth;
frameMiddleBottomHeight = 260;

angleIronWidth = 1;
angleIronHeight = 30;

angleIronSideLength = 36 * inchTOmm;

railLength = 36 * inchTOmm;
railRadius = (0.25 * inchTOmm)/2;

module powderbed_piston() {
   color([0.2, 0.4, 0.9])
     cube([pistonHeight, pistonLength, pistonWidth]);
}

module jack_clearance() {
    translate([pistonHeight/2, -(jackBaseLength - pistonLength)/2, -(pistonWidth + jackHeadHeight)]) {
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
        }
    }
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


module angle_iron(length = 100)
{
   translate([0, -angleIronWidth, -angleIronHeight])
       cube([length, angleIronWidth, angleIronHeight]);

   rotate([90, 0, 0])
     cube([length, angleIronWidth, angleIronHeight]);
}

module xrail_angleiron_side() {
   color([0.1, 0.2, 0.3])
       angle_iron(length =angleIronSideLength );
}

module xrail_bariron() {
    color([0.7, 0.7, 0.7])
      rotate([90, 0, 90])
        cylinder(h = railLength , r = railRadius);
}

module xrail_endbox() {
    endboxMatingWidth = mdfWidth;
    endboxMatingLength = frameSideWidth * 2 + frameMiddleLength;
    endboxMatingHeight = frameSideHeight;

    endboxCatchFrontWidth = mdfWidth;
    endboxCatchFrontLength = railLength - (frameSideLength + mdfWidth + endboxMatingWidth*2);
    endboxCatchFrontHeight = frameSideHeight/2;

    endboxCatchBackWidth = mdfWidth;
    endboxCatchBackLength = railLength - (frameSideLength + mdfWidth + endboxMatingWidth*2);
    endboxCatchBackHeight = frameSideHeight/2;

       translate([0, -frameSideWidth, -endboxMatingHeight ]) {
    color([0.8, 0.9, 0.9])
        cube([endboxMatingWidth, endboxMatingLength, endboxMatingHeight]);
        color([1.0, 0.9, 0.8])
        translate([endboxMatingWidth, 0, frameSideHeight - endboxCatchFrontHeight])
            cube([endboxCatchFrontLength, endboxCatchFrontWidth, endboxCatchFrontHeight]);
        color([1.0, 0.9, 0.8])
        translate([endboxMatingWidth, pistonLength + frameSideWidth, frameSideHeight - endboxCatchBackHeight])
            cube([endboxCatchBackLength, endboxCatchBackWidth, endboxCatchBackHeight]);
       }
    
}

xrailTruckHeight = 12.5;

// X axis rails
module powderbed_xrail() {
        translate([-(frameMiddleWidth + angleIronSideLength)/2, -frameSideWidth, -(railRadius*2 + xrailTruckHeight)])

            xrail_angleiron_side();

        translate([-(frameMiddleWidth + angleIronSideLength)/2, (frameMiddleLength + frameSideWidth) + angleIronWidth, -(railRadius*2 + xrailTruckHeight)])
            rotate([90, 0, 0])
            xrail_angleiron_side();

        translate([-(pistonHeight + frameMiddleWidth*2 + mdfWidth), -(frameSideWidth + 9.5), -(railRadius + xrailTruckHeight)])
            xrail_bariron();

        translate([-(pistonHeight + frameMiddleWidth*2 + mdfWidth), pistonLength + frameSideWidth + 9.5, -(railRadius + xrailTruckHeight)])
            xrail_bariron();

        translate([pistonHeight + frameMiddleWidth, 0, 0])
            xrail_endbox();
}

// Describe the solid model of the powerbed frame
// NOTE: This is NOT with the accounting of the jack!
module powderbed_frame() {

    translate([-(frameSideLength+frameMiddleWidth)/2, -frameSideWidth, -frameSideHeight]) {
        powderbed_frame_side();


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

        translate([(frameSideLength - frameMiddleBottomLength)/2, frameSideWidth, frameSideHeight - frameMiddleHeight - frameSideBottomWidth])
            powderbed_frame_middle_bottom();

        translate([frameSideLength - frameSideBottomLength, frameSideWidth, frameSideHeight - frameMiddleHeight - frameSideBottomWidth])
            powderbed_frame_side_bottom();
    }
}

pboxSideWidth = smWidth;
pboxSideLength = frameMiddleLength - mdfWidth*4 - smWidth*2;
pboxSideHeight = pboxSideLength;

pboxBLipWidth = smWidth;
pboxBLipHeight = mdfWidth*2;
pboxBLipLength = pboxSideLength - pboxBLipHeight;

module powderbox_blip(lipid = 0) {
    color([0.8, 0.0, 0.8])
    cube([pboxBLipLength, pboxBLipWidth, pboxBLipHeight]);
}

pboxTLipWidth = smWidth;
pboxTLipHeight = mdfWidth;
pboxTLipLength = pboxSideLength;

module powderbox_tlip(lipid = 0) {
    if (lipid != 3) {
      color([0.8, 0.0, 0.1])
        cube([pboxTLipLength, pboxTLipWidth, pboxTLipHeight]);
    }
}

pboxSLipWidth = smWidth;
pboxSLipHeight = pboxSideHeight;
pboxSLipLength = mdfWidth;

module powderbox_slip(lipid = 0) {
   if (lipid == 3) {
     color([0.8, 0.0, 1.0])
       cube([pboxSLipLength, pboxSLipWidth, pboxSLipHeight]);
   }
}

module powderbox_side(lipid = 0, exploded = 0) {
    color([0.8, 0.0, 0.4])
     if (lipid == 3) {
      cube([pboxSideLength, pboxSideWidth, pboxSideHeight+pboxTLipWidth]);
     } else {
      cube([pboxSideLength, pboxSideWidth, pboxSideHeight]);
     }
   if (exploded) {
      translate([0, 0, -pboxBLipHeight])
          powderbox_blip(lipid);
      translate([0, 0, pboxSideHeight])
           powderbox_tlip(lipid);
      translate([pboxSideLength, 0, 0])
           powderbox_slip(lipid); 
   } else {
      translate([pboxSideWidth, 0, 0])
          rotate([-90, 0, 0])
            powderbox_blip(lipid);
      translate([0, 0, pboxSideHeight])
          rotate([90, 0, 0])
            powderbox_tlip(lipid);
      translate([pboxSideLength + pboxSideWidth*2, pboxSideWidth, 0])
          rotate([0, 0, 90])
            powderbox_slip(lipid);
   }
}

module powderbox(exploded = 0) {
   if (exploded) {
      for (i = [0:3]) {
         translate([pboxSideLength * i, 0, 0])
          powderbox_side(i, exploded);
      }
   } else {
      translate([-pboxSideWidth, 0, -(pboxSideHeight + pboxTLipWidth)]) {
        translate([0, -pboxSideWidth, 0])
           powderbox_side(2);
        translate([0, pboxSideLength, 0])
          rotate([0, 0, -90])
             powderbox_side(3);
        translate([pboxSideLength, -pboxSideWidth, 0])
           rotate([0, 0, 90])
             powderbox_side(0);
        translate([pboxSideLength, pboxSideLength, 0])
           rotate([0, 0, 180])
             powderbox_side(1);
      }
   }
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
  
     translate([300, 0, -250])
     powderbox(1);
} else {
    powderbed_frame();

    powderbed_xrail();

    // jack_clearance();

    // translate([- (frameMiddleWidth + pistonHeight), 0, 0])
        // jack_clearance();

    translate([pboxSideWidth, (frameMiddleLength - pboxSideLength)/2, 0])
    powderbox(0);

    translate([-(pboxSideWidth+frameMiddleWidth), (frameMiddleLength + pboxSideLength)/2, 0])
    rotate([0, 0, 180])
    powderbox(0);
}

// vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab:
