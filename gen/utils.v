module gen

import os

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
		// else { error('Unknown GL type $gl') }
		else { '/* $gl */ voidptr' }
	}
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
