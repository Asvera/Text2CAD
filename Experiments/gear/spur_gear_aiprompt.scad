// Gear Parameters
// Pitch Diameter (D): The diameter of the pitch circle.
pitch_diameter = 18; // mm

// Module (m): Ratio of pitch diameter to number of teeth.
module_val = 1.0; // mm

// Pressure Angle: Standard angle for involute gears.
pressure_angle = 20; // degrees

// Gear Thickness (H): The width of the gear.
gear_thickness = 5; // mm

// Bore Diameter: Diameter of the center hole.
bore_diameter = 4; // mm

// Derived Parameters
// Number of Teeth (Z): Calculated from Pitch Diameter and Module.
number_of_teeth = pitch_diameter / module_val;

// Pitch Radius
pitch_radius = pitch_diameter / 2;

// Addendum: Radial distance from pitch circle to addendum circle.
addendum = module_val;

// Dedendum: Radial distance from pitch circle to dedendum circle.
// Standard dedendum is 1.25 * module.
dedendum = 1.25 * module_val;

// Base Radius: Radius of the base circle from which the involute curve is generated.
base_radius = pitch_radius * cos(pressure_angle);

// Addendum Radius: Radius of the outermost circle of the gear teeth.
addendum_radius = pitch_radius + addendum;

// Dedendum Radius: Radius of the innermost circle of the gear teeth (root circle).
dedendum_radius = pitch_radius - dedendum;

// Ensure number_of_teeth is an integer.
assert(number_of_teeth == floor(number_of_teeth), "Number of teeth must be an integer (Pitch Diameter / Module).");

// Involute function (angle in radians)
// inv(phi) = tan(phi) - phi
function involute_func(angle_rad) = tan(angle_rad) - angle_rad;

// Function to get the parameter 't' for the involute_coords function at a given radius 'r'.
// 't' is the angle in radians from the base circle tangent point to the involute point.
function get_involute_t(r, r_base) = (r < r_base) ? 0 : sqrt(pow(r/r_base, 2) - 1);

// Function to get (x,y) coordinates of a point on the involute curve.
// 'r_base' is the base radius, 't' is the angle parameter in radians.
function involute_coords(r_base, t) = [
    r_base * (cos(t) + t * sin(t)),
    r_base * (sin(t) - t * cos(t))
];

// Number of steps for generating the involute curve. Higher value means smoother curve.
$fn_involute_steps = 50;

module gear() {
    // Calculate the angular offset for the involute curve from the tooth centerline.
    // This ensures the tooth thickness at the pitch circle is correct.
    // Half tooth thickness at pitch circle is (PI / (2 * number_of_teeth)).
    // The involute function value at the pressure angle is subtracted to get the starting angle for the involute.
    start_involute_angle_rad = (PI / (2 * number_of_teeth)) - involute_func(pressure_angle * PI / 180);

    // Points for one tooth profile
    tooth_profile_points = [];

    // 1. Generate points for the right side of the tooth (involute curve from base_radius to addendum_radius)
    for (i = [0 : $fn_involute_steps]) {
        r = base_radius + (addendum_radius - base_radius) * i / $fn_involute_steps;
        t = get_involute_t(r, base_radius);
        
        // Calculate the angular position of the point relative to the gear center.
        // The involute curve is rotated by `start_involute_angle_rad`.
        current_angle_rad = start_involute_angle_rad + t;
        
        x = r * cos(current_angle_rad);
        y = r * sin(current_angle_rad);
        tooth_profile_points = concat(tooth_profile_points, [[x, y]]);
    }
    
    // 2. Generate points for the left side of the tooth (involute curve from addendum_radius to base_radius)
    // Iterate backwards to maintain correct polygon winding order.
    for (i = [$fn_involute_steps : -1 : 0]) {
        r = base_radius + (addendum_radius - base_radius) * i / $fn_involute_steps;
        t = get_involute_t(r, base_radius);
        
        // Mirror the angle for the left side of the tooth.
        current_angle_rad = -(start_involute_angle_rad + t);
        
        x = r * cos(current_angle_rad);
        y = r * sin(current_angle_rad);
        tooth_profile_points = concat(tooth_profile_points, [[x, y]]);
    }
    
