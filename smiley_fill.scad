
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
