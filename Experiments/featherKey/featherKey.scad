// Feather Key dimensions
key_width = 6;    // Width of the key in mm
key_height = 6;   // Height of the key in mm
key_length = 36;  // Length of the key in mm

/**
 * Renders a standard feather key.
 * @param width The width of the key.
 * @param height The height of the key.
 * @param length The length of the key.
 */
module feather_key(width, height, length) {
    cube([width, height, length]);
}

// Instantiate the feather key with the defined dimensions
feather_key(key_width, key_height, key_length);