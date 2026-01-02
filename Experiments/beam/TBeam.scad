// Beam dimensions
beam_length = 200; // Overall length of the T-beam

// Flange dimensions (the top horizontal part of the 'T')
flange_width = 50;      // Width of the top flange
flange_thickness = 5;   // Thickness of the top flange

// Web dimensions (the vertical part of the 'T')
web_height = 40;        // Height of the vertical web (excluding flange thickness)
web_thickness = 5;      // Thickness of the vertical web

// Module to create a T-section beam
// The origin [0,0,0] is at the bottom center of the web.
module t_section_beam(length, f_width, f_thickness, w_height, w_thickness) {
    union() {
        // Create the flange (top horizontal part)
        // Positioned on top of the web, centered horizontally along X and Y axes.
        translate([-f_width / 2, -length / 2, w_height]) {
            cube([f_width, length, f_thickness]);
        }

        // Create the web (vertical part)
        // Positioned from the bottom (z=0), centered horizontally along X and Y axes.
        translate([-w_thickness / 2, -length / 2, 0]) {
            cube([w_thickness, length, w_height]);
        }
    }
}

// Instantiate the T-section beam with the defined parameters
t_section_beam(beam_length, flange_width, flange_thickness, web_height, web_thickness);