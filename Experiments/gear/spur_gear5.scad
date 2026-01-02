// Gear parameters
pitch_radius = 9; // Desired pitch radius in mm
num_teeth = 18;   // Number of teeth for the gear
gear_thickness = 8; // Thickness of the gear in mm
shaft_diameter = 5; // Diameter of the shaft hole in mm

// Calculate module based on pitch radius and number of teeth
// pitch_radius = module * num_teeth / 2
// module = 2 * pitch_radius / num_teeth
gear_module = 2 * pitch_radius / num_teeth;

// Include BOSL2 libraries
include <BOSL2/std.scad>
include <BOSL2/gears.scad>

// Render the spur gear
spur_gear(
    mod = gear_module,
    teeth = num_teeth,
    thickness = gear_thickness,
    shaft_diam = shaft_diameter
);