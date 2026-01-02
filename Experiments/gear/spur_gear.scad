// Gear dimensions
pitch_radius = 9; // Pitch radius in mm (given by user)
module_m = 1;     // Module in mm (determines tooth size relative to pitch diameter)
pressure_angle = 20; // Pressure angle in degrees (standard is 20 or 14.5)
gear_thickness = 5; // Thickness of the main gear body in mm
bore_diameter = 5;  // Diameter of the central bore for shaft mounting in mm
hub_diameter = 10;  // Diameter of the hub (thicker part around the bore)
hub_thickness = 3;  // Thickness of the hub (extends from one side of the gear)

// Rendering parameters
$fn = 60; // Number of facets for circles and curves (higher for smoother curves)
involute_segments = 20; // Number of segments to approximate the involute curve

// Derived parameters (calculated from user inputs)
num_teeth = round(2 * pitch_radius / module_m); // Number of teeth (must be integer)
// Recalculate pitch_radius based on integer num_teeth to ensure consistency
pitch_radius_actual = num_teeth * module_m / 2;

addendum = module_m; // Addendum (height of tooth above pitch circle)
dedendum = 1.25 * module_m; // Dedendum (depth of tooth below pitch circle)

base_radius = pitch_radius_actual * cos(pressure_angle); // Base circle radius
outside_radius = pitch_radius_actual + addendum; // Outside (addendum) circle radius
root_radius = pitch_radius_actual - dedendum; // Root (dedendum) circle radius

// Ensure root_radius is not negative for very small gears
root_radius = max(0.1, root_radius);

// Module to generate a single 2D tooth profile
module single_tooth_profile_2d() {
    // Convert pressure angle to radians for calculations
    pressure_angle_rad = pressure_angle * PI / 180;

    // Angle for half a tooth at the pitch circle
    half_tooth_angle_pitch_rad = (PI / (2 * num_teeth));

    // Involute angle at pitch circle
    inv_pitch_rad = tan(pressure_angle_rad) - pressure_angle_rad;

    // Angle from tooth centerline to start of involute on base circle
    // This is the angle from the tooth's centerline to the point where the involute curve starts on the base circle.
    start_involute_angle_offset_rad = half_tooth_angle_pitch_rad - inv_pitch_rad;

    // Angle 't' for involute at the outside radius
    // This is the maximum angle for the involute curve segment.
    max_involute_t_angle_rad = sqrt(pow(outside_radius / base_radius, 2) - 1);

    // Angle of the tooth tip from the centerline
    // This is the angle from the tooth's centerline to the outermost point of the involute curve.
    angle_at_outside_radius_rad = start_involute_angle_offset_rad + max_involute_t_angle_rad;

    tooth_profile_points_list = [];

    // 1. Right side of the tooth (involute curve from base to outside radius)
    // The involute curve is generated starting from (base_radius, 0) and then rotated.
    for (i = [0 : involute_segments]) {
        t_angle = (i / involute_segments) * max_involute_t_angle_rad;
        x_inv = base_radius * (cos(t_angle) + t_angle * sin(t_angle));
        y_inv = base_radius * (sin(t_angle) - t_angle * cos(t_angle));

        // Rotate the involute point by `start_involute_angle_offset_rad`
        rotated_x = x_inv * cos(start_involute_angle_offset_rad) - y_inv * sin(start_involute_angle_offset_rad);
        rotated_y = x_inv * sin(start_involute_angle_offset_rad) + y_inv * cos(start_involute_angle_offset_rad);
        tooth_profile_points_list = concat(tooth_profile_points_list, [[rotated_x, rotated_y]]);
    }

    // 2. Top arc of the tooth (connecting the right and left involute curves)
    // From the last point added (top-right) to the top-left point.
    // The angle of the top-right point is `angle_at_outside_radius_rad`.
    // The angle of the top-left point is `-angle_at_outside_radius_rad`.
    for (i = [1 : involute_segments]) { // Start from 1 to avoid duplicate point
        angle = angle_at_outside_radius_rad - (i / involute_segments) * (2 * angle_at_outside_radius_rad);
        tooth_profile_points_list = concat(tooth_profile_points_list, [[outside_radius * cos(angle), outside_radius * sin(angle)]]);
    }

    // 3. Left side of the tooth (involute curve from outside to base radius)
    // Iterate backwards to connect points correctly.
    for (i = [involute_segments - 1 : -1 : 0]) { // Skip the last point (which is the start of the top arc)
        t_angle = (i / involute_segments) * max_involute_t_angle_rad;
        x_inv = base_radius * (cos(t_angle) + t_angle * sin(t_angle));
        y_inv = base_radius * (sin(t_angle) - t_angle * cos(t_angle));

        // Rotate by `-start_involute_angle_offset_rad` for the left side
        rotated_x = x_inv * cos(-start_involute_angle_offset_rad) - y_inv * sin(-start_involute_angle_offset_rad);
        rotated_y = x_inv * sin(-start_involute_angle_offset_rad) + y_inv * cos(-start_involute_angle_offset_rad);
        tooth_profile_points_list = concat(tooth_profile_points_list, [[rotated_x, rotated_y]]);
    }

    // 4. Root fillet/radial line (left side)
    // This point is at `root_radius` and angle `-start_involute_angle_offset_rad`.
    tooth_profile_points_list = concat(tooth_profile_points_list,
                                      [[root_radius * cos(-start_involute_angle_offset_rad),
                                        root_radius * sin(-start_involute_angle_offset_rad)]]);

    // 5. Root arc (connecting left and right root points)
    // This closes the tooth profile at the root radius.
    // The last point added is the bottom-left corner of the tooth.
    // The first point added was the top-right point of the tooth.
    // We need to connect the bottom-left corner to the bottom-right corner.
    tooth_profile_points_list = concat(tooth_profile_points_list,
                                      [[root_radius * cos(start_involute_angle_offset_rad),
                                        root_radius * sin(start_involute_angle_offset_rad)]]);

    polygon(tooth_profile_points_list);
}

// Main module to generate the spur gear
module spur_gear_main() {
    difference() {
        union() {
            // 1. Base disk up to the root radius
            // This fills the central part of the gear below the teeth.
            cylinder(h = gear_thickness, r = root_radius, $fn = $fn);

            // 2. Generate and extrude each tooth
            for (i = [0 : num_teeth - 1]) {
                rotate(i * (360 / num_teeth)) {
                    linear_extrude(height = gear_thickness) {
                        single_tooth_profile_2d();
                    }
                }
            }

            // 3. Add the hub if its diameter is larger than the bore
            // The hub is placed on one side (from z=0 to z=hub_thickness).
            if (hub_diameter / 2 > bore_diameter / 2 && hub_thickness > 0) {
                cylinder(h = hub_thickness, r = hub_diameter / 2, $fn = $fn);
            }
        }

        // 4. Subtract the central bore
        // The bore cuts through the entire height of the gear, including the hub if present.
        translate([0, 0, -0.01]) { // Translate slightly down to ensure clean cut
            cylinder(h = max(gear_thickness, hub_thickness) + 0.02, r = bore_diameter / 2, $fn = $fn);
        }
    }
}

// Render the spur gear
spur_gear_main();