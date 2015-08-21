// BrundleFab Layer Head sheet metal
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

isFlat = false;

// Width of the sheet-metal material
smWidth = 1/32 * inchTOmm;

// Width of the MDF
mdfWidth = 16;

// Length of the piston chamber (Y axis)
pbLength = 260;

// Width of the piston chamber (X axis)
pbWidth = 195;

// Depth from layerhead to powder
pbDepth = 15;

// Width of the powder heat break
hbWidth = 15;

// Width of the light chamber mounts
lmWidth = 15;

// Height of the light chamber shadow mask
lsHeight = pbDepth * 0.80;

// Width of the light chamber cutout
lcWidth = lsHeight * 2 + smWidth;

// Length of the light chamber
lcLength = 260 - 26;

// Height of the overhang
ofHeight = 16;

// Width of the pen carriage
pcWidth = 65;

// Width of the pen holder
penWidth = 25;

// Height of the seal
sealHeight = 10;

// Width of bolt/drill diameter
boltWidth = 3;

// IR Sensor center
irOffset = hbWidth + 2*lmWidth + lcWidth + (pbWidth - (hbWidth + 2*lmWidth + lcWidth + pcWidth + penWidth)) / 2;

// IR Sensor inset
irInset = mdfWidth * 2;

// IR Sensor hole size
irHole = 20;

module drill()
{
	drillRes = 10;
	translate([0, 0, -smWidth])
		scale([1/drillRes, 1/drillRes, smWidth*3]) 
			cylinder(r = boltWidth*drillRes/2);
}

module lh_shader()
{
	translate([0,smWidth,0])
	cube([lsHeight, lcLength-smWidth*2, smWidth]);
}

// Layerhead Plate
module lh_plate(isFlat = true)
{
  difference() {
		cube([pbWidth - penWidth,
			mdfWidth*2 + pbLength, smWidth]);

     translate([0, mdfWidth, 0]) {
			// Heat break & emergency powder return
			for (r = [ 0 : boltWidth*2 : hbWidth - boltWidth*2 ]) {
				translate([r, 0, 0])
				for (h = [ 0 : boltWidth*2 : pbLength]) {
					translate([boltWidth, boltWidth/2 + h, 0])
						drill();
					translate([boltWidth*2, boltWidth+boltWidth/2 + h, 0])
						drill();
				}
			}

	  		// Light chamber heat shield rear mountings
	  		translate([hbWidth + lmWidth/2, boltWidth*3, 0]) drill();
			translate([hbWidth + lmWidth/2, pbLength/2, 0]) drill();
			translate([hbWidth + lmWidth/2, pbLength - boltWidth*3, 0]) drill();

			// Light chamber cutout
			translate([hbWidth + lmWidth, (pbLength - lcLength) / 2, -smWidth])
				cube([lcWidth, lcLength, 3*smWidth]);

	  		// Light chamber heat shield front mountings
	  		translate([hbWidth + lmWidth + lcWidth + lmWidth/2, boltWidth*3, 0]) drill();
			translate([hbWidth + lmWidth + lcWidth + lmWidth/2, pbLength/2, 0]) drill();
			translate([hbWidth + lmWidth + lcWidth + lmWidth/2, pbLength - boltWidth*3, 0]) drill();

			// Hole for the IR sensor
			translate([irOffset, irInset, -smWidth])
					cube([irHole, irHole, 3*smWidth]);

		}
	}

color([1,0.5,1])
	translate([hbWidth + lmWidth, mdfWidth + (pbLength - lcLength) / 2, 0])
		rotate([0, isFlat ? 0 : 90, 0]) lh_shader();

color([1,0.5,0])
	translate([hbWidth + lmWidth + lcWidth, mdfWidth + (pbLength - lcLength) / 2, 0])
		translate([isFlat ? -lsHeight : -smWidth, 0, 0])
		rotate([0, isFlat ? 0 : 90, 0]) lh_shader();

}

module lh_guide()
{
color([1,1,0])
	cube([pbWidth - penWidth, ofHeight, smWidth]);
}

module lh_seal()
{
color([1,1,0])
	translate([0,smWidth,0])
	cube([sealHeight/cos(45), pbLength - smWidth*2, smWidth]);
}

module lh_recoat()
{
color([1,1,0])
	translate([0,smWidth,0])
	cube([pbDepth, pbLength - smWidth*2, smWidth]);
}

module lh_irmount(isFlat = true)
{
color([0,1,0])
	rotate([0, isFlat ? 0 : 90, 0])
		translate([0,smWidth,0])
		cube([irHole/2-smWidth/2, irHole-smWidth*2, smWidth]);

color([0,1,1])
	translate([irHole/2, isFlat ? 0 : smWidth, 0])
		rotate([isFlat ? 0 : 90, 0, 0])
			translate([smWidth/2,0,0])
			difference() {
				cube([irHole/2-smWidth*1.5, irHole/2-smWidth/2, smWidth]);
				translate([irHole/4-smWidth, irHole/4, 0])
				drill();
			};

color([0,0,1])
	translate([irHole/2, isFlat ? irHole/2 : irHole, 0])
		rotate([isFlat ? 0 : 90, 0, 0])
			translate([smWidth/2,smWidth,0])
			difference() {
				cube([irHole/2-smWidth*1.5, irHole/2-smWidth/2, smWidth]);
				translate([irHole/4-smWidth, irHole/4, 0])
				drill();
			};
}


module layerhead(isFlat = true)
{
  translate([isFlat ? -pbDepth : -smWidth, mdfWidth, 0])
	 	rotate([0, isFlat ? 0 : 90, 0])
		lh_recoat();
	translate([0, isFlat ? -ofHeight : -smWidth, 0])
	  rotate([isFlat ? 0 : -90, 0, 0])
			lh_guide();
	lh_plate(isFlat);
	translate([0, mdfWidth*2 + pbLength, 0])
		rotate([isFlat ? 0 : -90, 0, 0])
			lh_guide();
	translate([pbWidth - penWidth, mdfWidth, 0])
	rotate([0, isFlat ? 0 : 45, 0])
		lh_seal();

	translate([irOffset, mdfWidth + irInset, 0])
		lh_irmount(isFlat);
}

// projection(cut=true)
 layerhead(isFlat);

