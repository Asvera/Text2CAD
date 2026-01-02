// Beam length
beam_length = 200; // Length of the channel beam

// Channel section dimensions
web_height = 50;   // Height of the web (vertical part)
flange_width = 30; // Width of the flanges (horizontal parts)
thickness = 5;     // Thickness of the material

// Color for the beam
beam_color = [0.6, 0.6, 0.6, 1.0]; // A medium grey color

module channel_beam() {
    color(beam_color) {
        union() {
            // Web (the vertical part)
            // Dimensions: [length, thickness, height]
            cube([beam_length, thickness, web_height]);

            // Top Flange (horizontal part at the top)
            // Positioned at the top of the web, extending outwards
            translate([0, 0, web_height - thickness]) {
                cube([beam_length, flange_width, thickness]);
            }

            // Bottom Flange (horizontal part at the bottom)
            // Positioned at the bottom of the web, extending outwards
            cube([beam_length, flange_width, thickness]);
        }
    }
}

// Render the channel beam
channel_beam();