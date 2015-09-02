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

/*
	// Metric M3
	boltWidth = 3;
	nutHeight = 2.25;
	nutWidth = 6;
*/
/**/
	// US 4/40
	boltWidth = 0.112 * inchTOmm;
	nutHeight = 0.066 * inchTOmm;
	nutWidth = 0.217 * inchTOmm;
/**/

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

// IR Sensor field of view (degrees)
irFOV = 110;

// IR Sensor (MLX90614) mounting
imWidth = 45;
imLength = 45;
imHeight = 1;
imMount = 5; // Inset from corners for the mounting
imSensor = 6; // Distance from edge to center of sensor

irRadius = 4.5; // Radius of sensor
irHeight = 5;

// Gap between light chamber and heat shield
lcGap = 4;

// Width of the light chamber cutout
lcWidth = 20;

//////////// Calculated ///////////////

// Height of the light chamber shadow mask
lsHeight = (lcWidth - 2*smBend90 - smCut)/2;

// Length of the light chamber
lcLength = pbLength - 2 * lsHeight;

// Width of the light chamber mounts
lmWidth = sbWidth;

// IR Sensor center (150% oversize)
irHole = irRadius*2 * 1.5;

// IR Sensor base plate mounting location
imBaseX = hbWidth + lmWidth + lcWidth + lmWidth/2 - imMount;
imBaseY = pbLength/2 + imMount - imLength;

// IR Sensor view hole location
irHoleX = imBaseX + imWidth - imSensor - irRadius - irHole/2;
irHoleY = imBaseY + imLength/2 - irHole/2;

// Height of outer light chamber
lcHeight = lcWidth/2 + lcGap;

lcOffset = (pbLength - lcLength) / 2;

///////////// Sheet metal manipulations ///////////////////

// Drill a hole for the 'standard bolt'
module drill(radius = boltWidth/2)
{
	drillRes = 10;

