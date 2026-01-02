// Beam parameters
beam_length = 200; // Length of the channel beam (along Y-axis)
web_width = 50;    // Width of the horizontal web section (along X-axis)
flange_height = 30; // Height of the vertical flange sections (along Z-axis, above the web)
material_thickness = 5; // Thickness of the material for web and flanges

// Color for the beam
beam_color = [0.6, 0.6, 0.6, 1.0]; // A light grey color

module channel_beam() {
    color(beam_color) {
        union() {
            // Horizontal Web (lying on the ground)
            // Dimensions: [web_width, beam_length, material_thickness]
            // Position: Starts at [0, 0, 0]
            cube([web_width, beam_length, material_thickness]);

            // Left Vertical Flange
            // Dimensions: [material_thickness, beam_length, flange_height]
            // Position: Starts at [0, 0, material_thickness]
            translate([0, 0, material_thickness])
                cube([material_thickness, beam_length, flange_height]);

            // Right Vertical Flange
            // Dimensions: [material_thickness, beam_length, flange_height]
            // Position: Starts at [web_width - material_thickness, 0, material_thickness]
            translate([web_width - material_thickness, 0, material_thickness])
                cube([material_thickness, beam_length, flange_height]);
        }
    }
}

channel_beam();