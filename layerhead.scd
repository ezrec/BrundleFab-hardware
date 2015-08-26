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

/////// Material Parameters ///////////

// Width of the sheet-metal material
smWidth = 0.01 * inchTOmm;
// 90 degree bend material needed
smBend90 = smWidth/2;
// Minium sheet metal cut
smCut = smWidth*4;

// Stiffening bar width
sbWidth = 3/4 * inchTOmm;
// Stiffening bar height
sbHeight = 1/8 * inchTOmm;

// Width of the MDF
mdfWidth = 16;

// Width of bolt/drill diameter
boltWidth = 3;

/////// Fittment Parameters ///////////

// Length of the piston chamber (Y axis)
pbLength = 260;

// Width of the piston chamber (X axis)
pbWidth = 195;

// Depth from layerhead to powder
pbDepth = 15;

// Width of the powder heat break
hbWidth = 15;

// Height of the guide rail overhang
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

// Width of print carriage retaining flaps
pfWidth = 30;

// Height of the seal
sealHeight = 10;

// IR Sensor hole size
irHole = 20;

// Gap between light chamber and heat shield
lcGap = 6;

//////////// Calculated ///////////////

// Height of the light chamber shadow mask
lsHeight = pbDepth * 0.80;

// Width of the light chamber cutout
lcWidth = lsHeight * 2 + 2 * smBend90 + smCut;

// Length of the light chamber
lcLength = pbLength - 2 * lsHeight;

// Width of the light chamber mounts
lmWidth = sbWidth;

// IR Sensor center
midBack = hbWidth + lmWidth + lcWidth + lmWidth;
midFront = pbWidth - (pcWidth + penWidth);
irWidth = midFront - midBack;
irOffset = midBack + (irWidth - irHole)/2;

// IR Sensor inset
irInset = mdfWidth * 2;

// Height of outer light chamber
lcHeight = lcWidth/2 + lcGap;

lcOffset = (pbLength - lcLength) / 2;

///////////// Sheet metal manipulations ///////////////////

// Drill a hold for the 'standard bolt'
module drill(radius = boltWidth/2)
{
	drillRes = 10;

	if (isFlat) {
		translate([-radius, -radius, -100])
		cube([radius*2, radius*2, 300]);
	} else {
		translate([0, 0, -100])
		scale([1/drillRes, 1/drillRes, 300])
			cylinder(r = radius*drillRes);
	}
}

// Drill a pilot hold for the 'standard screw'
module pilot(radius = boltWidth/4)
{
	drill(radius);
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

// Generate a half-pipe
module y_pipe(radius, isFlat = true)
{
	if (isFlat) {
		cube([radius * PI + smWidth, 1, smWidth]);
		translate([radius * PI + smWidth, 0, 0])
			children();
	} else {
		rotate([0, -90, 0])
		translate([radius + smWidth, 1, 0])
		rotate([90, 0, 0]) {
			difference() {
				cylinder(r = radius + smWidth);
				translate([0, 0, -1]) scale([1, 1, 3]) cylinder(r = radius);
				translate([-(radius + smWidth + 1), -(radius + smWidth + 1), 0])
					cube([(radius + smWidth + 1)*2, (radius + smWidth + 1), 1]);
			}
		}

		translate([-smWidth, 0, (radius + smWidth)*2])
			children();
	}
}

// Flat of sheet metal
module y_flat(width, isFlat = true)
{
	cube([width, 1, smWidth]);
	translate([width, 0, 0])
		children();
}

////////////////////// Layerhead Components /////////////////

module lc_mount()
{
	// Light chamber heat shield front mountings
	translate([lmWidth/2, boltWidth*3, 0]) children();
	translate([lmWidth/2, pbLength/2, 0]) children();
	translate([lmWidth/2, pbLength - boltWidth*3, 0]) children();
}

// Inner light chamber shield and halogen holder
module lc_holder(isFlat = false)
{
  	translate([-lmWidth, 0, 0]) {
		difference() {
			cube([lmWidth, pbLength, smWidth]);
	  		// Light chamber heat shield front mountings
			lc_mount() pilot();
		}

		scale([1, pbLength, 1])
		translate([lmWidth, 0, 0])
		y_bend(90, isFlat)
		y_pipe(lcWidth/2, isFlat)
		y_bend(-90, isFlat)
		difference() {
			y_flat(lmWidth, isFlat);
	  		// Light chamber heat shield front mountings
			scale([1, 1/pbLength, 1]) {
				lc_mount() pilot();
			}
		}
	}
}

loHeight = lcHeight + lcGap + smWidth - sbHeight;
loMount = lmWidth - lcGap;

// Outer light chamber shield
module lc_shield(isFlat = true)
{
	difference() {
			cube([loMount, pbLength, smWidth]);

	  		// Light chamber heat shield rear mountings
			lc_mount() drill();
	}
	translate([loMount, 0, 0])
	scale([1, pbLength, 1])
	y_bend(-60, isFlat)
	y_flat(loHeight*sin(60), isFlat)
	y_bend(60, isFlat)
	y_flat(lcWidth + lcGap*2 - sin(60)*(loHeight + smWidth), isFlat)
	y_bend(60, isFlat)
	y_flat(loHeight*sin(60), isFlat)
	y_bend(-60, isFlat)
	difference() {
		y_flat(loMount, isFlat);

		// Light chamber heat shield rear mountings
		scale([1, 1/pbLength, 1])
		translate([loMount - lmWidth, 0, 0]) {
			lc_mount() drill();
		}
	}
}


module lh_shader()
{
	cube([lsHeight, lcLength-smCut*2, smWidth]);
}

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
	cube([irHole/2-smCut/2, irHole-smCut*2, smWidth]);

