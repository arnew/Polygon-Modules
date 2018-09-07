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

function neck(sides) = let( offset = (sides%2)==0?180/sides:0) [for(i = [0:sides]) [cos(360/sides*i+offset),sin(360/sides*i+offset)]];
