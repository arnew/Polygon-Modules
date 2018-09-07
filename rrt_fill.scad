
function neck(sides) = let( offset = (sides%2)==0?180/sides:0) [for(i = [0:sides]) [cos(360/sides*i+offset),sin(360/sides*i+offset)]];
function lrv(p,q,r) = let ( w = (q[0]-p[0])*(r[1]-p[1]) - (r[0]-p[0])*(q[1]-p[1]) ) (w>0)?1:((w<0)?0:1);

function inside_neck(p,sides) = let(points = neck(sides), check =    norm([ for (i=[0:sides-1]) lrv(points[i],points[i+1],p) ])) check == sqrt(sides);

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
