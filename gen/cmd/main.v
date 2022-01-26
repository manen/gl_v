module main

import gen

fn main() {
	gen.new_header('/usr/include/GL/glew.h') ?.parse().write(
		root: '.'
		fns_file: 'fns.v'
		enums_file: 'enums.v'
	) ?
}
