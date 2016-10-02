
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

