
snaps=5
side_length=60

for sides in 3 4 5 6; do
for pattern in 0 1 2 ":)" ":D" ";)" ; do
for level in 4 5 6; do
	echo openscad -o "tile_len${side_length}_snap${snaps}_sides${sides}_pat${pattern}_lev${level}.stl" -D side_length=${side_length} -D snaps=${snaps} -D sides=${sides} -D pattern=${pattern} -D level=${level} generator.scad
	openscad -o "tile_len${side_length}_snap${snaps}_sides${sides}_pat${pattern}_lev${level}.stl" -D side_length=${side_length} -D snaps=${snaps} -D sides=${sides} -D pattern=${pattern} -D level=${level} generator.scad
done
done
done
