use <../src/snapfit.scad>;

// Parameters
w = 10;   // Base cylinder diameter
h = 5;    // Base cylinder height


dia = 3;	// Snap fit diameter
lip = 0.75;	// Snap fit lip (adds to diameter)
col_h = dia * 2;   // Snap fit column height

slot_ratio = 0.7;  // Snap fit slot ratio

col_tol = 0.1;  // Snap fit column tolerance
neg_tol = 0.5;  // Snap fit tolerance for the negative

// If defined, creates a foot for the snapfit, leaving a  
// gap of 'thickness' from the bottom of the column head
thickness = 1; 

$fn = 64; // Number of facets for the cylinder

z_fite = $preview ? 0.05 : 0.0;  // Z offset for preview

difference() {
    union() {
        cylinder(r = w/2, h = h, center = true); // Main cylinder
        translate([0, 0, h/2])
        snapfit(dia, lip, col_h, col_tol, slot_ratio, thickness=thickness);
    }

    translate([0, 0, -h/2 - 0.1]) 
    snapfit_neg(dia, lip, col_h, neg_tol, slot_ratio, thickness=thickness);
}