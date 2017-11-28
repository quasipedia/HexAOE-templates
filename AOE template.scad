// ©2017 - Mac Ryan <quasipedia@gmail.com>
// CC-Attribution-ShareAlike-NonCommercial

/* [PRINTER SETTINGS] */
nozzle_diameter = 0.4;
layer_height = 0.2;

/* [MAP SETTINGS] */
cell_units = "inches";  // [inches,millimiters]
// The cell size is measured side-to-side, not vertex-to-vertex
cell_size = 1;
// How many units does a cell represent in-game (e.g.: "5" if it represents 5 feet)
cell_scale = 5;

/* [TEMPLATE GEOMETRY] */
// Minimun thickness (mm) of the template lines (will be approximated up to a nozzle multiple)
approx_width = 1;
// Minimum height (mm) of the template (will be approximated up to a layer height multiple)
approx_height = 3;
// Range (in number of cells, not in-game units)
range = 6;  // [1:30]
// Angle (in degrees)
angle = 90;  // [0:360]
// Only create the outer edge of the template, as opposed to the full honeycomb
contour_only = "no";  // [yes,no]

/* [Hidden] */
hex_circles_ratio = 1 / (sqrt(3) / 2);
mm_cell_size = cell_units == "inches" ? mm_from_inches(1) : cell_size;
echo(mm_cell_size);
cell_radius = mm_cell_size * (sqrt(3)/3);
tr_x = sqrt(3)/2 * mm_cell_size;  // modulo for translation on X axis
tr_y = mm_cell_size / 2;  // modulo for translation on Y axis
grid_line_thickness = ceil(approx_width / nozzle_diameter) * nozzle_diameter;
template_height = ceil(approx_height / layer_height) * layer_height;

// GEOMETRY

function mm_from_inches(x) = x * 25.4;
function abs_x(x, y) = x * tr_x;
function abs_y(x, y) = y * mm_cell_size + (x % 2) * tr_y;

module hex(x, y, origin, extra_padding) {
  // Extrude a hex cell at the location X, Y on an imaginary hexagonal grid
  carve_radius = (origin) ? 0 : cell_radius - grid_line_thickness / 2;
  linear_extrude(height = template_height, center = false,
    convexity = 10, twist = 0, slices = 1)
    translate([abs_x(x, y), abs_y(x, y), 0])
      difference() {
        circle($fn = 6, r = cell_radius + grid_line_thickness / 2 + extra_padding);
        circle($fn = 6, r = carve_radius);
      }
}

// CONDITION VERIFICATION

function compute_angle(a, b) =
  // a, b : vectors
  round(2 * atan2( norm(cross(a, b)), a * b));

function inrange(range, x, y) =
  sqrt(pow(abs_x(x, y), 2) + pow(abs_y(x, y), 2)) <= (ceil(range * mm_cell_size)) ?
    true : false;

function inangle(angle, x, y) =
  compute_angle([0, 1, 0], [abs_x(x, y), abs_y(x, y), 0]) <= angle ?
    true : false;

// BUSINESS LOGIC

module base_geometry(range, angle, infill, extra_padding) {
  safe_range = ceil(hex_circles_ratio * range);
  for (x = [-safe_range : safe_range], y = [-safe_range : safe_range]) {
    if (inrange(range, x, y) && inangle(angle, x, y)) {
      if (infill)
        hex(x, y, !(x||y), extra_padding);  // will evaluate `true` at the origin
      else
        hex(x, y, true, extra_padding);  // will create a solid plate
    }
  }
}

module template(range, angle, infill) {
  if (infill) {  // add text with range, angle
    base_geometry(range, angle, infill, extra_padding = 0);
    linear_extrude(height = template_height + 2 * layer_height)
      text(text = str("R", range * cell_scale, "A", angle),
        size = mm_cell_size / 6,
        halign = "center",
        valign = "center");
  } else {
    difference() {
      base_geometry(range, angle, infill, extra_padding = grid_line_thickness);
      base_geometry(range, angle, infill, extra_padding = 0);
    }
  }
}

template(range = range, angle = angle, infill = contour_only == "no");
