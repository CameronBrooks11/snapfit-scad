// Two copies of examples/self_connecting_snap.scad, the upper OFFSET mm above
// the lower, intersected. Seated, the upper copy rests on the lower's foot:
// OFFSET = h + col_h - thickness = 10, and nothing should overlap.
use <../snapfit.scad>;

OFFSET = 10;

w = 10;
h = 5;
dia = 3;
lip = 0.75;
col_h = dia * 2;
slot_ratio = 0.7;
col_tol = 0.1;
neg_tol = 0.5;
thickness = 1;
$fn = 64;

module copy() {
  difference() {
    union() {
      cylinder(r=w / 2, h=h, center=true);
      translate([0, 0, h / 2]) snapfit(dia, lip, col_h, col_tol, slot_ratio, thickness=thickness);
    }
    translate([0, 0, -h / 2 - 0.1]) snapfit_neg(dia, lip, col_h, neg_tol, slot_ratio, thickness=thickness);
  }
}

intersection() {
  copy();
  translate([0, 0, OFFSET]) copy();
}
