// Define parameters for the cube truss
cube_side = 100; // Side length of each cube in the truss (in mm)
num_segments = 5; // Number of cube segments in the horizontal (X) direction
rod_diameter = 5; // Diameter of the rods forming the truss (in mm)
$fn = 32; // Number of facets for cylinders (for smoothness)

// Helper module to draw a rod (cylinder) between two 3D points
module rod(p1, p2, diameter) {
    // Calculate the length of the rod
    length = norm(p2 - p1);
    
    // Calculate the direction vector
    direction = (p2 - p1) / length;
    
    // Calculate rotation angles to align the cylinder with the direction vector
    // Rotate around Z-axis to align with the XY projection of the vector
    angle_z = atan2(direction.y, direction.x);
    // Rotate around Y-axis to align with the Z component
    angle_y = atan2(direction.z, sqrt(pow(direction.x, 2) + pow(direction.y, 2)));
    
    // Translate to the first point, then rotate and draw the cylinder
    translate(p1) {
        rotate([0, angle_y, angle_z]) {
            cylinder(h = length, d = diameter, center = false);
        }
    }
}

// Module for a single cube truss segment
// This module draws all edges and face diagonals for one cube
module truss_cube_segment(side, rod_d) {
    // Define the 8 corner points of a cube relative to its origin (0,0,0)
    // P0: (0,0,0), P1: (side,0,0), P2: (0,side,0), P3: (0,0,side)
    // P4: (side,side,0), P5: (side,0,side), P6: (0,side,side), P7: (side,side,side)

    // Draw the 12 edges of the cube
    // Edges parallel to X-axis
    rod([0,0,0], [side,0,0], rod_d);
    rod([0,side,0], [side,side,0], rod_d);
    rod([0,0,side], [side,0,side], rod_d);
    rod([0,side,side], [side,side,side], rod_d);

    // Edges parallel to Y-axis
    rod([0,0,0], [0,side,0], rod_d);
    rod([side,0,0], [side,side,0], rod_d);
    rod([0,0,side], [0,side,side], rod_d);
    rod([side,0,side], [side,side,side], rod_d);

    // Edges parallel to Z-axis
    rod([0,0,0], [0,0,side], rod_d);
    rod([side,0,0], [side,0,side], rod_d);
    rod([0,side,0], [0,side,side], rod_d);
    rod([side,side,0], [side,side,side], rod_d);

    // Draw the 12 face diagonals (2 per face)
    // Diagonals on XY faces (Z=0 and Z=side)
    rod([0,0,0], [side,side,0], rod_d); // Bottom face diagonal 1
    rod([side,0,0], [0,side,0], rod_d); // Bottom face diagonal 2
    rod([0,0,side], [side,side,side], rod_d); // Top face diagonal 1
    rod([side,0,side], [0,side,side], rod_d); // Top face diagonal 2

    // Diagonals on XZ faces (Y=0 and Y=side)
    rod([0,0,0], [side,0,side], rod_d); // Front face diagonal 1
    rod([side,0,0], [0,0,side], rod_d); // Front face diagonal 2
    rod([0,side,0], [side,side,side], rod_d); // Back face diagonal 1
    rod([side,side,0], [0,side,side], rod_d); // Back face diagonal 2

    // Diagonals on YZ faces (X=0 and X=side)
    rod([0,0,0], [0,side,side], rod_d); // Left face diagonal 1
    rod([0,side,0], [0,0,side], rod_d); // Left face diagonal 2
    rod([side,0,0], [side,side,side], rod_d); // Right face diagonal 1
    rod([side,side,0], [side,0,side], rod_d); // Right face diagonal 2
}

// Main module to generate the full cube truss structure
module cube_truss_assembly(side, segments, rod_d) {
    // Iterate to create multiple segments along the X-axis
    for (i = [0 : segments - 1]) {
        translate([i * side, 0, 0]) {
            truss_cube_segment(side, rod_d);
        }
    }
}

// Instantiate the main module to render the final object
cube_truss_assembly(cube_side, num_segments, rod_diameter);