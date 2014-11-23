// All units are in mm
inchTOmm = 25.4;

isExploded = 0;

// Width of the powderbox sheet-metal material
// 22 Guage = 0.759mm
smWidth = 0.759;

lipWidth = 15;

pboxBLipWidth = smWidth;
pboxBLipHeight = lipWidth*2;

module powderbox_blip(sz, lipid = 0) {
    color([0.8, 0.0, 0.8])
    if (lipid == 1 || lipid == 3) {
        cube([sz[1], pboxBLipWidth, pboxBLipHeight]);
    } else {
        cube([sz[0], pboxBLipWidth, pboxBLipHeight]);
    }
}

pboxTLipWidth = smWidth;
pboxTLipHeight = lipWidth;

module powderbox_tlip(sz, lipid = 0) {
    if (lipid != 3) {
      color([0.8, 0.0, 0.1])
      if (lipid == 1 || lipid == 3) {
        cube([sz[1], pboxTLipWidth, pboxTLipHeight]);
      } else {
        cube([sz[0], pboxTLipWidth, pboxTLipHeight]);
      }
    }
}

module powderbox_slip(sz, lipid = 0) {
   pboxSLipWidth = smWidth;
   pboxSLipHeight = sz[2];
   pboxSLipLength = 36*inchTOmm - sz[1]*2 - sz[2]*2;
   if (lipid == 3) {
     color([0.8, 0.0, 1.0])
       cube([pboxSLipLength, pboxSLipWidth, pboxSLipHeight]);
   }
}

module powderbox_side(sz, lipid = 0, exploded = 0) {
    color([0.8, 0.0, 0.4]) {
     if (lipid == 0) {
       cube([sz[0], smWidth, sz[2]]);
     } else if (lipid == 1) {
      cube([sz[1], smWidth, sz[2]]);
     } else if (lipid == 2) {
      cube([sz[0], smWidth, sz[2]]);
     } else if (lipid == 3) {
      cube([sz[1], smWidth, sz[2]+smWidth]);
     }
   if (exploded) {
      translate([0, 0, -pboxBLipHeight])
          powderbox_blip(sz, lipid);
      translate([0, 0, sz[2]])
           powderbox_tlip(sz, lipid);
      translate([sz[1], 0, 0])
           powderbox_slip(sz, lipid); 
   } else {
      translate([smWidth, 0, 0])
          rotate([-90, 0, 0])
            powderbox_blip(sz, lipid);
      translate([0, 0, sz[2]])
          rotate([90, 0, 0])
            powderbox_tlip(sz, lipid);
      translate([sz[1] + smWidth*2, smWidth, 0])
          rotate([0, 0, 90])
            powderbox_slip(sz, lipid);
   }
  }
}

module powderbox(sz, exploded = 0) {
   if (exploded) {
         translate([0, 0, 0])
          powderbox_side(sz, 0, exploded);
         translate([sz[0], 0, 0])
          powderbox_side(sz, 1, exploded);
         translate([sz[0] + sz[1], 0, 0])
          powderbox_side(sz, 2, exploded);
         translate([sz[0]*2 + sz[1], 0, 0])
          powderbox_side(sz, 3, exploded);  
   } else {
      translate([0, 0, -(sz[2] + pboxTLipWidth)]) {
         translate([0, 0, 0])
           powderbox_side(sz, 0);
         translate([sz[0], 0, 0])
          rotate([0, 0, 90])
             powderbox_side(sz, 1);
         translate([sz[0], sz[1], 0])
           rotate([0, 0, 180])
             powderbox_side(sz, 2);
         translate([0, sz[1], 0])
           rotate([0, 0, -90])
             powderbox_side(sz, 3);
      }
   }
}

// These are the internal dimensions of the box, not
// the external dimensions
powderbox([240, 200, 250], isExploded);
