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
smWidth = 0.01 * inchTOmm;
// 90 degree bend material needed
smBend90 = smWidth/2;
// Minium sheet metal cut
smCut = smWidth*4;

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
lcWidth = lsHeight * 2 + smBend90 + smCut;

// Length of the light chamber
lcLength = 260 - 2 * lsHeight;

// Height of the overhang
ofHeight = 16;

// Width of the pen carriage
pcWidth = 63;
// Height of the pen carriage
pcHeight = 40;

// Width of the pen carriage rail
prWidth = 14;
// Height of the pen carriage rail
prHeight = 10;

// Width of the pen holder
penWidth = 25;
// Height of the pen holder
penHeight = 55;
// Descention below carriage
penDepth = 8;

// Height of the seal
sealHeight = 10;

// Width of bolt/drill diameter
boltWidth = 3;

// IR Sensor hole size
irHole = 20;

// IR Sensor center
midBack = hbWidth + lmWidth + lcWidth + lmWidth;
midFront = pbWidth - (pcWidth + penWidth);
irOffset = midBack + (midFront - midBack - irHole)/2;

// IR Sensor inset
irInset = mdfWidth * 2;

///////////// Sheet metal manipulations ///////////////////

// Drill a hold for the 'standard bolt'
module drill()
{
	drillRes = 10;
	translate([0, 0, -smWidth])
		scale([1/drillRes, 1/drillRes, smWidth*3]) 
			cylinder(r = boltWidth*drillRes/2);
}

// Drill a pilot hold for the 'standard screw'
module pilot()
{
	scale([1/3, 1/3, 1]) drill();
}

// Bend along the Y axis, taking into account sheet metal bed radii offsets
module y_bend(angle, isFlat = true)
{
	translate([isFlat ? smBend90 : 0, 0, 0])
	if (angle < 0) {
		translate([isFlat ? 0 : sin(-angle)*smWidth, 0, isFlat ? 0 : cos(angle)*smWidth])
		rotate([0, isFlat ? 0 : angle, 0])
		children();
	} else {
		rotate([0, isFlat ? 0 : angle, 0])
		children();
	}		
}


// Gap between inner and outer light chamber
lcGap = 5;
// Height of inner light chamber
lcHeight = 10;

lcOffset = (pbLength - lcLength) / 2;

// Inner light chamber shield and halogen holder
module lc_holder(isFlat = false)
{
  	translate([-lmWidth, 0, 0]) {
		difference() {
			cube([lmWidth, pbLength, smWidth]);
	  		// Light chamber heat shield front mountings
	  		translate([lmWidth/2, boltWidth*3, 0]) pilot();
			translate([lmWidth/2, pbLength/2, 0]) pilot();
			translate([lmWidth/2, pbLength - boltWidth*3, 0]) pilot();
		}

		translate([lmWidth, 0, 0]) 
		y_bend(-60, isFlat) {
			cube([lcHeight*sin(60), pbLength, smWidth]);
			translate([lcHeight*sin(60), 0, 0])
			y_bend(60, isFlat) {
				cube([lcWidth - 2*cos(60)*lcHeight, pbLength, smWidth]);
				translate([lcWidth - 2*cos(60)*lcHeight, 0, 0])
				y_bend(60, isFlat) {
					cube([lcHeight*sin(60), pbLength, smWidth]);		
					translate([lcHeight*sin(60), 0, 0]) 
					y_bend(-60, isFlat) {
						difference() {
							cube([lmWidth, pbLength, smWidth]);		
	  						// Light chamber heat shield front mountings
	  						translate([lmWidth/2, boltWidth*3, 0]) pilot();
							translate([lmWidth/2, pbLength/2, 0]) pilot();
							translate([lmWidth/2, pbLength - boltWidth*3, 0]) pilot();
						}
					}
				}
			}
		}
	}
}

loHeight = lcHeight + lcGap + smWidth;
loMount = lmWidth - lcGap;


