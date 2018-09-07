use <helper.scad>

module new_border(side_length,sides, radius, width, height, chamfer, thickness) {
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

module new_snaps(side_length,sides, width, height, radius,bore, radius, snaplen, snaps, snap_trim, border_snap, thickness, bore_trim) {

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
#    translate([width/2-bore_trim/2,side_length/2,0]) rotate([90,0,0]) cylinder(r=bore/2, h=side_length);
					// snap spaces
					for(i=[(border_snap?0:1):snaps-1])
						translate([0,snaplen*(i-snaps/2)+snap_trim,-height/2])
							cube([width,snaplen/2*(i==snaps-1?3:1) - 2*snap_trim,height]);

				}
	}


}
