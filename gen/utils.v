module gen

import os

const (
	reserved_words   = ['as', 'asm', 'assert', 'atomic', 'break', 'const', 'continue', 'defer',
		'else', 'embed', 'enum', 'false', 'fn', 'for', 'go', 'goto', 'if', 'import', 'in',
		'interface', 'is', 'lock', 'match', 'module', 'mut', 'none', 'or', 'pub', 'return', 'rlock',
		'select', 'shared', 'sizeof', 'static', 'struct', 'true', 'type', 'typeof', 'union', 'unsafe',
		'volatile', '__offsetof', 'map', 'string']
	reserved_numbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
)

fn translate_type(gl string) string {
	return match gl {
		'GLenum' { 'u32' }
		'GLbitfield' { 'u32' }
		'GLuint' { 'u32' }
		'GLint' { 'int' }
		'GLsizei' { 'int' }
		'GLboolean' { 'u8' }
		'GLbyte' { 'i8' }
		'GLshort' { 'i16' }
		'GLubyte' { 'u8' }
		'GLushort' { 'u16' }
		'GLulong' { 'u64' }
		'GLfloat' { 'f32' }
		'GLclampf' { 'f32' }
		'GLdouble' { 'f64' }
		'GLclampd' { 'f64' }
		'GLsizeiptr' { 'i64' }
		'GLintptr' { 'i64' }
		'GLchar' { 'char' }
		'GLint64' { 'i64' }
		'GLuint64' { 'u64' }
		'GLuint64EXT' { 'u64' }
		'GLvoid' { '' }
		'void' { '' }
		'GLsync' { 'voidptr' }
		'cl_context' { 'voidptr' }
		'cl_event' { 'voidptr' }
		'GLhandleARB' { 'u32' }
		'GLcharARB' { 'char' }
		'GLsizeiptrARB' { 'i64' }
		'GLintptrARB' { 'i64' }
		'GLeglImageOES' { 'voidptr' }
		'GLeglClientBufferEXT' { 'voidptr' }
		'GLint64EXT' { 'i64' }
		'GLhalf' { 'u16' }
		'GLvdpauSurfaceNV' { 'i64' }
		'GLfixed' { 'int' }
		'GLclampx' { 'int' }
		'char' { 'char' }
		// else { error('Unknown GL type $gl') }
		else { '/* $gl */ voidptr' }
	}
}

// unreserve_word is a handy function to convert function/variable/argument/constant names that
// are invalid in V to names that are actually valid in V.
fn unreserve_word(raw string) string {
	if is_invalid(raw) {
		return 'gl_$raw'
	} else {
		return raw
	}
}

// is_invalid checks if a function/variable/argument/constant name would be
// invalid in V.
// inevitably O(n^2), probably a performance pain point.
fn is_invalid(name string) bool {
	if name[0..1].is_upper() {
		return true
	}
	for reserved in gen.reserved_numbers {
		if name.starts_with(reserved) {
			return true
		}
	}
	for reserved in gen.reserved_words {
		if name == reserved {
			return true
		}
	}

	return false
}

fn translate_enum(name string) string {
	if name.starts_with('GLEW_') {
		return 'glew_${translate_enum(name.replace('GLEW_', 'xx'))}'
	}
	remove := if name.starts_with('GL_') { 3 } else { 2 }
	return name.substr(remove, name.len).to_lower()
}

fn translate_fun(name string) string {
	return to_snake_case(name.substr(if !name.to_lower().starts_with('glew') { 2 } else { 0 },
		name.len), true)
}

enum SnakeCaseParserPrev {
	letter
	capital
	number
}

fn (mut prev SnakeCaseParserPrev) set(c u8) {
	if c.is_digit() {
		prev = .number
		return
	}
	if c.is_capital() {
		prev = .capital
		return
	}
	prev = .letter
}

fn to_snake_case(camel_case string, ignore_starting_capital bool) string {
	// requirements:
	// createShader -> create_shader
	// something3D -> something_3d
	// somethingElseARB -> something_else_arb

	// so
	// 1. if capital, insert underscore and lowercase
	// 2. if capital after number, only lowercase
	// 3. if multiple capitals right after each other, first an underscore and lowercase, then only lowercase
	mut res := []u8{cap: camel_case.len}

	mut prev := if ignore_starting_capital {
		SnakeCaseParserPrev.capital
	} else {
		SnakeCaseParserPrev.letter
	}
	for c in camel_case.bytes() {
		match prev {
			.letter {
				if c.is_capital() {
					res << `_`
				}
			}
			.capital {}
			.number {}
		}
		prev.set(c)
		res << if c.is_capital() { c.ascii_str().to_lower().bytes()[0] } else { c }
	}

	return res.bytestr()
}

fn validify_enum(val string) string {
	return match val {
		'0xFFFFFFFFFFFFFFFFull' { '0xFFFFFFFFFFFFFFFF' }
		'0xFFFFFFFFu' { '0xFFFFFFFF' }
		else { val }
	}
}

fn make_sure_dir_exists(path string) ? {
	if !os.exists(path) {
		os.mkdir(path)?
	}
}

fn string_index_last(str string, find string) ?int {
	return str.len - (str.reverse().index(find.reverse())? + find.len)
}

fn string_count(str string, find u8) int {
	mut count := 0
	for b in str.bytes() {
		if b == find {
			count++
		}
	}
	return count
}
