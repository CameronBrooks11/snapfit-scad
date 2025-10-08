use <../snapfit.scad>;

// Parameters
w = 10; // Base cylinder diameter
h = 3; // Base cylinder height

dia = 5; // Snap fit diameter
lip = 1; // Snap fit lip (adds to diameter)
col_h = 2; // Snap fit column height

slot_ratio = 0.8; // Snap fit slot ratio

col_tol = 0.1; // Snap fit column tolerance

$fn = $preview ? 32 : 128; // Number of facets for the cylinder

z_fight = $preview ? 0.05 : 0.0; // Z offset for preview

union() {
  translate([0, 0, h / 2]) cylinder(r1=w / 2, r2=w / 3, h=h, center=true); // Main cylinder
  translate([0, 0, h]) snapfit(dia, lip, col_h, col_tol, slot_ratio, under_chamfer_angle=45);
}
