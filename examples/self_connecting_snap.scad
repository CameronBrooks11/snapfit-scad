// A disc with a pin on top and a hole underneath, so copies stack.
// Seated, each copy rests on the foot of the one below, 10 mm higher.
use <../snapfit.scad>;

/* [Disc] */
// Disc diameter (mm)
w = 10; // [6:1:30]
// Disc height (mm)
h = 5; // [2:0.5:15]

/* [Pin] */
// Pin column diameter (mm)
dia = 3; // [2:0.25:8]
// How much wider the head is than the column (mm)
lip = 0.75; // [0.25:0.05:2]
// Clearance around the head in the hole (mm)
neg_tol = 0.5; // [0.1:0.05:1]
// Gap between the foot and the head: the plate the head snaps past (mm)
thickness = 1; // [0.5:0.1:3]

/* [Hidden] */
col_h = dia * 2;
$fn = 64;

difference() {
  union() {
    cylinder(d = w, h = h, center = true);
    translate([0, 0, h / 2]) snapfit(dia, lip, col_h, 0.1, 0.7, thickness = thickness);
  }
  translate([0, 0, -h / 2 - 0.1]) snapfit_neg(dia, lip, col_h, neg_tol, 0.7, thickness = thickness);
}
