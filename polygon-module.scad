use <helper.scad>
use <polygon.scad>
use <rrt_fill.scad>
use <sierpinski_fill.scad>
use <smiley_fill.scad>
use <spacetree_fill.scad>


sides = 3;
snaps = 5;
level = 4;
pattern =":)"; // [0: Sierpinski/Megnerlike/n-Flakes, 1: Space Tree, 2: RRT] or smileys
side_length = 60; 

// Set the thickness of the tile, in mm
thickness = 4;
snap_thickness=4;
fill_pattern_thickness=0.9;
fill_canvas_thickness=0.3;

// Set the border thickness, in mm
border_width = 2;	
chamfer_width = 2;
snap_width = 4;

snap_trim = -0.1;
continuity = 0.9;
bore = 1.5    ;
border_snap = false;

//for(sides = [3:6])      translate([100*sides, 0,0])
//for(pattern = [0:2])         translate([0,100*pattern,0])
            mod(sides, snaps, pattern, side_length,level);

module mod(sides, snaps, pattern, side_length,level) {
    
radius = side_length/(2*sin(180/sides)); 
border = radius-snap_width/(cos(180/sides));
inside = border-border_width/(cos(180/sides)); 
snaplen = side_length/snaps;
          translate([0,0,-thickness/2])
        new_border(side_length,sides, radius-snap_width/cos(180/sides), border_width,thickness,chamfer_width, thickness);
        new_snaps(side_length,sides,snap_width,snap_thickness,radius,bore, radius, snaplen, snaps, snap_trim, border_snap, thickness);
new_fill_maker(pattern, level, sides, inside);
 
   

}

module new_fill_maker(mode, level, sides, radius) { 
        union() {
            translate([0,0,-thickness/2 + fill_canvas_thickness]) {
                linear_extrude(fill_pattern_thickness) {
                    scale(radius) {
                        if(mode == 0) 
                     fill_poly(sides,level);
                        else if (mode ==1)
                       space_tree_fill(sides,level,0.01) ;
                        else if(mode == 2)
                       rrt_fill(sides,(sides*sides)*5*level,0.01,3/4);
                        else
                        smily_2d(mode,0.5,0.05,true,$fn=20);
                    }
                }
            }
            for(i = [0:sides]) rotate([0,0,360/sides*i])
            translate([0,0,-thickness/2]) {
                           piece_of_cake(sides, radius,  fill_canvas_thickness,0);
            }
        }
}

