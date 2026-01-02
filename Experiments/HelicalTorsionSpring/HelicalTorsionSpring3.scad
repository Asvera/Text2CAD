// Torsion Spring Parameters
coil_diameter = 20;     // Diameter of the coil (mm)
wire_width = 2.0;       // Width of the rectangular wire cross-section (radial dimension) (mm)
wire_height = 1.5;      // Height of the rectangular wire cross-section (axial dimension) (mm)
num_coils = 6;          // Number of active coils
pitch = 2;              // Pitch of the helix (distance between coils per turn) (mm)
leg_length = 20;        // Length of the straight tangential legs (mm)

// Internal derived parameters
R = coil_diameter / 2;  // Radius of the coil
pitch_per_deg = pitch / 360; // Pitch per degree of rotation

// Resolution for the helical sweep
segment_angle = 5; // Angle increment for each segment of the helix (degrees). Smaller values result in smoother coils.
$fn = 64; // Global resolution for circles/spheres (not directly used for this geometry, but good practice)

// Function to get a point on the helix path (center of the wire)
// 't' is the angle in degrees
function get_helix_point(t) = [
    R * cos(t),
    R * sin(t),
    pitch_per_deg * t
];

// Function to get the unnormalized tangent vector at a point on the helix
// 't' is the angle in degrees
function get_helix_tangent(t) = [
    -R * sin(t),
    R * cos(t),
    pitch_per_deg
];

// Module for the rectangular wire cross-section
// Centered at [0,0] in its local coordinate system
module wire_profile() {
    square([wire_width, wire_height], center=true);
}

// Module to place the wire_profile at a specific angle 't' on the helix
// The profile's center will be at get_helix_point(t).
// The wire_width dimension will be oriented radially (from the Z-axis outwards).
// The wire_height dimension will be oriented axially (parallel to the Z-axis).
module place_profile_at_t(t) {
    translate([0,0,pitch_per_deg*t]) // Translate along Z to the helix height
    rotate([0,0,t])                   // Rotate around Z to align with the helix angle
    translate([R,0,0])                // Translate radially to the coil radius
    wire_profile();
}

module torsion_spring() {
    // Generate the helical coil by hulling consecutive cross-sections
    num_segments = floor(num_coils * 360 / segment_angle);
    for (i = [0 : num_segments-1]) {
        t1 = i * segment_angle;
        t2 = (i+1) * segment_angle;
        hull() {
            place_profile_at_t(t1);
            place_profile_at_t(t2);
        }
    }

    // Generate the start leg
    t_start_coil = 0; // Angle at the start of the coil
    P_start_coil = get_helix_point(t_start_coil); // Position of the profile center at coil start
    T_start_unnorm = get_helix_tangent(t_start_coil); // Unnormalized tangent vector at coil start
    T_start = T_start_unnorm / norm(T_start_unnorm); // Normalized tangent vector
    P_start_leg_end = P_start_coil + leg_length * T_start; // End position of the leg

    // Hull the profile at the coil start with a translated copy to form the leg
    hull() {
        place_profile_at_t(t_start_coil);
        // Translate the entire profile (including its internal rotations) from its original helix position
        // to the leg end position, maintaining its orientation.
        translate(P_start_leg_end - P_start_coil) place_profile_at_t(t_start_coil);
    }

    // Generate the end leg
    t_end_coil = num_coils * 360; // Angle at the end of the coil
    P_end_coil = get_helix_point(t_end_coil); // Position of the profile center at coil end
    T_end_unnorm = get_helix_tangent(t_end_coil); // Unnormalized tangent vector at coil end
    T_end = T_end_unnorm / norm(T_end_unnorm); // Normalized tangent vector
    P_end_leg_end = P_end_coil + leg_length * T_end; // End position of the leg

    // Hull the profile at the coil end with a translated copy to form the leg
    hull() {
        place_profile_at_t(t_end_coil);
        // Translate the entire profile (including its internal rotations) from its original helix position
        // to the leg end position, maintaining its orientation.
        translate(P_end_leg_end - P_end_coil) place_profile_at_t(t_end_coil);
    }
}

// Render the torsion spring
torsion_spring();