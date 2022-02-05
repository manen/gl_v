module gen

import os

enum Module {
	gl
	sys
}

fn (mod Module) gen() string {
	return match mod {
		.gl { 'gl' }
		.sys { 'sys' }
	}
}

fn head(body string, mod Module) string {
	return 'module $mod.gen()

// generated by the gl_v bindings generator
// do not edit by hand

$body

// generated by the gl_v bindings generator
// do not edit by hand\n'
}

struct Data {
	fns   []Fn
	enums []Enum
}

pub fn (fns []Fn) gen(mod Module) string {
	return head(fns.map(it.gen()).join('\n'), mod)
}

pub fn (enums []Enum) gen(mod Module) string {
	return head(enums.map(it.gen()).join('\n'), mod)
}

pub fn (fns []Fn) gen_bindings() string {
	raw := fns.map(it.gen_binding()).join('\n')
	return head('#pkgconfig glew
#include <GL/glew.h>

$raw', .sys)
}

pub struct WriteConfig {
	root string

	fns_file      string
	enums_file    string
	bindings_file string
}

pub fn (data Data) write(conf WriteConfig) ? {
	make_sure_dir_exists(conf.root) ?
	os.write_file(os.join_path(conf.root, conf.fns_file), data.fns.gen(.sys)) ?
	os.write_file(os.join_path(conf.root, conf.enums_file), data.enums.gen(.sys)) ?
	os.write_file(os.join_path(conf.root, conf.bindings_file), data.fns.gen_bindings()) ?
}

struct Fn {
	name  string
	types FnTypes
}

fn (fun Fn) gen() string {
	returns := if fun.types.returns != Type('') { ' $fun.types.returns.gen()' } else { '' }
	args := fun.types.args.map(it.gen()).join(', ')

	return 'fn C.${fun.name}($args)$returns'
}

fn (fun Fn) gen_binding() string {
	if_returns := if fun.types.returns != Type('') { 'return ' } else { '' }

	return '[inline]
pub fn ${translate_fun(fun.name)}(${fun.types.args.map(it.gen()).join(', ')}) $fun.types.returns.gen() {
	${if_returns}C.${fun.name}(${fun.types.args.map(unreserve_word(it.name)).join(', ')})
}'
}

struct FnTypes {
	returns Type
	args    []Var
}

struct Var {
	name string
	kind Type
}

fn (var Var) gen() string {
	name := unreserve_word(var.name)
	return '$name $var.kind.gen()'
}

struct PtrType {
	child Type
}

fn (ty PtrType) gen() string {
	if ty.child == Type('') {
		return 'voidptr'
	}
	return '&$ty.child.gen()'
}

struct ArrayType {
	len   int
	child Type
}

fn (ty ArrayType) gen() string {
	return '[$ty.len]$ty.child.gen()'
}

type Type = ArrayType | PtrType | string

fn (ty Type) gen() string {
	return match ty {
		string { ty }
		PtrType { ty.gen() }
		ArrayType { ty.gen() }
		// using else here caused a segfault
	}
}

struct Enum {
	name string
	val  string
}

fn (en Enum) gen() string {
	name := unreserve_word(translate_enum(en.name))
	return 'pub const $name = $en.val'
}
