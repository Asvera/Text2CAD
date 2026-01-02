// Parameters for the cube truss
segment_length = 20; // Side length of each cube segment
rod_diameter = 2;    // Diameter of the truss rods
num_segments_x = 5;  // Number of segments along the X-axis (horizontal extents)
num_segments_y = 1;  // Number of segments along the Y-axis
num_segments_z = 1;  // Number of segments along the Z-axis

// BOSL2 library inclusion
use <BOSL2/bosl2.scad>

// Render the cube truss
truss_cube(
    size = [segment_length * num_segments_x, segment_length * num_segments_y, segment_length * num_segments_z],
    segment_size = segment_length,
    rod_d = rod_diameter
);