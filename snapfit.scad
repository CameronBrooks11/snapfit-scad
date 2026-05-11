// Adapted by Cameron K. Brooks on 2024-01-26 from the following source:
// https://www.thingiverse.com/thing:1799553/files

def_dia = 3;      // Snap fit dia
def_lip = 0.75;   // Snap fit def_lip (adds to dia)
def_col_h = def_dia * 2; // Snap fit Mini column height

def_slot_ratio = 0.7; // Slot ratio

def_col_tol = 0.1; // Column Tolerance
def_neg_tol = 0.5; // Tolerance for the Negative Snapfit

$fn = $preview ? 32 : 128; // Number of facets for the cylinder
z_fight = $preview ? 0.05 : 0.0; // Z offset for preview

module snapfit(
  dia = def_dia,
  lip = def_lip,
  col_h = def_col_h,
  col_tol = def_col_tol,
  slot_ratio = def_slot_ratio,
  thickness = undef,
  under_chamfer_angle = undef
) {
  z_fight = $preview ? 0.05 : 0.0; // Z offset for preview

  // Calculated Snapfit Parameters
  head_h  = (dia + lip) / 2;                      // Snap fit height
  head_r1 = (dia + lip) / 2;                      // Snap fit radius 1
  head_r2 = calculateRadFromAngle(180 - 60, head_r1, head_h); // Snap fit radius 2
  col_r   = dia / 2;                              // Mini column radius

  difference() {
    union() {
      // snapfit head
      translate([0, 0, col_h + head_h / 2]) {
        if (!is_undef(under_chamfer_angle)) {
          under_height          = head_h / 3;
          r2_from_under_angle   = calculateRadFromAngle(-under_chamfer_angle, head_r1, under_height);

          // Main head
          cylinder(r1=head_r1, r2=head_r2, h=head_h, center=true);

          // Under chamfer
          translate([0, 0, -head_h/2 - under_height/2])
            rotate([0, 180, 0])
              cylinder(r1=head_r1, r2=r2_from_under_angle, h=under_height, center=true);
        } else {
          // Main head
          cylinder(r1=head_r1, r2=head_r2, h=head_h, center=true);
        }
      }

      // Mini column
      translate([0, 0, col_h / 2]) cylinder(r=col_r - col_tol, h=col_h, center=true);

      // optional snapfit foot
      if (!is_undef(thickness)) {
        translate([0, 0, col_h - head_h - thickness + head_h/2])
          cylinder(r1=col_r - col_tol, r2=col_r - col_tol + lip, h=head_h, center=true);
      }
    }

    thick = is_undef(thickness) ? 0 : thickness; // Snapfit foot thickness

    translate([0, 0, (col_h + head_h + z_fight) - (slot_ratio * (col_h + head_h)) / 2])
      cube([head_r1 / 3, head_r1 * 2 + thick * 2, slot_ratio * (col_h + head_h)], center=true);
  }
}

module snapfit_neg(
  dia = def_dia,
  lip = def_lip,
  col_h = def_col_h,
  neg_tol = def_neg_tol,
  slot_ratio = def_slot_ratio,
  thickness = undef,
  flip = false,
  under_chamfer_angle = undef
) {
  // Calculated Snapfit Parameters
  head_h  = (dia + lip) / 2;                      // Snap fit height
  head_r1 = (dia + lip) / 2;                      // Snap fit radius 1
  head_r2 = calculateRadFromAngle(180 - 60, head_r1, head_h); // Snap fit radius 2
  col_r   = dia / 2;                              // Mini column radius

  rot   = flip ? 180 : 0;
  z1    = is_undef(thickness) ? col_h : thickness;
  z_offs = rot ? 0 : (head_h + neg_tol + z1);

  // Place so the main head spans z∈[0, head_h+neg_tol] in the local frame
  rotate([rot, 0, 0])
    translate([0, 0, -(head_h + neg_tol) + z_offs])
      union() {
        // snapfit head clearance
        translate([0, 0, (head_h + neg_tol)/2])
          cylinder(r1=head_r1 + neg_tol, r2=head_r2 + neg_tol, h=head_h + neg_tol, center=true);

        // under-chamfer clearance (optional)
        if (!is_undef(under_chamfer_angle)) {
          under_height_neg = head_h/3 + neg_tol; // add z clearance
          // At z=0 interface, radius must match top of under chamfer = head_r1
          r_under_bottom = calculateRadFromAngle(-under_chamfer_angle, head_r1 + neg_tol, under_height_neg);
          // Make the frustum extend downwards from z=0 to z=-under_height_neg
          translate([0, 0, -under_height_neg/2])
            cylinder(r1=r_under_bottom, r2=head_r1 + neg_tol, h=under_height_neg, center=true);
        }

        // optional snapfit foot / column clearance below
        if (!is_undef(thickness)) {
          translate([0, 0, -thickness/2 + z_fight])
            cylinder(r=head_r1 - neg_tol/2, h=thickness, center=true);
        } else {
          // Mini column
          translate([0, 0, -col_h/2])
            cylinder(r=head_r1 - neg_tol/2, h=col_h, center=true);
        }
      }
}

// Function to calculate radius based on angle, initial radius, and height
function calculateRadFromAngle(angle, r, height) =
  let (norm_angle = angle % 90)
    (angle < 90)
      ? r + tan(abs(90 - norm_angle)) * height
      : r - tan(norm_angle) * height;
