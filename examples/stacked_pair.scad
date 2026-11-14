// Two self-connecting discs snapped together, cut in half to show the pin in its hole.
// For looking at, not printing.
use <../snapfit.scad>;

w = 10;
h = 5;
dia = 3;
lip = 0.75;
col_h = dia * 2;
neg_tol = 0.5;
thickness = 1;
$fn = 64;

module disc() {
  difference() {
    union() {
      cylinder(d = w, h = h, center = true);
      translate([0, 0, h / 2]) snapfit(dia, lip, col_h, 0.1, 0.7, thickness = thickness);
    }
    translate([0, 0, -h / 2 - 0.1]) snapfit_neg(dia, lip, col_h, neg_tol, 0.7, thickness = thickness);
  }
}

// Seated: the upper disc rests on the lower one's foot.
seat = h + col_h - thickness;

difference() {
  union() {
    disc();
    translate([0, 0, seat]) disc();
  }
  // Keep the half behind the y = 0 plane, so the front shows the section.
  translate([-w, -2 * w, -h]) cube([2 * w, 2 * w, 3 * h + seat + 10]);
}
