// Include the BOSL2 library for gear generation
use <BOSL2/std.scad>

// --- Gear Parameters ---
pitch_radius = 9;       // Pitch radius of the gear in mm (as requested)
module_size = 1;        // Module of the gear in mm (determines tooth size)
num_teeth = 2 * pitch_radius / module_size; // Number of teeth, calculated from pitch radius and module
pressure_angle = 20;    // Pressure angle in degrees (standard is 20)
gear_thickness = 5;     // Thickness of the gear body in mm

// --- Bore and Hub Parameters ---
bore_diameter = 4;      // Diameter of the central bore for a shaft in mm
hub_diameter = 8;       // Diameter of the hub around the bore in mm
hub_thickness = 3;      // Thickness of the hub in mm

// --- Main Gear Module ---
module create_spur_gear() {
    // Generate the spur gear using BOSL2's gear() function
    gear(
        module = module_size,
        num_teeth = num_teeth,
        pressure_angle = pressure_angle,
        thickness = gear_thickness,
        bore_d = bore_diameter,
        hub_d = hub_diameter,
        hub_h = hub_thickness
    );
}

// Render the gear
create_spur_gear();