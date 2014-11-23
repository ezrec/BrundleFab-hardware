use <powderbox.scd>
use <BOLTS.scad>

// All units are in mm
inchTOmm = 25.4;

isExploded = 0;

// Width of the MDF material
mdfWidth = 17;

// Width of the powderbox sheet-metal material
smWidth = 1/16 * inchTOmm;

module pistonbox(sz, isExploded = 0)
{
    if (isExploded) {
    } else {
        % translate([0, 0, -sz[2]])
            cube(sz);
        translate([0, mdfWidth*2, 0])  
        powderbox([sz[0] - (mdfWidth*2), sz[1] - (mdfWidth*4), sz[2] / 2]);

    }
	 d608 = DIN625_1_dims(key="608", type="open", part_mode="default");
    translate([0, sz[1]/2, - (get_dim(d608, "B") + sz[2] - get_dim(d608, "d2"))])
      rotate([0, -90, 0])
      DIN625_1(key="608", type="open", part_mode="default");
}

// Bounding box
bbHeight = 370;
bbWidth = 270;
bbLength = 370;

echo(BOLTS_version());
pistonbox([bbLength, bbWidth, bbHeight], isExploded);

// vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab:

