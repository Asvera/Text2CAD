include <BOSL2/std.scad>
include <BOSL2/cubetruss.scad>

// --- Parameters ---

// The nominal size of the thread (e.g., "M10", "M8", "1/4-20UNC").
// Refer to BOSL2 documentation for supported thread sizes.
thread_size = "M10";

// The length of the thread along its axis.
thread_length = 10; // mm

// Number of facets for rendering curves (higher value means smoother curves).
$fn = 64;

// --- Main Object ---

// Generates a standard thread profile suitable for a nut.
// This creates a negative (subtractive) object that can be used
// to cut a thread into a solid cylinder or hole.
nut_thread(size=thread_size, length=thread_length);