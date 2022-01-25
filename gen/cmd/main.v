module main

import gen

fn main() {
	// println('Hey :D')
	println(gen.new_header('/usr/include/GL/glew.h') ?.parse())
}