	// Thermopile front retention flap
	translate([irHole/2, isFlat ? smBend90 : smWidth, 0])
		rotate([isFlat ? 0 : 90, 0, 0])
			translate([smCut,0,0])
			difference() {
				cube([irHole/2-smCut*2, irHole/2-smCut, smWidth]);
				translate([(irHole/2-smCut*2)/2, (irHole/2-smCut)/2, 0])
				drill();
			};

	// Thermopile back retention flap
	translate([irHole/2 + smCut, isFlat ? (irHole-smBend90) : irHole, isFlat ? smWidth : 0])
		rotate([isFlat ? 180 : 90, 0, 0])
			difference() {
				cube([irHole/2-smCut*2, irHole/2-smCut, smWidth]);
				translate([(irHole/2-smCut*2)/2, (irHole/2-smCut)/2,0])
				drill();
			};
}

module lh_irsensor() {
		translate([irHole/2, irHole/2, smWidth]) {
				scale([1,1,12]) cylinder(r=18.5/2);
				translate([0, 0, 12]) {
					scale([1, 1, 22]) cylinder(r=23.5/2);
					translate([-25/2, -33/2, 22]) {
						cube([25, 33, 3.5]);
					}
				}
		}
}

module lh_irplug() {
	translate([-(irWidth - irHole - smCut*2)/2, -(irWidth - irHole - smCut*2)/2, smWidth])
	difference() {
		cube([irWidth - smCut*2, irWidth - smCut*2, smWidth]);
		translate([((irWidth - smCut*2) - irHole)/2, ((irWidth - smCut*2) - irHole)/2, 0]) {
			 translate([irHole/2+smCut, -(smCut-smWidth)/2, -smWidth])
				cube([irHole/2-smCut*2, smCut, smWidth*3]);
			 translate([irHole/2+smCut, irHole-smCut+(smCut-smWidth)/2, -smWidth])
				cube([irHole/2-smCut*2, smCut, smWidth*3]);
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
		  for (h = [ 0 : hbWidth/3 : pbLength - hbWidth/3]) {
				translate([hbWidth/3, hbWidth/3 + h, 0])
					drill((hbWidth/3 - smCut)/2);
				translate([hbWidth/3*2, hbWidth/3*1.5 + h, 0])
					drill((hbWidth/3 - smCut)/2);
			}

	  		// Light chamber heat shield rear mountings
			translate([hbWidth, 0, 0])
				lc_mount() drill();

			// Light chamber cutout
			translate([hbWidth + lmWidth, 0, -smWidth])
				cube([lcWidth, pbLength, 3*smWidth]);


	  		// Light chamber heat shield front mountings
			translate([hbWidth + lmWidth + lcWidth, 0, 0])
				lc_mount() drill();
ill();

			// Holes for the IR sensor
			translate([irOffset, irInset, -smWidth])
					cube([irHole, irHole, 3*smWidth]);

			translate([irOffset, pbLength/2 - irHole/2, -smWidth])
					cube([irHole, irHole, 3*smWidth]);

			translate([irOffset, pbLength - (irInset + irHole), -smWidth])
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

	// Infrared mounting - 3 options
	translate([irOffset, mdfWidth + irInset, 0]) {
		lh_irmount(isFlat);
		if (!isFlat) % lh_irplug();
	}

	translate([irOffset, mdfWidth + pbLength/2 - irHole/2, 0]) {
		lh_irmount(isFlat);
		if (!isFlat) % lh_irsensor();
	}

	translate([irOffset, mdfWidth + pbLength - (irInset + irHole), 0]) {
		lh_irmount(isFlat);
		if (!isFlat) % lh_irplug();
	}

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

}

module lc_stiffener()
{
	difference() {
		cube([sbWidth, pbLength, sbHeight]);
		lc_mount() drill();
	}
}

if (isFlat) {
  // Uncomment for DXF export
  // projection(cut=true) translate([0, 0, -smWidth])
  {
		layerhead(isFlat);
		translate([pbWidth * 1.2, 0, 0])
		lc_holder(isFlat);
		translate([pbWidth + lcWidth * 4, 0, 0])
		lc_shield(isFlat);
		translate([pbWidth + lcWidth * 8, 0, 0])
			lh_irplug();
		translate([pbWidth + lcWidth * 8, irWidth, 0])
			lh_irplug();
		translate([pbWidth + lcWidth * 8, irWidth*2, 0])
			lh_irplug();
	}
} else {
	layerhead(isFlat);


  color([0.8,0,0.8])
	translate([hbWidth + lmWidth, mdfWidth, smWidth])
			lc_holder(isFlat);

	color([0,0.6,0])
	  translate([hbWidth + lmWidth - sbWidth, mdfWidth, smWidth * 2]) {
			lc_stiffener();
			translate([sbWidth + lcWidth, 0, 0])
				lc_stiffener();
				
		}

   color([0,0.5,0.5])
		translate([hbWidth, mdfWidth, smWidth*2 + sbHeight])
			lc_shield(isFlat);


   % translate([prOffset, 0, smWidth])
		pc_ghost();

	% translate([hbWidth + lmWidth + lcWidth/2, mdfWidth, (lcWidth/2-2.5)/2])
		rotate([-90, 0, 0]) scale([1, 1, pbLength]) cylinder(r=2.5);
}

