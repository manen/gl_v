module gen

import os
import json

struct AST {
	inner []Inner [required]
}

struct Inner {
	name     string
	kind     string
	ast_type InnerType [json: 'type']
}

struct InnerType {
	desugared_qual_type string [json: desugaredQualType]
}

pub fn new_ast(path string) ?AST {
	precompiled_path := os.join_path(os.temp_dir(), 'precompiled.h')

	run('gcc -E $path -o $precompiled_path') ?
	raw := run('clang -Xclang -ast-dump=json $precompiled_path') ?

	data := json.decode(AST, raw) ?
	return data
}

pub fn (ast AST) parse() Data {
	fns := ast.inner.filter(it.kind == 'VarDecl' && it.ast_type.desugared_qual_type.contains('(')).map(fn (it Inner) Fn {
		// println('new function: $it.name')
		return Fn{
			name: it.name
			types: parse_fn_types(it.ast_type.desugared_qual_type) or { panic(error) }
		}
	})
	enums := []Enum{} // welp

	return Data{fns, enums}
}

fn parse_fn_types(raw string) ?FnTypes {
	// well this is going to be one scuffed-ass parser for sure
	// println('prescuff: $raw')
	// println('scuff: ${raw.substr(0, raw.index('(*)') ?)}')
	returns := parse_type(raw.substr(0, raw.index('(*)') ?)) ?
	args := raw.substr(raw.index('(*)(') ? + 4, raw.len - 1).split(', ').map(fn (gl string) Type {
		return parse_type(gl) or { panic(error) }
	})

	return FnTypes{returns, args}
}

fn parse_type(raw string) ?Type {
	// println(raw)
	// defer {println('$raw done')}
	if raw.contains('const') {
		return parse_type(raw.replace('const', '').trim(' '))
	}
	if !raw.contains('*') {
		return Type(translate_type(raw.trim(' ')) ?)
	}
	return ComplexType{
		pointer: true
		child: parse_type(raw.trim(' ').substr(0, raw.len - 1).trim(' ')) ?
	}
}

fn translate_type(gl string) ?string {
	// println('GL: $gl')

	if gl.contains('PROC') {
		return gl
	}
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
		else { '/* $gl */' }
	}
}
