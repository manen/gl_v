module gen

import os

const (
	reserved_words   = ['as', 'asm', 'assert', 'atomic', 'break', 'const', 'continue', 'defer',
		'else', 'embed', 'enum', 'false', 'fn', 'for', 'go', 'goto', 'if', 'import', 'in',
		'interface', 'is', 'lock', 'match', 'module', 'mut', 'none', 'or', 'pub', 'return', 'rlock',
		'select', 'shared', 'sizeof', 'static', 'struct', 'true', 'type', 'typeof', 'union', 'unsafe',
		'volatile', '__offsetof']
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
	remove := if name.starts_with('GL_') { 3 } else { 2 }
	return name.substr(remove, name.len).to_lower()
}

fn make_sure_dir_exists(path string) ? {
	if !os.exists(path) {
		os.mkdir(path) ?
	}
}

fn string_index_last(str string, find string) ?int {
	return str.len - (str.reverse().index(find.reverse())? + find.len)
}
