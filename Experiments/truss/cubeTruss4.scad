// Cube Truss Parameters
size = 50;              // Overall size of the cube truss (length, width, height)
bar_radius = 2;         // Radius of the truss bars
num_segments = 2;       // Number of segments along each axis (e.g., 1 for a single cube, 2 for 2x2x2 cubes)
joint_radius = 4;       // Radius of the spherical joints at the corners
joint_facets = 32;      // Number of facets for the spherical joints (for smoother spheres)

// BOSL2 Library Includes
include <BOSL2/std.scad>
include <BOSL2/cubetruss.scad>

// Generate the cube truss
cubetruss(
    size = size,
    bar_radius = bar_radius,
    num_segments = num_segments,
    joint_radius = joint_radius,
    joint_facets = joint_facets
);