use <helper.scad>

translate([0,-2,0]) fill_polygon(5,0);
translate([0,0,0]) fill_polygon(5,1);
translate([0,2,0]) fill_polygon(5,2);
translate([2,-2,0]) fill_polygon(5,3);

translate([2,0,0]) fill_polygon(5,4);

translate([2,2,0]) fill_polygon(5,5);
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
			scale($continuity)
				scale(0.99) // https://github.com/openscad/openscad/issues/791
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
		//rotate([0,0,(level%2) == 1?180/sides:0])

		polygon_rec(sides,level, level);
	}
}
module polygon_rec(sides, level, depth) {
	if(level > 0) {
		r = 1/( 2*( 1+ pow(norm([ for(k = [1:floor(sides/4)]) sqrt(cos(360*k/sides)      )    ] )  ,2))     );
		union() {          
			rotate([0,0,(level%2)==0?180/sides:0])
				scale(level>1?1:1/r)
				scale($continuity)
				scale(0.9*r) polygon(neck(sides));
			for(i = [1:sides]) 
				rotate([0,0,i*360/sides]) 
				{
					//  rotate([0,0,180/sides])

					translate([1-r,0,0])
						//translate([(1-r)*cos(360/sides), (1-r)*sin(360/sides),0])             //rotate([0,0,(depth-level%2) == 0?180/sides:0])
						//      rotate([0,0,180/sides])
						//            rotate([0,0,180])
						scale(r) polygon_rec(sides,level-1, depth);
					//translate([sqrt(2),sqrt(2),0]) polygon_rec(level-1);
				}
		}
	}
}

function neck(sides) = let( offset = (sides%2)==0?180/sides:0) [for(i = [0:sides]) [cos(360/sides*i+offset),sin(360/sides*i+offset)]];
