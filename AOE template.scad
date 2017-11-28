// 3D PRINTER SETTINGS

nozzle = 0.4;
layer = 0.2;

// COMPUTED PARAMETRIC PROPERTIES

hex_circles_ratio = 1 / (sqrt(3) / 2);
cell_size = mm_from_inches(1);
cell_scale = 5;  // how many units (DnD → feet) does a cell represent
cell_radius = cell_size * (sqrt(3)/3);
tr_x = sqrt(3)/2 * cell_size;  // modulo for translation on X axis
tr_y = cell_size / 2;  // modulo for translation on Y axis
grid_line_thickness = nozzle * 3;
//   Thickness: at least 4 extrusion layers or approx the same as walls otherwise
template_height = max(4 * layer, (grid_line_thickness % layer) * layer);

// GEOMETRY

function mm_from_inches(x) = x * 25.4;
function abs_x(x, y) = x * tr_x;
function abs_y(x, y) = y * cell_size + (x % 2) * tr_y;

module hex(x, y, origin) {
  // Extrude a hex cell at the location X, Y on an imaginary hexagonal grid
  carve_radius = (origin) ? 0 : cell_radius - grid_line_thickness / 2;
  linear_extrude(height = template_height, center = false,
    convexity = 10, twist = 0, slices = 1)
    translate([abs_x(x, y), abs_y(x, y), 0])
      difference() {
        circle($fn = 6, r = cell_radius + grid_line_thickness / 2);
        circle($fn = 6, r = carve_radius);
      }
}

// CONDITION VERIFICATION

function compute_angle(a, b) =
  // a, b : vectors
  round(2 * atan2( norm(cross(a, b)), a * b));

function inrange(range, x, y) =
  sqrt(pow(abs_x(x, y), 2) + pow(abs_y(x, y), 2)) <= (ceil(range * cell_size)) ?
    true : false;

function inangle(angle, x, y) =
  compute_angle([0, 1, 0], [abs_x(x, y), abs_y(x, y), 0]) <= angle ?
    true : false;

// BUSINESS LOGIC

module template (range, angle, infill) {
  safe_range = ceil(hex_circles_ratio * range);
  for (x = [-safe_range : safe_range], y = [-safe_range : safe_range]) {
    if (inrange(range, x, y) && inangle(angle, x, y)) {
      if (infill)
        hex(x, y, !(x||y));  // will evaluate `true` at the origin
      else
        hex(x, y, true);  // will create a solid plate
    }
  }
  if (infill)  // add text with range, angle
    linear_extrude(height = template_height + 2 * layer)
      text(text = str("R", range * cell_scale, "A", angle),
           size = cell_size / 6,
           halign = "center",
           valign = "center");
}

template(range = 3, angle = 360, infill = true);
