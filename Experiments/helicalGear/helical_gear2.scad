use <BOSL2/std.scad>

// Gear parameters
teeth = 24;                 // Number of teeth
pitch = 7;                  // Pitch of the gear (mm)
pressure_angle = 20;        // Pressure angle in degrees
gear_thickness = 5;         // Thickness of the gear body (mm)
bore_diameter = 8;          // Diameter of the center bore (mm)
hub_diameter = 15;          // Diameter of the hub (mm)
hub_thickness = 3;          // Thickness of the hub (mm)
keyway_width = 3;           // Width of the keyway (set to 0 for no keyway)
keyway_depth = 1.5;         // Depth of the keyway (set to 0 for no keyway)

// Main gear module
module my_gear() {
    gear(
        teeth = teeth,
        pitch = pitch,
        pressure_angle = pressure_angle,
        thickness = gear_thickness,
        bore_diameter = bore_diameter,
        hub_diameter = hub_diameter,
        hub_thickness = hub_thickness,
        keyway_width = keyway_width,
        keyway_depth = keyway_depth
    );
}

my_gear();