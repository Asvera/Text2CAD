// Thread parameters
thread_diameter = 10; // Major diameter of the thread (e.g., M10)
thread_pitch = 1.5;   // Pitch of the thread (e.g., 1.5 for M10x1.5)
thread_length = 15;   // Length of the threaded section

// Number of segments for the helix and profile (higher = smoother)
// This variable is used for both the thread and the surrounding cylinder.
$fn = 64;

// Derived parameters for a standard 60-degree internal thread (ISO Metric)
// Fundamental triangle height (H)
H_fundamental = thread_pitch * sqrt(3) / 2;
// Actual thread depth (h_3 or h_internal, 0.6134 * pitch for ISO metric)
thread_depth = 0.6134 * thread_pitch;
// Width of the flat at the crest (major diameter) (P/8)
crest_flat_width = thread_pitch / 8;
// Width of the flat at the root (minor diameter) (P/4)
root_flat_width = thread_pitch / 4;

// Minor diameter of the thread (diameter of the hole before threading)
minor_diameter = thread_diameter - 2 * thread_depth;

// Module to generate the internal thread (nut thread) as a solid object to be subtracted.
// This object represents the material to be removed to form the thread groove.
module nut_thread_groove(diameter, pitch, length, fn_segments = $fn) {
    // Derived parameters for the thread profile
    _thread_depth = 0.6134 * pitch;
    _crest_flat_width = pitch / 8;
    _root_flat_width = pitch / 4;

    // Define the 2D profile of the thread groove (trapezoid)
    // Points are defined in the XY plane, where Y is the radial direction.
    // The top edge (crest) of the profile is at y=0.
    // The bottom edge (root) of the profile is at y=-_thread_depth.
    profile_points = [
        [-_crest_flat_width / 2, 0],
        [_crest_flat_width / 2, 0],
        [_root_flat_width / 2, -_thread_depth],
        [-_root_flat_width / 2, -_thread_depth]
    ];

    // Number of turns for the helix
    num_turns = length / pitch;
    // Total number of segments for the helix, ensuring full length is covered
    total_segments = ceil(num_turns * fn_segments);

    // Arrays to store points and faces for the polyhedron
    points = [];
    faces = [];

    // Generate points for each segment of the helix
    for (i = [0 : total_segments]) {
        // Current angle and Z position along the helix
        angle = i * 360 / fn_segments;
        z_pos = i * pitch / fn_segments;

        // Calculate the radial offset for the profile.
        // The profile's top edge (crest) should be at the major diameter/2.
        // Since the profile is defined with its top edge at y=0, we translate it radially.
        radial_offset = diameter / 2;

        // Transform and add profile points for the current segment
        for (j = [0 : len(profile_points) - 1]) {
            p = profile_points[j];
            x_profile = p[0];
            y_profile = p[1] + radial_offset; // Apply radial offset

            // Rotate the point around the Z-axis to its position on the helix
            rotated_x = x_profile * cos(angle) - y_profile * sin(angle);
            rotated_y = x_profile * sin(angle) + y_profile * cos(angle);

            points = concat(points, [[rotated_x, rotated_y, z_pos]]);
        }

        // Create faces for the polyhedron by connecting current and previous profiles
        if (i > 0) {
            // Indices for the previous profile (base_idx) and current profile (current_idx)
            base_idx = (i - 1) * 4;
            current_idx = i * 4;

            // Side faces connecting the corresponding points of the two profiles
            faces = concat(faces, [
                [base_idx + 0, base_idx + 1, current_idx + 1, current_idx + 0], // Top connecting face
                [base_idx + 1, base_idx + 2, current_idx + 2, current_idx + 1], // Right side connecting face
                [base_idx + 2, base_idx + 3, current_idx + 3, current_idx + 2], // Bottom connecting face
                [base_idx + 3, base_idx + 0, current_idx + 0, current_idx + 3]  // Left side connecting face
            ]);
        }
    }

    // Add end caps to make the polyhedron a closed solid
    // Bottom cap (first profile)
    faces = concat(faces, [
        [0, 3, 2, 1] // Points 0, 1, 2, 3 form the first profile
    ]);
    // Top cap (last profile)
    last_idx = total_segments * 4;
    faces = concat(faces, [
        [last_idx + 0, last_idx + 1, last_idx + 2, last_idx + 3] // Points of the last profile
    ]);

    polyhedron(points, faces);
}

// Main object: a cylinder with the internal thread subtracted
difference() {
    // Outer cylinder representing the body of the nut
    // Added 5mm to the diameter for a visible nut body
    cylinder(h = thread_length, d = thread_diameter + 5, $fn = $fn);

    // Inner cylinder representing the pre-drilled hole before threading
    cylinder(h = thread_length, d = minor_diameter, $fn = $fn);

    // Subtract the thread groove geometry to create the internal thread
    nut_thread_groove(thread_diameter, thread_pitch, thread_length, $fn);
}