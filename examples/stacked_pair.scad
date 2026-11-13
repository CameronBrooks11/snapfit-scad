// Two self_connecting_snap discs, the upper seated on the lower's foot, cut
// in half to show how the pin sits in the hole. For looking at, not printing.
use <../snapfit.scad>;

w = 10;
h = 5;
dia = 3;
lip = 0.75;
col_h = dia * 2;
slot_ratio = 0.7;
col_tol = 0.1;
neg_tol = 0.5;
thickness = 1;
$fn = $preview ? 32 : 128;

// Seated, the upper disc rests on the lower one's foot.
stack_offset = h + col_h - thickness;

module disc() {
  difference() {
    union() {
      cylinder(r=w / 2, h=h, center=true);
      translate([0, 0, h / 2]) snapfit(dia, lip, col_h, col_tol, slot_ratio, thickness=thickness);
    }
    translate([0, 0, -h / 2 - 0.1]) snapfit_neg(dia, lip, col_h, neg_tol, slot_ratio, thickness=thickness);
  }
}

// Cut away the front half, across the slot.
module front_half() {
  translate([-w, -w, -h]) cube([2 * w, w, 4 * h + stack_offset]);
}

color("SteelBlue") difference() { disc(); front_half(); }
color("Goldenrod") difference() { translate([0, 0, stack_offset]) disc(); front_half(); }
