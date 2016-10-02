
sides = 6;
snaps = 5;
level = 4;
pattern = 1; // [0: Sierpinski/Megnerlike/n-Flakes, 1: Space Tree, 2: RRT] or smileys
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

//radius = side_length/(sqrt(3)); 
//inside = border-border_width/(cos(60)); 


snap_trim = -0.1;
continuity = 0.9;
bore = 1.5    ;
border_snap = false;

//for(sides = [3:6])      translate([100*sides, 0,0])
//for(pattern = [0:2])         translate([0,100*pattern,0])
            mod(sides, pattern, side_length);

module mod(sides, pattern, side_length) {
    
radius = side_length/(2*sin(180/sides)); 
border = radius-snap_width/(cos(180/sides));
inside = border-border_width/(cos(180/sides)); 
snaplen = side_length/snaps;
union(){
          translate([0,0,-thickness/2])
        new_border(sides, radius-snap_width/cos(180/sides), border_width,thickness,chamfer_width);
        new_snaps(sides,snap_width,snap_thickness,radius,bore, radius, snaplen);
new_fill_maker(pattern, level, sides, inside);
 
   
}

}
//rotate([0,0,180])
//translate([radius + 10,0,0]) import("/home/arnew/3D/sierpinski_icosahedron_rrt_tree_l4_5cm.stl");
module triangle() {
    polygon([[1,0],[sin(210),cos(210)],[sin(330),cos(330)]]);
}

module piece_of_cake(sides, radius, height,matsch) {
    step = 360/sides;
    linear_extrude(height, true)
    scale(radius) 
//    rotate([0,0,3*step/4]) 
    polygon([[0,-matsch],[0,matsch],[cos(180-step/2),sin(180-step/2)],[cos(180+step/2),sin(180+step/2)]]);
}

module new_border(sides, radius, width, height, chamfer) {
    flat = (width-chamfer)/cos(180/sides);
    roun = (chamfer)/cos(180/sides);
    for(i = [0:sides-1]) rotate([0,0,360/sides*i])
    union() {
        // flat border part
   difference() {
    piece_of_cake(sides, radius, height,0);     
       translate([0,0,-height/4])
    piece_of_cake(sides, radius-flat, 2*height,1);
    }
    // bottom section of round pard
    difference() {
    piece_of_cake(sides, radius-flat, height-chamfer,0);
        translate([0,0,-height/4])
    piece_of_cake(sides, radius-flat-roun, 2*height,1);
    }
    // take top part of cylinder
    intersection() {
        // limit round parts to pieces
               translate([0,0,chamfer])           piece_of_cake(sides, radius-flat,  chamfer,0);
        
        // cut of bottom part
    difference() {
        // cylinder part
     rotate([0,0,180]) translate([0,0,0])
    translate([(radius-flat)*cos(180/sides),side_length/2,chamfer])
           rotate([90,0,0])
           cylinder(r = thickness/2,h = side_length,$fn=16);
        // cut part
       translate([0,0,-chamfer/2])
            piece_of_cake(sides, radius,  height-chamfer/2,0);

    }
}
    }
}

module new_snaps(sides, width, height, radius,bore, radius, snaplen) {
    
$fn=20;
    difference() {
        
    for(i = [0:sides-1])
        rotate([0,0,i*360/sides])  
intersection() {
    // only produce parts inside the piece of cake
        translate([0,0,-height/2])       piece_of_cake(sides, radius,  height,0);
translate([-radius*cos(180/sides),0,0])
        union() {
            // hinges
            translate([width/2,side_length/2,0]) rotate([90,0,0]) cylinder(r=width/2, h=side_length);
           
            // rectangular part
            translate([width/2,-side_length/2,-height/2])
            cube([width/2,side_length,height]);
        }
    }
        
    for(i = [0:sides-1])
        rotate([0,0,i*360/sides])  translate([-radius*cos(180/sides),0,0])

    union() {
        // bores
      translate([width/2,side_length/2,0]) rotate([90,0,0]) cylinder(r=bore/2, h=side_length);
            // snap spaces
            for(i=[(border_snap?0:1):snaps-1])
                translate([0,snaplen*(i-snaps/2)+snap_trim,-height/2])
                        cube([width,snaplen/2*(i==snaps-1?3:1) - 2*snap_trim,height]);
            
    }
}
    
    
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

module fill_poly(sides, level) {
    if(sides == 3) 
        fill_sierpinski(level);
    else if (sides == 4)
        fill_menger(level);
    else 
        fill_polygon(sides, level);
    
}


module fill_sierpinski(depth) {
    difference() {
        polygon([[1,0],[sin(210),cos(210)],[sin(330),cos(330)]]);
        sierpinski(depth);
    }
}
module sierpinski(rec_level) {     
    if(rec_level > 0) {
        scale(0.5) rotate([0,0,180]) union() {  
            scale(continuity*0.99) // https://github.com/openscad/openscad/issues/791
                        triangle();
            for(i = [0:2]) 
                rotate([0,0,i*120]) translate([-1,0]) rotate([0,0,180])     
                    sierpinski(rec_level-1);
        }
    }
}

module fill_menger(level) {
        difference() {
            polygon(neck(4));
            menger(level);
    }
}
module menger(level) {
    if(level > 0) {
        scale(1/3) union() {polygon(neck(4));
        for(i = [0:3]) rotate([0,0,i*90]) {
            
            translate([sqrt(2),0,0]) menger(level-1);
            translate([sqrt(2),sqrt(2),0]) menger(level-1);
        }
    }
    }
}

module fill_polygon(sides,level) {
        difference() {
            polygon(neck(sides));
            rotate([0,0,(sides%2) == 1?180/sides:0])
            polygon_rec(sides,level);
    }
}
module polygon_rec(sides, level) {
    if(level > 0) {
        r = 1/( 2*( 1+ pow(norm([ for(k = [1:floor(sides/4)]) sqrt(cos(360*k/sides)      )    ] )  ,2))     );
        union() {           
        scale(level>1?r:1) 
polygon(neck(sides));
        for(i = [1:sides]) rotate([0,0,i*360/sides-180/sides]) {
          #  translate([(1-r)*cos(360/sides), (1-r)*sin(360/sides),0])             rotate([0,0,(sides%2) == 0?180/sides:0])
 rotate([0,0,(level%2)==1?180:0]) scale(r) polygon_rec(sides,level-1);
            //translate([sqrt(2),sqrt(2),0]) polygon_rec(level-1);
        }
    }
    }
}

module space_tree_fill(sides, level, width) {
    offset = (sides%2)==0?180/sides:0;
    rotate([0,0,offset]) space_tree(sides, level, width);
    
}
module space_tree(sides,level,width) {
    for(i = [1:sides])
        rotate([0,0,i*360/sides])
    scale([1/2,width,1])
    translate([0,-1/2,-1/2])
    square(1);
    
