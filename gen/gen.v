module gen

import os

fn head(body string) string {
	return 'module gl

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

pub struct WriteConfig {
	root string

	fns_file   string
	enums_file string
}

pub fn (data Data) fns_str() string {
	fns := data.fns.map(it.str()).join('\n')
	return head(fns)
}

pub fn (data Data) enums_str() string {
	raw := data.enums.map(it.str()).join('\n')
	enums := 'const (\n$raw\n)'
	return head(enums)
}

pub fn (data Data) write(conf WriteConfig) ? {
	os.write_file(os.join_path(conf.root, conf.fns_file), data.fns_str()) ?
	os.write_file(os.join_path(conf.root, conf.enums_file), data.enums_str()) ?
}

struct Fn {
	name  string
	types FnTypes
}

fn (fun Fn) str() string {
	name := fun.name.replace('__glew', 'gl').substr(0, fun.name.len)

	returns := if fun.types.returns != Type('') { ' $fun.types.returns.str()' } else { '' }
	args := fun.types.args.map(it.str()).join(', ')

	return 'fn C.${name}($args)$returns'
}

struct FnTypes {
	returns Type
	args    []Var
}

struct Var {
	name string
	kind Type
}

fn (var Var) str() string {
	return '$var.name $var.kind.str()'
}

struct ComplexType {
	pointer bool
	child   Type
}

fn (ty ComplexType) str() string {
	if ty.pointer && ty.child.str() == '' {
		return 'voidptr'
	}

	pointer := if ty.pointer { '&' } else { '' }
	return '$pointer$ty.child.str()'
}

type Type = ComplexType | string

fn (ty Type) str() string {
	return match ty {
		ComplexType { ty.str() }
		string { ty }
	}
}

struct Enum {
	name string
	val  string
}

fn (en Enum) str() string {
	name := translate_enum(en.name)
	return '\t$name = $en.val'
}
