// Woodruff Key Dimensions
woodruff_key_diameter = 10; // Diameter of the half-cylinder (width of the key)
woodruff_key_length = 25;   // Length of the key along its axis

// Global rendering parameters
$fn = 64; // Number of facets for circular shapes, higher value means smoother curves

module woodruff_key(diameter, length) {
    // The Woodruff key is a half-cylinder.
    // We create a full cylinder, then cut off the bottom half.
    difference() {
        // 1. Create a full cylinder
        // The cylinder is initially along the Z-axis.
        // We want its length along the Y-axis and its flat side on the bottom (Z=0).
        // So, rotate it 90 degrees around the X-axis.
        // Using center=true for the cylinder places its center at [0,0,0].
        // After rotation, its axis is along the Y-axis, and it extends from
        // Z = -diameter/2 to Z = diameter/2.
        rotate([90, 0, 0])
        cylinder(h = length, r = diameter / 2, center = true);

        // 2. Cut off the bottom half
        // To get the flat side on the bottom (Z=0) and curved side on top,
        // we need to remove everything where Z < 0.
        // Create a cutting cube that covers the negative Z-space of the cylinder.
        // The cube needs to be slightly larger than the cylinder in X and Y
        // to ensure a clean cut.
        cube_width = diameter * 1.1;  // Slightly wider than the cylinder
        cube_length = length * 1.1;   // Slightly longer than the cylinder
        
        // The cylinder extends from Z = -diameter/2 to Z = diameter/2.
        // We want to remove the part from Z = -diameter/2 up to Z = 0.
        // The cutting cube's bottom should be below -diameter/2, and its top should be at or above 0.
        // We use center=false for the cube to define its starting corner.
        translate([
            -cube_width / 2,         // X-start: centered on X-axis
            -cube_length / 2,        // Y-start: centered on Y-axis
            -(diameter / 2 + 0.1)    // Z-start: slightly below the cylinder's lowest point
        ])
        cube(size = [
            cube_width,              // X-dimension
            cube_length,             // Y-dimension
            diameter / 2 + 0.2       // Z-dimension: from Z-start up to slightly above Z=0
        ]);
    }
}

// Render the Woodruff key
woodruff_key(woodruff_key_diameter, woodruff_key_length);