	if (isFlat) {
		translate([-radius * 1.10, -radius * 1.10, -100])
		cube([radius*2*1.10, radius*2*1.10, 300]);
	} else {
		translate([0, 0, -100])
		scale([1/drillRes, 1/drillRes, 300])
			cylinder(r = radius*drillRes*1.10);
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

	translate([0, 0, isFlat ? 0 : (angle < 0 ? smWidth : 0)])
	rotate([0, isFlat ? 0 : angle, 0])
	translate([0, 0, isFlat ? 0 : (angle < 0 ? -smWidth : 0)])
	children();	
}

// Generate a half-pipe - radius is _outer_ radius
module y_pipe(radius, isFlat = true)
{
	if (isFlat) {
		translate([smBend90, 0, 0])
		cube([radius * PI, 1, smWidth]);
		translate([smBend90 + radius * PI + smBend90, 0, 0])
			children();
	} else {
		translate([0, 0, smWidth])
		rotate([0, 90, 0])
		translate([radius, 1, 0])
		rotate([90, 0, 0]) {
			difference() {
				cylinder(r = radius);
				translate([0, 0, -1]) scale([1, 1, 3]) cylinder(r = radius - smWidth);
				translate([-(radius + smWidth + 1), -(radius + smWidth + 1), -1])
					cube([(radius + smWidth + 1)*2, (radius + smWidth + 1), 3]);
			}
		}

		translate([0, 0, -radius*2+smWidth*2])
			rotate([0, 180, 0]) 
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

////////////////////// Arduino Mega 2560 Ghost //////////////

arduinoDrill = 3.2 / 2;

megaHoles = [
  [  2.54, 15.24 ],
  [  17.78, 66.04 ],
  [  45.72, 66.04 ],
  [  50.8, 13.97 ],
  [  2.54, 90.17 ],
  [  50.8, 96.52 ]
];

megaShape = [ 
  [  0.0, 0.0 ],
  [  53.34, 0.0 ],
  [  53.34, 99.06 ],
  [  52.07, 99.06 ],
  [  49.53, 101.6 ],
  [  15.24, 101.6 ],
  [  12.7, 99.06 ],
  [  2.54, 99.06 ],
  [  0.0, 96.52 ]
  ];

module arduino_mega()
{
	difference() {
		polygon(megaShape);
		for (i = megaHoles) {
			translate(i) drill(arduinoDrill);
		}
	}
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
  	translate([-lmWidth, smCut, 0]) {
		difference() {
			cube([lmWidth + smCut, pbLength-smCut*2, smWidth]);
	  		// Light chamber heat shield front mountings
			translate([0, -smCut, 0]) lc_mount(smCut*2) drill();
		}

		translate([lmWidth + smCut, 0, 0])
		scale([1, pbLength - smCut*2, 1])
		y_bend(-90, isFlat)
		y_flat(smWidth + nutHeight + smWidth, isFlat)
		y_pipe((lcWidth-smCut*2)/2, isFlat)
		y_flat(smWidth + nutHeight + smWidth, isFlat)
		y_bend(-90, isFlat)
		difference() {
			y_flat(lmWidth + smCut, isFlat);
	  		// Light chamber heat shield front mountings
			translate([smCut, 0, 0])
			scale([1, 1/(pbLength - smCut*2), 1])
			translate([0, -smCut, 0]) {
				lc_mount() drill();
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


module lh_irsensor_HB808()
{
		scale([1,1,12]) cylinder(r=18.5/2);
		translate([0, 0, 12]) {
			scale([1, 1, 22]) cylinder(r=23.5/2);
			translate([-25/2, -33/2, 22]) {
				cube([25, 33, 3.5]);
			}
		}
}

module lh_irsensor_drill_MLX90614()
{
	translate([imMount,imMount,-1]) drill();
	translate([imWidth - imMount,imMount,-1]) drill();
	translate([imMount, imWidth - imMount , -1]) drill();
	translate([imWidth-imMount, imWidth - imMount,-1]) drill();
}	

module lh_irsensor_MLX90614()
{
	difference() {
		union() {
			cube([imWidth, imWidth, 1]);
			translate([imWidth-(imSensor+irRadius), imWidth/2, -5])
				scale([1, 1, 5]) cylinder(r=irRadius);
		}
		lh_irsensor_drill_MLX90614();
	}
}

module lh_irsensor()
{
	lh_irsensor_MLX90614();
}

module lh_irdrill()
{
	lh_irsensor_drill_MLX90614();
}

module lh_irmount(isFlat = true)
{
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

			// Hole for the IR sensor
			translate([irHoleX, irHoleY, -smWidth])
					cube([irHole, irHole, 3*smWidth]);

			// IR sensor additional mount points
			translate([imBaseX, imBaseY, 0]) lh_irdrill();

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

	// Light chamber flaps
	translate([hbWidth + lmWidth, mdfWidth, 0]) {

		translate([smCut, isFlat ? smBend90 : 0, 0])
		rotate([isFlat ? 0 : -90, 0, 0])
			cube([lcWidth - smCut*2, lsHeight, smWidth]);

		translate([smCut, pbLength - (isFlat ? smBend90 : 0), isFlat ? smWidth : 0])
		rotate([isFlat ? 180 : -90, 0, 0])
			cube([lcWidth - smCut*2, lsHeight, smWidth]);
	}

	// Infrared mounting folds
	translate([imBaseX, mdfWidth + imBaseY, 0]) {
		lh_irmount(isFlat);
	}
	if (!isFlat) {
		% translate([imBaseX, mdfWidth + imBaseY, sbHeight+smWidth+nutHeight])
			lh_irsensor();
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
	translate([0, -mdfWidth, 0])
	difference() {
		cube([sbWidth, pbLength + mdfWidth*2, sbHeight]);
		translate([0, mdfWidth, 0]) lc_mount() drill();
	}
}

if (isFlat) {
  // Uncomment for DXF export
  // projection(cut=true) translate([0, 0, -smWidth])
  {
		layerhead(isFlat);
		translate([pbWidth * 1.2, 0, 0])
		lc_holder(isFlat);
		translate([pbWidth + lcWidth * 5, 0, 0])
		lc_shield(isFlat);
		translate([pbWidth + lcWidth * 9, 0, 0])
		lc_stiffener();
		translate([pbWidth + lcWidth * 11, 0, 0])
		lc_stiffener();
	}
} else {
	layerhead(isFlat);


  color([0.8,0,0.8])
	translate([hbWidth + lmWidth, mdfWidth, -(smWidth + nutHeight)])
			lc_holder(isFlat);

	color([0,0.6,0])
	  translate([hbWidth + lmWidth - sbWidth, mdfWidth, smWidth]) {
			lc_stiffener();
			translate([sbWidth + lcWidth, 0, 0])
				lc_stiffener();
				
		}

   color([0,0.5,0.5])
		translate([hbWidth, mdfWidth, smWidth + sbHeight])
			lc_shield(isFlat);


   % translate([prOffset, 0, smWidth])
		pc_ghost();

	% translate([hbWidth + lmWidth + lcWidth/2, mdfWidth, (lcWidth/2-2.5)/2])
		rotate([-90, 0, 0]) scale([1, 1, pbLength]) cylinder(r=2.5);
}


