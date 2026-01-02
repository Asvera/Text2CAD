use <BOSL2/gears.scad>

// --- Gear Parameters ---
// Pitch radius of the gear in mm.
pitch_radius = 9; 
// Number of teeth on the gear.
num_teeth = 18; 
// Pressure angle in degrees (typically 20 or 14.5).
pressure_angle = 20; 
// Thickness of the gear body in mm.
gear_thickness = 5; 
// Diameter of the bore (center hole) in mm.
bore_diameter = 3; 
// Depth of the bore (usually same as gear_thickness).
bore_depth = gear_thickness; 
// Diameter of the hub (raised center part), if any. Set to 0 for no hub.
hub_diameter = 6; 
// Depth of the hub. Set to 0 for no hub.
hub_depth = 2; 

// --- Rendering Quality ---
// Number of facets for circles and arcs. Higher values give smoother curves.
$fn = 60; 

// Generate the spur gear
spur_gear(
    pitch_radius = pitch_radius,
    num_teeth = num_teeth,
    pressure_angle = pressure_angle,
    thickness = gear_thickness,
    bore_diameter = bore_diameter,
    bore_depth = bore_depth,
    hub_diameter = hub_diameter,
    hub_depth = hub_depth
);