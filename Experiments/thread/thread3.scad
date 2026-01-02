include <BOSL2/std.scad>
include <BOSL2/threading.scad>

// --- Thread Parameters ---
// Nominal diameter of the internal thread (e.g., 20 for M20)
thread_diameter = 20; // mm
// Length of the threaded section
thread_length = 25; // mm
// Pitch of the thread (e.g., 2.5 for M20x2.5)
thread_pitch = 2.5; // mm
// Length of the unthreaded section at the start of the hole
start_unthreaded_length = 2.5; // mm
// Length of the unthreaded section at the end of the hole
end_unthreaded_length = 2.5; // mm
// Whether to add a chamfer at the start of the hole
add_chamfer = true;
// Diameter of the chamfer (defaults to thread_diameter if not specified)
chamfer_diameter = thread_diameter; // mm
// Angle of the chamfer (defaults to 45 if not specified)
chamfer_angle = 45; // degrees

// --- Nut Body Parameters (for demonstration) ---
// Diameter of the cylindrical body representing the nut
nut_body_diameter = thread_diameter * 1.5; // mm
// Total height of the nut body, including unthreaded sections
nut_body_height = thread_length + start_unthreaded_length + end_unthreaded_length + 5; // mm

// Create a simple cylindrical body and subtract the internal thread from it
difference() {
    // Main body of the nut (a cylinder for demonstration)
    cylinder(d = nut_body_diameter, h = nut_body_height, center = true);

    // Create the internal threaded hole
    threaded_hole(
        d = thread_diameter,
        l = thread_length,
        pitch = thread_pitch,
        start_len = start_unthreaded_length,
        end_len = end_unthreaded_length,
        chamfer = add_chamfer,
        chamfer_d = chamfer_diameter,
        chamfer_angle = chamfer_angle
    );
}