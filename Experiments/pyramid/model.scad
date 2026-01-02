// Parameters for the pentagonal pyramid
pyramid_height = 70; // Height of the pyramid in mm
base_side_length = 20; // Side length of the pentagonal base in mm

module pentagonal_pyramid(height, side_length) {
    // Calculate the radius of the circumcircle for the pentagonal base.
    // For a regular n-gon, side_length = 2 * R * sin(180/n).
    // For a pentagon (n=5), side_length = 2 * R * sin(36).
    base_r = side_length / (2 * sin(36));

    // Define vertices for the polyhedron.
    // Vertex 0 is the apex.
    // Vertices 1-5 are the base vertices, arranged counter-clockwise around the Z-axis.
    vertices = [
        [0, 0, height], // v0: Apex
        [base_r * cos(0), base_r * sin(0), 0], // v1
        [base_r * cos(72), base_r * sin(72), 0], // v2
        [base_r * cos(144), base_r * sin(144), 0], // v3
        [base_r * cos(216), base_r * sin(216), 0], // v4
        [base_r * cos(288), base_r * sin(288), 0]  // v5
    ];

    // Define faces using indices into the 'vertices' array.
    // The order of vertices in a face determines its normal direction.
    // For a solid object, faces should be defined such that their normals point outwards.
    faces = [
        // Base face (bottom, normal pointing downwards)
        [1, 2, 3, 4, 5],

        // Side faces (triangles, normals pointing outwards)
        [1, 0, 5], // Face connecting v1, apex, v5
        [2, 0, 1], // Face connecting v2, apex, v1
        [3, 0, 2], // Face connecting v3, apex, v2
        [4, 0, 3], // Face connecting v4, apex, v3
        [5, 0, 4]  // Face connecting v5, apex, v4
    ];

    // Create the pyramid using the polyhedron primitive
    polyhedron(points = vertices, faces = faces);
}

// Instantiate the pentagonal pyramid with the defined parameters
pentagonal_pyramid(height = pyramid_height, side_length = base_side_length);