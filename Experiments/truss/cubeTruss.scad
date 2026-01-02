// Parameters for the cube truss
truss_side_length = 100; // Overall side length of the cube truss
member_thickness = 5;    // Side length of the square profile for truss members
member_color = [0.7, 0.7, 0.7, 1]; // Color of the truss members (RGBA)

// Helper module to create a square beam between two points using hull.
// This creates a beam with a square cross-section, whose ends are centered at p1 and p2.
module beam(p1, p2) {
    hull() {
        translate(p1) cube(member_thickness, center = true);
        translate(p2) cube(member_thickness, center = true);
    }
}

// Main module to generate the cube truss structure
module cube_truss() {
    // Define the 8 vertices of the cube
    // The cube starts at (0,0,0) and extends to (truss_side_length, truss_side_length, truss_side_length)
    v0 = [0, 0, 0];
    v1 = [truss_side_length, 0, 0];
    v2 = [0, truss_side_length, 0];
    v3 = [truss_side_length, truss_side_length, 0];
    v4 = [0, 0, truss_side_length];
    v5 = [truss_side_length, 0, truss_side_length];
    v6 = [0, truss_side_length, truss_side_length];
    v7 = [truss_side_length, truss_side_length, truss_side_length];

    color(member_color) {
        // Draw the 12 edges of the cube
        // Bottom face edges (Z=0)
        beam(v0, v1);
        beam(v0, v2);
        beam(v1, v3);
        beam(v2, v3);

        // Top face edges (Z=truss_side_length)
        beam(v4, v5);
        beam(v4, v6);
        beam(v5, v7);
        beam(v6, v7);

        // Vertical edges connecting bottom and top faces
        beam(v0, v4);
        beam(v1, v5);
        beam(v2, v6);
        beam(v3, v7);

        // Draw the 12 face diagonals
        // Bottom face diagonals (Z=0)
        beam(v0, v3);
        beam(v1, v2);

        // Top face diagonals (Z=truss_side_length)
        beam(v4, v7);
        beam(v5, v6);

        // Front face diagonals (Y=0)
        beam(v0, v5);
        beam(v1, v4);

        // Back face diagonals (Y=truss_side_length)
        beam(v2, v7);
        beam(v3, v6);

        // Left face diagonals (X=0)
        beam(v0, v6);
        beam(v2, v4);

        // Right face diagonals (X=truss_side_length)
        beam(v1, v7);
        beam(v3, v5);
    }
}

// Render the cube truss
cube_truss();