    // 3. Add points for the root fillet/arc (connecting the two base_radius points to the dedendum_radius).
    // The tooth space is centered at 0 degrees relative to the tooth centerline.
    // The half angle of the tooth space at the dedendum circle is PI / (2 * number_of_teeth).
    num_root_steps = 10; // Number of steps for the root arc.
    for (i = [0 : num_root_steps]) {
        // Angle from the tooth centerline to the root arc.
        // The root arc spans the tooth space at the dedendum circle.
        // The tooth is centered at 0 degrees, so the tooth space is centered at 0 degrees.
        // The tooth space half-angle is `PI / (2 * number_of_teeth)`.
        // The root arc connects the two lowest points of the involute.
        // For simplicity, we connect the base circle points to the dedendum circle.
        // The angular position of the root arc points should be calculated relative to the tooth space.
        // The tooth is centered at 0 degrees. The tooth space is centered at `180 / number_of_teeth` degrees.
        // The angle of the tooth space at the dedendum circle is `PI / number_of_teeth`.
        // So, the root arc should span from `-(PI / (2 * number_of_teeth))` to `PI / (2 * number_of_teeth)`.
        
        // The current tooth is centered at 0 degrees.
        // The root arc should connect the two base circle points to the dedendum circle.
        // The angle of the tooth profile at the base circle is `start_involute_angle_rad`.
        // So, the root arc should connect `base_radius * cos(-start_involute_angle_rad)` to `base_radius * cos(start_involute_angle_rad)`.
        // And go down to `dedendum_radius`.
        
        // For a simple root, we can just connect the last point of the left involute (at base_radius)
        // to a point on the dedendum circle, then along the dedendum circle, then up to the first point of the right involute.
        
        // Let's simplify the root by just drawing a circle for the dedendum.
        // The gear body is a cylinder up to the dedendum radius.
        // The teeth are added on top of this.
        
        // A simpler approach for the root:
        // The gear body is a cylinder of `dedendum_radius`.
        // The teeth are then added on top of this.
        // This means the polygon for a single tooth should start at `dedendum_radius` and go up.
        
        // Let's restart the tooth profile generation with a simpler polygon.
        // The core of the gear is a cylinder up to `dedendum_radius`.
        // The teeth are then added on top of this.
        // So, the tooth profile should be a polygon that defines the tooth shape *above* the dedendum circle.
        // This means the polygon should start at the dedendum circle, go up the involute, across the addendum, down the other involute, and then close at the dedendum circle.
        
        // Let's redefine the tooth profile points for a single tooth space.
        // This is easier to union and then subtract the core.
        // No, the request is for a single involute spur gear, using difference() for the bore.
        // So, the main body should be the addendum_radius cylinder, and then subtract the tooth spaces.
        // Or, build the gear from the dedendum_radius cylinder and add the teeth.
        // The latter is more common for OpenSCAD.

        // Let's generate the points for a single tooth.
        // The tooth is centered at 0 degrees.
        // The right side of the tooth is defined by the involute curve.
        // The left side of the tooth is defined by the mirrored involute curve.
        // The root of the tooth is defined by an arc on the dedendum circle.
        
        // Points for the right involute (from base_radius to addendum_radius)
        right_involute_points = [];
        for (j = [0 : $fn_involute_steps]) {
            r = base_radius + (addendum_radius - base_radius) * j / $fn_involute_steps;
            t = get_involute_t(r, base_radius);
            current_angle_rad = start_involute_angle_rad + t;
            right_involute_points = concat(right_involute_points, [[r * cos(current_angle_rad), r * sin(current_angle_rad)]]);
        }
        
        // Points for the left involute (from addendum_radius to base_radius)
        left_involute_points = [];
        for (j = [$fn_involute_steps : -1 : 0]) {
            r = base_radius + (addendum_radius - base_radius) * j / $fn_involute_steps;
            t = get_involute_t(r, base_radius);
            current_angle_rad = -(start_involute_angle_rad + t);
            left_involute_points = concat(left_involute_points, [[r * cos(current_angle_rad), r * sin(current_angle_rad)]]);
        }
        
        // Root arc points (connecting the two base_radius points to the dedendum_radius).
        // The angle of the tooth space at the dedendum circle.
        // The tooth is centered at 0 degrees.
        // The half angle of the tooth space at the dedendum circle is `PI / (2 * number_of_teeth)`.
        // The root arc should connect the two points on the dedendum circle that define the bottom of the tooth space.
        // For a tooth, the root is a circular arc at `dedendum_radius`.
        // The angle of the tooth profile at the base circle is `start_involute_angle_rad`.
        // The angle of