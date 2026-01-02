// Beam dimensions
beam_length = 200; // Length of the beam
beam_width = 20;   // Width of the beam
beam_height = 20;  // Height of the beam

/**
 * Creates a simple rectangular beam.
 * @param length The length of the beam.
 * @param width The width of the beam.
 * @param height The height of the beam.
 */
module create_beam(length, width, height) {
    cube([length, width, height]);
}

create_beam(beam_length, beam_width, beam_height);