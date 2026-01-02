// Torsion Spring Parameters
coil_outer_diameter = 20; // Outer diameter of the spring coils (mm)
wire_diameter = 2;        // Diameter of the spring wire (mm)
num_coils = 6;            // Number of active coils
leg_length = 15;          // Length of each straight leg (mm)
leg_angle_degrees = 90;   // Angle between the two legs (degrees). 0 for parallel, 90 for perpendicular.

// Smoothness for rendering
$fn = 64;

module torsion_spring(
    coil_outer_diameter,
    wire_diameter,
    num_coils,
    leg_length,
    leg_angle_degrees
) {
    // Derived parameters
    _coil_radius = (coil_outer_diameter - wire_diameter) / 2; // Radius of the helix path
    _wire_radius = wire_diameter / 2;                         // Radius of the wire cross-section
    _pitch = wire_diameter;                                   // Pitch of the helix (distance between coil centers for tightly wound)
    _total_coil_height = num_coils * _pitch;                   // Total height of the coiled section
    _total_twist_degrees = num_coils * 360;                   // Total twist for the linear_extrude

    union() {
        // Helical Coils
        // Uses linear_extrude with twist to create a smooth helix.
        // The profile is a circle translated to the coil_radius, then extruded along Z
        // while simultaneously twisting.
        linear_extrude(
            height = _total_coil_height,
            twist = _total_twist_degrees,
            slices = num_coils * 30, // Number of segments along the helix for smoothness
            $fn = $fn
        ) {
            // The circle profile is placed at the starting radius of the helix.
            translate([_coil_radius, 0, 0])
                circle(r = _wire_radius, $fn = $fn);
        }

        // First Leg (bottom)
        // This leg starts at the beginning of the helix path: [_coil_radius, 0, 0].
        // The tangent direction of the helix at this point is along the +Y axis.
        // We rotate the cylinder (which by default extends along Z) to align it along +Y.
        translate([_coil_radius, 0, 0])
            rotate([0, 0, 90]) // Rotate cylinder to extend along +Y axis
                cylinder(h = leg_length, r = _wire_radius, $fn = $fn);

        // Second Leg (top)
        // This leg starts at the end of the helix path: [_coil_radius, 0, _total_coil_height].
        // The tangent direction of the helix at this point is also along the +Y axis.
        // We rotate this leg by `leg_angle_degrees` relative to the first leg's orientation.
        // If the first leg is at 90 degrees (along +Y), then this leg will be at (90 + leg_angle_degrees) degrees.
        translate([_coil_radius, 0, _total_coil_height])
            rotate([0, 0, 90 + leg_angle_degrees]) // Rotate cylinder to align along desired angle
                cylinder(h = leg_length, r = _wire_radius, $fn = $fn);
    }
}

// Instantiate the spring with the defined parameters
torsion_spring(
    coil_outer_diameter,
    wire_diameter,
    num_coils,
    leg_length,
    leg_angle_degrees
);