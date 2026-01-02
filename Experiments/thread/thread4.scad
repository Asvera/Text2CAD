// Standard Threaded Rod using BOSL2

// --- Parameters ---
// Diameter of the threaded rod
rod_diameter = 25; // mm
// Height (length) of the threaded section
rod_height = 20; // mm
// Pitch of the thread (distance between threads)
thread_pitch = 2; // mm

// Rendering quality parameters for BOSL2 threading
// Fragments per rotation (higher = smoother thread)
render_fn = 128;
// Minimum angle (smaller = smoother curves)
render_fa = 0.5;

// --- Includes ---
include <BOSL2/std.scad>
include <BOSL2/threading.scad>

// --- Main Module ---
module threaded_rod_design() {
    threaded_rod(
        d = rod_diameter,
        height = rod_height,
        pitch = thread_pitch,
        fn = render_fn,
        fa = render_fa
    );
}

// --- Render the object ---
threaded_rod_design();