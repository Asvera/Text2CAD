include <BOSL2/std.scad>
include <BOSL2/gears.scad>

// --- Gear Parameters ---
// The desired pitch radius of the gear
pitch_radius = 9; // mm
// The number of teeth on the gear
num_teeth = 18;
// The thickness of the gear
gear_thickness = 5; // mm
// The diameter of the shaft hole through the center of the gear
shaft_diameter = 3; // mm

// --- Derived Parameters ---
// Calculate the module based on pitch radius and number of teeth
// Module = (2 * Pitch Radius) / Number of Teeth
module = (2 * pitch_radius) / num_teeth;

// --- Render the Gear ---
spur_gear(
    mod = module,
    teeth = num_teeth,
    thickness = gear_thickness,
    shaft_diam = shaft_diameter
);