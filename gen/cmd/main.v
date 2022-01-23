module main

import gen

fn main() {
	// println('Hey :D')
	println(gen.new_ast('/usr/include/GL/glew.h') ?.parse())
}
