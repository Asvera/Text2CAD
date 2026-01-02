// Woodruff Key Parameters
key_width = 4;      // Nominal width of the key (b) in mm
key_diameter = 13;  // Nominal diameter of the key (d1) in mm
key_height = 9.5;   // Overall height of the key (h) in mm - based on DIN 6888 for d1=13, b=4

// --- Calculated Dimensions ---
key_radius = key_diameter / 2; // Radius of the cylindrical segment in mm
// Distance from the center of the cylinder to the flat bottom of the key.
// This is calculated as the total key height minus the cylinder's radius.
// For example, if key_height = 9.5mm and key_radius = 6.5mm, then cut_offset_from_center = 3mm.
// This means the flat bottom of the key is 3mm below the cylinder's center.
cut_offset_from_center = key_height - key_radius;

// --- Global Settings ---
$fn = 64; // Number of facets for circular objects, controls smoothness

// Module to create the 2D profile of the Woodruff key
// This profile is a circle with a segment cut off by a flat plane.
module woodruff_key_profile(diameter, height) {
    radius = diameter / 2;
    offset_from_center_to_flat = height - radius;

    difference() {
        // The base circle from which the key segment is cut
        circle(r = radius);

        // Cutting rectangle to remove the bottom part of the circle.
        // The circle is centered at (0,0).
        // The flat bottom of the key should be at y = -offset_from_center_to_flat.
        // The cutting rectangle needs to cover everything from y = -radius (bottom of the circle)
        // up to y = -offset_from_center_to_flat (the desired flat bottom of the key).
        // Its width is 'diameter', its height is 'radius - offset_from_center_to_flat'.
        // It's positioned with its bottom-left corner at (-diameter/2, -radius).
        translate([-diameter/2, -radius, 0]) {
            square([diameter, radius - offset_from_center_to_flat]);
        }
    }
}

// Main object: Extrude the 2D profile to create the 3D Woodruff key.
// The extrusion is centered on the Z-axis.
linear_extrude(height = key_width, center = true) {
    woodruff_key_profile(key_diameter, key_height);
}