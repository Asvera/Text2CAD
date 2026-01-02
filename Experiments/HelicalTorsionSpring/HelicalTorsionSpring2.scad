// Include BOSL2 library for advanced path operations
use <BOSL2/BOSL2.scad>

// --- Spring Parameters ---
// Mean diameter of the helical coil
coil_diameter = 20; // mm

// Rectangular wire cross-section dimensions
wire_width = 2.0;   // mm (dimension along the coil radius)
wire_thickness = 1.5; // mm (dimension along the coil axis/pitch)

// Number of active coils
num_coils = 6;

// Axial distance per full turn (pitch)
// Approximately equal to wire_thickness for a close-wound spring
pitch = 2.0; // mm

// Length of the straight tangential legs
leg_length = 20; // mm

// --- Derived Parameters ---
// Total height of the helical coil
coil_height = num_coils * pitch;

// --- Module for the Torsion Spring ---
module helical_torsion_spring() {
    // Define the 2D profile for the wire cross-section.
    // The profile is rotated so that:
    // - Its local X-axis corresponds to the wire_width (radial direction)
    // - Its local Z-axis corresponds to the wire_thickness (axial direction)
    // - Its local Y-axis will be aligned with the path tangent by path_sweep
    profile_shape = rotate([90, 0, 0]) square([wire_width, wire_thickness], center = true);

    // Generate the helical path using BOSL2's helix_spiral.
    // 'd' is the mean diameter.
    // 'h' is the total height.
    // 'n' is the number of turns.
    // 'pitch' is the axial distance per turn.
    helix_path = helix_spiral(
        d = coil_diameter,
        h = coil_height,
        n = num_coils,
        pitch = pitch
    );

    // Sweep the profile along the helical path.
    // 'orient_profile="up"' ensures the profile's local Z-axis (wire_thickness)
    // stays aligned with the global Z-axis (helix axis).
    // The profile's local X-axis (wire_width) will then be radial.
    // The profile's local Y-axis will be along the tangent.
    coil = path_sweep(
        path = helix_path,
        profile = profile_shape,
        orient_profile = "up"
    );

    // --- Create the straight tangential legs ---
    // Get the transformation matrix at the start (t=0) and end (t=1) of the helix.
    // This matrix includes translation and rotation to correctly orient the profile
    // according to 'orient_profile="up"'.
    start_transform = path_transform_at_t(helix_path, 0, orient_profile = "up");
    end_transform = path_transform_at_t(helix_path, 1, orient_profile = "up");

    // Start Leg: Extends tangentially backwards from the start of the helix.
    // The profile's local Y-axis (after 'orient_profile="up"') is along the tangent.
    // We need to extrude along this local Y-axis.
    // linear_extrude extrudes along its local Z-axis.
    // So, we rotate the extrusion direction by -90 degrees around X to align Z with Y.
    // Then translate it back by leg_length along the local Y-axis.
    start_leg = multmatrix(start_transform) {
        translate([0, -leg_length, 0]) // Move extrusion start point back along local Y (tangent)
        rotate([0, -90, 0])            // Rotate linear_extrude's Z-axis to align with local Y-axis
        linear_extrude(height = leg_length)
        profile_shape;
    };

    // End Leg: Extends tangentially forwards from the end of the helix.
    // Similar logic as the start leg, but no initial translation as it extends forwards.
    end_leg = multmatrix(end_transform) {
        rotate([0, -90, 0])            // Rotate linear_extrude's Z-axis to align with local Y-axis
        linear_extrude(height = leg_length)
        profile_shape;
    };

    // Combine all parts into a single object
    union() {
        coil;
        start_leg;
        end_leg;
    }
}

// Render the torsion spring
helical_torsion_spring();