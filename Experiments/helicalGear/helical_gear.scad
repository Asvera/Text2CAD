// Helical Gear Generator
// Based on involute gear principles and manual slicing for helix.

// --- Gear Parameters ---
pitch_radius = 7;      // [mm] Pitch radius of the gear (given)
number_of_teeth = 20;  // Number of teeth
pressure_angle = 20;   // [degrees] Standard pressure angle
helix_angle = 20;      // [degrees] Helix angle
gear_thickness = 10;   // [mm] Thickness of the gear
bore_diameter = 3;     // [mm] Diameter of the central bore

// --- Rendering Parameters ---
slices_per_mm = 5;     // Number of 2D slices per mm of gear thickness for hulling
num_involute_segments = 20; // Number of segments to approximate the involute curve
$fn = 64;              // Facets for circles and cylinders

// --- Derived Parameters ---
module_val = (2 * pitch_radius) / number_of_teeth; // Module of the gear
base_radius = pitch_radius * cos(pressure_angle);  // Base circle radius
addendum = module_val;                             // Addendum (height above pitch circle)
dedendum = 1.25 * module_val;                      // Dedendum (depth below pitch circle)
outer_radius = pitch_radius + addendum;            // Outer circle (tip) radius
root_radius = pitch_radius - dedendum;             // Root circle radius

// Calculate the total twist angle over the gear thickness
// Formula: total_twist_angle = gear_thickness * tan(helix_angle) * 180 / (PI * pitch_radius)
total_twist_angle = gear_thickness * tan(helix_angle) * 180 / (PI * pitch_radius);

// Number of slices for the hull operation
num_slices = floor(gear_thickness * slices_per_mm);
if (num_slices < 2) num_slices = 2; // Ensure at least 2 slices for hulling

// --- Involute Curve Functions ---

// Function to calculate the angle of a point on the involute curve relative to its tangent point on the base circle.
// Returns angle in degrees.
function involute_angle_at_radius_deg(r, base_r) = (r < base_r) ? 0 : (atan(sqrt(r*r - base_r*base_r) / base_r) - acos(base_r / r));

// --- Tooth Profile Generation ---

// Calculate the angle from the tooth center line to the start of the involute curve at the base circle.
// This ensures correct tooth thickness at the pitch circle.
half_tooth_angle_at_pitch_radius_deg = (180 / number_of_teeth);
involute_angle_at_pitch_radius_deg = involute_angle_at_radius_deg(pitch_radius, base_radius);
start_angle_for_involute_deg = half_tooth_angle_at_pitch_radius_deg - involute_angle_at_pitch_radius_deg;

// Module to generate a single 2D tooth profile as a polygon.
// The profile includes two involute curves, connected by radial lines (if root_radius < base_radius)
// and a root arc (implicitly closed by polygon).
module single_tooth_profile_2d(segments) {
    points = [];
    
    // Angle of the involute at the base circle (where it effectively starts)
    angle_at_base_circle_deg = start_angle_for_involute_deg;

    // Add radial line from root_radius to base_radius (if root_radius is below base_radius)
    if (root_radius < base_radius) {
        points = concat(points, [[root_radius * cos(angle_at_base_circle_deg), root_radius * sin(angle_at_base_circle_deg)]]);
    }

    // First involute curve (from base_radius to outer_radius)
    for (i = [0 : segments]) {
        r_curr = base_radius + i * (outer_radius - base_radius) / segments;
        if (r_curr < base_radius) r_curr = base_radius; // Clamp to base_radius
        angle_curr_rel = angle_at_base_circle_deg + involute_angle_at_radius_deg(r_curr, base_radius);
        points = concat(points, [[r_curr * cos(angle_curr_rel), r_curr * sin(angle_curr_rel)]]);
    }

    // Second involute curve (from outer_radius to base_radius), reflected
    for (i = [segments : -1 : 0]) {
        r_curr = base_radius + i * (outer_radius - base_radius) / segments;
        if (r_curr < base_radius) r_curr = base_radius; // Clamp to base_radius
        angle_curr_rel = angle_at_base_circle_deg + involute_angle_at_radius_deg(r_curr, base_radius);
        points = concat(points, [[r_curr * cos(angle_curr_rel), -r_curr * sin(angle_curr_rel)]]);
    }

    // Add radial line from base_radius to root_radius (if root_radius is below base_radius)
    if (root_radius < base_radius) {
        points = concat(points, [[root_radius * cos(angle_at_base_circle_deg), -root_radius * sin(angle_at_base_circle_deg)]]);
    }
    
    // The polygon command automatically closes the shape, creating the root arc.
    polygon(points);
}

// --- Main Helical Gear Module ---
module helical_gear_body() {
    hull() {
        for (i = [0 : num_slices]) {
            z_pos = i * (gear_thickness / num_slices);
            slice_twist_angle = (z_pos / gear_thickness) * total_twist_angle;
            
            translate([0, 0, z_pos]) {
                rotate([0, 0, slice_twist_angle]) {
                    union() { // Union all teeth for this slice
                        for (j = [0 : number_of_teeth - 1]) {
                            rotate([0, 0, j * (360 / number_of_teeth)]) {
                                single_tooth_profile_2d(num_involute_segments);
                            }
                        }
                    }
                }
            }
        }
    }
}

// --- Render the Helical Gear ---
difference() {
    helical_gear_body();
    cylinder(h = gear_thickness, r = bore_diameter / 2, center = false, $fn = $fn);
}