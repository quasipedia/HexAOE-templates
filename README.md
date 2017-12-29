# HexAOE-templates
An OpenSCAD script to generate area of effect templates for hex grids (for RPG games like DnD)

This is a customisable script that can produce templates for area of effect (AOE) events (blasts, spells, beams...).
It is meant to generate STL files for 3D printing.

The variables at the top of the script allow to:

- **optimise sizing** for your print extrusion settings
- set the values associated with the map (**cell size, scale, unit of measurement**)
- input the **radius** of the effect and the **angle** of its cone (use 0 for lines like "ray of frost" or "laser beam", and 360 for things like "blasts" or "toxic cloud"... and anything in-between for the rest!
- choose if you want the template to produce the internal geometry of the map (the hexagons enclosed in the area) or just its contour.
