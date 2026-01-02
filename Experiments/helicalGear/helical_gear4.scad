// Gear parameters
gear_circ_pitch = 7;      // Circular pitch of the gear (mm)
gear_teeth = 20;          // Number of teeth
gear_thickness = 10;      // Thickness of the gear (mm)
gear_shaft_diam = 5;      // Diameter of the shaft hole (mm)
gear_helix_angle = 20;    // Helix angle in degrees (positive for right-hand helix, negative for left-hand helix)
gear_pressure_angle = 20; // Pressure angle in degrees (standard is 20)
gear_backlash = 0;        // Backlash (0 for no backlash)
gear_slices = 64;         // Number of slices for rendering curves (higher for smoother)

include <BOSL2/std.scad>
include <BOSL2/gears.scad>

spur_gear(
    circ_pitch = gear_circ_pitch,
    teeth = gear_teeth,
    thickness = gear_thickness,
    shaft_diam = gear_shaft_diam,
    helical = gear_helix_angle,
    pressure_angle = gear_pressure_angle,
    backlash = gear_backlash,
    slices = gear_slices
);