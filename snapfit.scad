// snapfit.scad: round, slotted snap-fit pins that print without supports.
//
// snapfit() is the pin: a column with a cone-shaped head, slotted so the head's two
// halves flex together on the way through. snapfit_neg() is the hole it snaps into,
// to subtract from the mating part: a narrow throat the head squeezes past, and a
// pocket above where the head opens out again. MIT licence; see LICENSE.
//
// Both build the head from dia and lip: it is (dia + lip) / 2 tall, on a base
// dia + lip across, and narrows to dia / 2 across at the top.

$fn = 64;

function _head_r(dia, lip) = (dia + lip) / 2;
function _head_h(dia, lip) = (dia + lip) / 2;
// The narrow throat of the hole: the column's own size, so a seated column clears
// it and the head's wider base cannot pass back out.
function _throat_r(dia) = dia / 2;

/**
 * The pin, standing on z = 0.
 *   dia                 column diameter, before col_tol
 *   lip                 how much wider the head's base is than dia
 *   col_h               column height, from z = 0 to the head
 *   col_tol             taken off the column's radius
 *   slot_ratio          the slot's depth, as a fraction of column plus head height
 *   thickness           if set, a foot this far below the head, to trap a plate of
 *                       this thickness between foot and head
 *   under_chamfer_angle if set, a cone of this angle under the head, so the catch
 *                       is a slope instead of a step (for flexible filament)
 */
module snapfit(dia = 3, lip = 0.75, col_h = 6, col_tol = 0.1, slot_ratio = 0.7,
               thickness = undef, under_chamfer_angle = undef) {
  col_r = dia / 2 - col_tol;
  head_r = _head_r(dia, lip);
  head_h = _head_h(dia, lip);
  total = col_h + head_h;
  slot_w = dia / 3;
  slot_d = slot_ratio * total;
  difference() {
    union() {
      cylinder(r = col_r, h = col_h + 0.01);
      translate([0, 0, col_h]) cylinder(r1 = head_r, r2 = dia / 4, h = head_h);
      if (!is_undef(under_chamfer_angle)) {
        // From the head's rim down to the column, at the given angle from horizontal.
        drop = (head_r - col_r) * tan(under_chamfer_angle);
        translate([0, 0, col_h - drop]) cylinder(r1 = col_r, r2 = head_r, h = drop);
      }
      if (!is_undef(thickness)) {
        // The foot: a 45 degree cone whose flat top is `thickness` below the head,
        // flaring out to `lip` past the head's rim so the plate has a shoulder to sit on.
        foot_r = head_r + lip / 2;
        translate([0, 0, col_h - thickness - (foot_r - col_r)])
          cylinder(r1 = col_r, r2 = foot_r, h = foot_r - col_r);
      }
    }
    translate([-slot_w / 2, -head_r - 1, total - slot_d]) cube([slot_w, 2 * head_r + 2, slot_d + 1]);
  }
}

/**
 * The hole for a pin, to subtract from the mating part, starting at z = 0.
 *   dia, lip, col_h, slot_ratio  match the pin
 *   neg_tol             clearance around the head in the pocket
 *   thickness           if set, the throat is this deep (the plate the head snaps
 *                       past); otherwise col_h
 *   flip                mirror it top to bottom, for a pin entering from above
 *   under_chamfer_angle clearance for a pin with an under chamfer
 */
module snapfit_neg(dia = 3, lip = 0.75, col_h = 6, neg_tol = 0.5, slot_ratio = 0.7,
                   thickness = undef, flip = false, under_chamfer_angle = undef) {
  throat = is_undef(thickness) ? col_h : thickness;
  head_r = _head_r(dia, lip);
  pocket_r = head_r + neg_tol;
  pocket_h = _head_h(dia, lip) + neg_tol;
  total = throat + pocket_h;
  module shape() {
    cylinder(r = _throat_r(dia), h = throat + 0.01);
    translate([0, 0, throat]) cylinder(r = pocket_r, h = pocket_h);
    if (!is_undef(under_chamfer_angle)) {
      // Room for the pin's under chamfer: a cone down from the pocket's floor.
      drop = (pocket_r - _throat_r(dia)) * tan(under_chamfer_angle);
      translate([0, 0, throat - drop]) cylinder(r1 = _throat_r(dia), r2 = pocket_r, h = drop + 0.01);
    }
  }
  if (flip) translate([0, 0, total]) mirror([0, 0, 1]) shape();
  else shape();
}