// Outer light chamber shield
module lc_shield(isFlat = true)
{
	difference() {
			cube([loMount, pbLength, smWidth]);
  
	  		// Light chamber heat shield rear mountings
	  		translate([lmWidth/2, boltWidth*3, 0]) drill();
			translate([lmWidth/2, pbLength/2, 0]) drill();
			translate([lmWidth/2, pbLength - boltWidth*3, 0]) drill();
	}
	translate([loMount, 0, 0])
	y_bend(-60, isFlat) {
		cube([loHeight*sin(60), pbLength, smWidth]);
		translate([loHeight*sin(60), 0, 0])
		y_bend(60, isFlat) {
			cube([lcWidth + smWidth + lcGap*2 - 2*cos(60)*loHeight, pbLength, smWidth]);
			translate([lcWidth + smWidth + lcGap*2 - 2*cos(60)*loHeight, 0, 0])
			y_bend(60, isFlat) {
				cube([loHeight*sin(60), pbLength, smWidth]);
				translate([loHeight*sin(60), 0, 0])
				y_bend(-60, isFlat) {
					difference() {
						cube([loMount, pbLength, smWidth]);
  
				  		// Light chamber heat shield rear mountings
						translate([loMount - lmWidth, 0, 0]) {
				  			translate([lmWidth/2, boltWidth*3, 0]) drill();
							translate([lmWidth/2, pbLength/2, 0]) drill();
							translate([lmWidth/2, pbLength - boltWidth*3, 0]) drill();
						}
					}					
				}
			}
		}
	}
}


module lh_shader()
{
	cube([lsHeight, lcLength-smCut*2, smWidth]);
}

// Width of print carriage retaining flaps
pfWidth = 30;

// Height of print carriage retaining flaps
pfHeight = prWidth/2 - smCut/2;


// Offset of the rear of the pen carriage rail
prOffset = pbWidth - (penWidth + pcWidth);

// Pen carriage ghost (debug only)
module pc_ghost()
{
	// Carriage rail mount ghost
	cube([prWidth, pbLength + mdfWidth*2, prHeight]);

	// Pen carriage ghost
	translate([0, 0, prHeight])
		cube([pcWidth, pbLength + mdfWidth*2, pcHeight]);

	// Pen
	translate([pcWidth, 0, -penDepth]) 
		difference() {
			cube([penWidth, pbLength + mdfWidth*2, penHeight]);
			translate([-1, -1, -1])
			cube([12+2, pbLength + mdfWidth*2+2, penDepth+2]);
		}
}

module lh_irmount(isFlat = true)
{
	// Light shield
	translate([0, smCut, 0])
	y_bend(90, isFlat)
	cube([irHole/2-smWidth/2, irHole-smCut*2, smWidth]);

	// Thermopile front retention flap
	translate([irHole/2, isFlat ? smBend90 : smWidth, 0])
		rotate([isFlat ? 0 : 90, 0, 0])
			translate([smCut/2,0,0])
			difference() {
				cube([irHole/2-smCut*1.5, irHole/2-smCut/2, smWidth]);
				translate([irHole/4-smCut, irHole/4, 0])
				drill();
			};

	// Thermopile back retention flap
	translate([irHole/2, isFlat ? (irHole/2-smBend90) : irHole, 0])
		rotate([isFlat ? 0 : 90, 0, 0])
			translate([smCut/2,smCut/2,0])
			difference() {
				cube([irHole/2-smCut*1.5, irHole/2-smCut/2, smWidth]);
				translate([irHole/4-smCut, irHole/4, 0])
				drill();
			};

   // Ghost IR device
	if (!isFlat) {
		% translate([irHole/2, irHole/2, smWidth]) {
				scale([1,1,12]) cylinder(r=18.5/2);
				translate([0, 0, 12]) {
					scale([1, 1, 22]) cylinder(r=23.5/2);
					translate([-25/2, -33/2, 22]) {
						cube([25, 33, 3.5]);
					}
				}
			}
	}
			
}

// Layerhead Plate
module lh_plate(isFlat = true)
{
  difference() {
		cube([pbWidth - penWidth,
			mdfWidth*2 + pbLength, smWidth]);

     translate([0, mdfWidth, 0]) {
			// Heat break & emergency powder return
			//* 
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
			translate([hbWidth + lmWidth, 0, -smWidth])
				cube([lcWidth, pbLength, 3*smWidth]);


	  		// Light chamber heat shield front mountings
	  		translate([hbWidth + lmWidth + lcWidth + lmWidth/2, boltWidth*3, 0]) drill();
			translate([hbWidth + lmWidth + lcWidth + lmWidth/2, pbLength/2, 0]) drill();
			translate([hbWidth + lmWidth + lcWidth + lmWidth/2, pbLength - boltWidth*3, 0]) drill();

			// Hole for the IR sensor
			translate([irOffset, irInset, -smWidth])
					cube([irHole, irHole, 3*smWidth]);

			// Hole for carriage mounts - debug only
			if (false) {
			  translate([pbWidth - (penWidth + pcWidth),0, 0])
					cube([pcWidth, pbLength, smWidth]);

			}
			// Carriage mount flap holes
			translate([prOffset - 2*smWidth, 0, -smWidth]) {
				for (i = [ 0 : 2 : 2]) {
					// Flap hole
					translate([0, pbLength/5 * (i+1), 0])
					cube([prWidth+smWidth*4, pfWidth+smCut*2, smWidth*3]);
				}
			}	
		}
	}