    if(level > 1){
        rotate([0,0,180])
        scale([1/2,1/2,1])
        space_tree(sides, level-1, width*2);
        for (i= [1:sides])
            rotate([0,0,i*360/sides])
        translate([1/2,0,0])
        scale([1/2,1/2,1])
         space_tree(sides, level-1, width*2); 
    }
}


function neck(sides) = let( offset = (sides%2)==0?180/sides:0) [for(i = [0:sides]) [cos(360/sides*i+offset),sin(360/sides*i+offset)]];
function lrv(p,q,r) = 
    let (
        w = (q[0]-p[0])*(r[1]-p[1]) - (r[0]-p[0])*(q[1]-p[1])) (w>0)?1:((w<0)?0:1);

function inside_neck(p,sides) =
    let(points = neck(sides),
check =    norm([ for (i=[0:sides-1]) lrv(points[i],points[i+1],p) ])) check == sqrt(sides);

function random_n_sides(sides) =
    let(p=rands(-1,1,2))
    inside_neck(p,sides)?p:random_n_sides(sides);
        
module line(a,b,width) {
   
    center = (a+b)/2;
    diff = a-b;
    translate(center)  
  rotate([0,0,90+atan2(diff[1],diff[0])])  
    scale([width,norm(diff)])
    square(1,true);
    
}
function find_near(G,v) = 
    real_near(G,1,v,G[0]);

function real_near(G,i,v,mn) = 
    (len(G)-i>0)?
    (
(norm(v-mn) < norm(v-G[i])) ? real_near(G,i+1,v,mn) :
real_near(G,i+1,v,G[i])
):
        mn;
     

module rrt_fill(sides,K,width,dq) {
    G = [[0,0]];
    rrt_walk(sides,G,K,width,dq);
}
module rrt_walk(sides,G,k,width,dq)  {
    if(k>0) {
      q_r = random_n_sides(sides);
      q_n = find_near(G,q_r);
      q = q_n + (q_r-q_n)*dq;
      G = concat(G,[q]);
      line(q,q_n,width);
        
        
    rrt_walk(sides,G,k-1,width,dq);
    }
}

module smily_2d(type, radius, line_thickness, inverse) {
	difference() {
		if(inverse) {
			circle(radius);
		}
		assign(scale_factor = inverse ? radius / (radius + line_thickness) : 1)
		scale([scale_factor, scale_factor])
		translate([0, 0, -0.1])
		difference() {
			circle(radius);
			for(i = [-1 : 2 : 1]) {
				translate([i * (sqrt(2) / 6) * radius, (sqrt(2) / 4) * radius])
				scale([1, 2]) {
					if(type == ";)" && i == -1) {
						scale([2, 0.2]) {
							circle(line_thickness, $fn = 15);
						}
					}
					else {
						circle(line_thickness, $fn = 15);
					}
				}
			}

			// The mouth
			assign(ratio = 0.6)
			mirror([0, type == ":(" ? 1 : 0])
			translate([0, type == ":(" ? ratio * radius + line_thickness : 0]) {
				if(type == ":|") {
					translate([0, -0.4 * radius]) {
						square([radius, line_thickness], center = true);
						for(i = [-1 : 2 : 1]) {
							translate([i * radius / 2, 0]) {
								circle(line_thickness / 2, $fn = 15);
							}
						}
					}
				}
				else {
					scale([1.1, 1]) {
						translate([0, -0.15 * radius])
						difference() {
							circle(ratio * radius);
							if(type != ":D") {
								circle(ratio * radius - line_thickness);
							}
							translate([-ratio * radius - 0.1, 0, 0]) {
								square([2 * ratio * radius + 2 * 0.1, ratio * radius + 0.1]);
							}
						}
						if(type != ":D") {
							for(i = [-1 : 2 : 1]) {
								translate([i * ratio * radius - i * line_thickness / 2, -0.15 * radius]) {
									circle(line_thickness / 2, $fn = 15);
								}
							}
						}
					}
				}
			}
		}		
	}
}
