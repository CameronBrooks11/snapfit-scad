// A tapered foot with a short pin, to push into a board's mounting hole.
// The pin has an under chamfer, so a foot printed in flexible filament slopes in and
// out of the hole rather than catching on a step.
use <../snapfit.scad>;

/* [Foot] */
// Foot diameter at the floor (mm)
foot_d = 10; // [6:1:20]
// Foot height (mm)
foot_h = 3; // [1:0.5:10]

/* [Pin] */
// Pin column diameter: the board hole's size (mm)
dia = 4.5; // [2:0.25:6]
// How much wider the head is than the column (mm)
lip = 1.5; // [0.5:0.1:3]
// Column height: the board's thickness (mm)
col_h = 2; // [0.8:0.1:5]
// Angle of the cone under the head (degrees)
chamfer = 45; // [20:5:70]

/* [Hidden] */
$fn = 64;

cylinder(d1 = foot_d, d2 = foot_d * 0.7, h = foot_h);
translate([0, 0, foot_h]) snapfit(dia, lip, col_h, 0.1, 0.7, under_chamfer_angle = chamfer);