	// Side rail guildes
	translate([0, isFlat ? -(ofHeight + smBend90) : -smWidth, 0])
	  rotate([isFlat ? 0 : -90, 0, 0])
			lh_guide();
	translate([0, mdfWidth*2 + pbLength + (isFlat ? smBend90 : 0), 0])
		rotate([isFlat ? 0 : -90, 0, 0])
			lh_guide();


	// Carriage mount flaps
	translate([prOffset - 2*smWidth, mdfWidth, 0]) {
		for (i = [ 0 : 2 : 2]) {
			// Rear flap
			translate([0, smCut + pbLength/5 * (i+1), isFlat ? 0 : smWidth])
				y_bend(-90, isFlat)
				cube([pfHeight, pfWidth, smWidth]);

			// Front flap
			translate([prWidth + smWidth*4 + (isFlat ? -smBend90 : 0), smCut + pbLength/5 * (i+1), smWidth])
				rotate([0, isFlat ? -180 : -90,0])
				cube([pfHeight, pfWidth, smWidth]);
		}
	}

	// Light shader flaps
	translate([hbWidth + lmWidth, mdfWidth, 0]) {

		translate([smCut, isFlat ? smBend90 : 0, 0])
		rotate([isFlat ? 0 : -90, 0, 0])
			cube([lcWidth - smCut*2, lsHeight, smWidth]);

		translate([smCut, pbLength - (isFlat ? smBend90 : 0), isFlat ? smWidth : 0])
		rotate([isFlat ? 180 : -90, 0, 0])
			cube([lcWidth - smCut*2, lsHeight, smWidth]);

		// Rear shader
		translate([0, smCut + (pbLength - lcLength) / 2, 0])
		y_bend(90, isFlat)
			lh_shader();

		// Front shader
		translate([lcWidth, smCut + (pbLength - lcLength) / 2, 0])
		translate([isFlat ? -(lsHeight + smBend90*2) : -smWidth, 0, 0])
		y_bend(90, isFlat)
			lh_shader();
	}

	// Infrared mounting
	translate([irOffset, mdfWidth + irInset, 0])
	lh_irmount(isFlat);

	translate([pbWidth - penWidth, 0, 0])
	children();
}

module lh_guide()
{
	cube([pbWidth - penWidth, ofHeight, smWidth]);
}

module lh_seal(isFlat = true)
{
	y_bend(45, isFlat)
		cube([sealHeight/cos(45), pbLength - smWidth*2, smWidth]);
}

module lh_recoat()
{
	cube([pbDepth, pbLength - smWidth*2, smWidth]);
	translate([pbDepth, 0, 0])
	children();
}

module layerhead(isFlat = true)
{
  translate([isFlat ? -pbDepth : -smWidth, mdfWidth, isFlat ? 0 : -pbDepth])
	y_bend(-90, isFlat)
	lh_recoat()
	translate([0, -mdfWidth, 0])
	y_bend(90, isFlat)
	lh_plate(isFlat)
	translate([0, mdfWidth, 0])
	lh_seal(isFlat);


   color([0.8,0,0.8]) 
	translate([(isFlat ? pbWidth + lcWidth : (hbWidth + lmWidth)), mdfWidth, isFlat ? 0 : smWidth])
			lc_holder(isFlat);

   color([0,0.5,0.5])
		translate([isFlat ? (pbWidth + lcWidth * 4) : hbWidth, mdfWidth, isFlat ? 0 : smWidth*2])
			lc_shield(isFlat);

	if (!isFlat) {
   	% translate([prOffset, 0, smWidth])
			pc_ghost();
		% translate([hbWidth + lmWidth + lcWidth/2, mdfWidth, lcHeight/2-2.5/2])
			rotate([-90, 0, 0]) scale([1, 1, pbLength]) cylinder(r=2.5);
	}
}

//isFlat=true;
if (isFlat) {
  // projection(cut=true) translate([0, 0, -smWidth])
		layerhead(isFlat);
} else {
	layerhead(isFlat);
}

