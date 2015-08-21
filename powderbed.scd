// BrundleFab Powder Bed MDF assembly
// Copyright 2015, Jason S. McMullan <jason.mcmullan@gmail.com>
//
// Licensed under the MIT License:
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.

// All units are in mm
inchTOmm = 25.4;

isExploded = 0;

// Width of the MDF material
mdfWidth = 17;

// Width of the sheet-metal material
smWidth = 1/16 * inchTOmm;


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
frameSideBottomLength = frameMiddleWidth;
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

pboxTLipWidth = smWidth;
pboxTLipHeight = mdfWidth;
pboxTLipLength = pboxSideLength;

pboxSLipWidth = smWidth;
pboxSLipHeight = pboxSideHeight;
pboxSLipLength = mdfWidth;

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

    powderbed_xrail();
    
}

// vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab:
