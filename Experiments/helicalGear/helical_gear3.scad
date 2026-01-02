// Gear parameters
gear_circ_pitch = 7;      // Circular pitch of the gear (mm)
gear_teeth = 20;          // Number of teeth on the gear
gear_thickness = 10;      // Thickness of the gear (mm)
gear_shaft_diam = 5;      // Diameter of the shaft hole (mm)
gear_helical_angle = 0;   // Helical angle in degrees (0 for spur gear)
gear_slices = 24;         // Number of slices for smoother curves

include <BOSL2/std.scad>
include <BOSL2/gears.scad>

spur_gear(
    circ_pitch = gear_circ_pitch,
    teeth = gear_teeth,
    thickness = gear_thickness,
    shaft_diam = gear_shaft_diam,
    helical = gear_helical_angle,
    slices = gear_slices
);