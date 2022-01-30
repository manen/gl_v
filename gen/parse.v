module gen

import os

// 1. read c file
// 2. ignore everything that's not a typedef, #define, or GLEW_FUN_EXPORT
// 3. parse (we'll deal with this later)

// the hardest to parse it typedefs
// defines after
// easiest is exports

struct Header {
	enums []Enum

	exports  map[string]string
	defines  map[string]string
	typedefs map[string]FnTypes
}

pub fn new_header(path string) ?Header {
	raw := os.read_file(path) ?
	lines := raw.split('\n')

	enums := parse_enums(lines.filter(is_enum)) ?

	exports := parse_exports(lines.filter(is_export)) ?
	defines := parse_defines(lines.filter(is_define)) ?
	typedefs := parse_typedefs(lines.filter(is_typedef)) ?
	// these could be parallelized!

	return Header{enums, exports, defines, typedefs}
}

pub fn (header Header) parse() Data {
	fns := header.parse_fns()

	return Data{
		fns: fns
		enums: header.enums
	}
}

fn (header Header) parse_fns() []Fn {
	mut fns := []Fn{cap: header.exports.len}

	for name, export_name in header.defines {
		types := header.typedefs[header.exports[export_name]]

		fns << Fn{name, types}
	}

	return fns
}

fn is_enum(line string) bool {
	return line.starts_with('#define GL_') && !line.starts_with('#define GLEW')
}

fn parse_enums(lines []string) ?[]Enum {
	mut res := []Enum{cap: lines.len}

	for raw in lines {
		name_from := 8
		without_define := raw.substr(name_from, raw.len)
		if !without_define.contains(' ') {
			// header definition probably. do something if i fucked something up
			continue
		}
		name_to := without_define.index(' ') ? + name_from // add name_from to accommodate for without_define something blah blah

		val_from := name_to + 1
		val_to := raw.len

		res << Enum{
			name: raw.substr(name_from, name_to)
			val: raw.substr(val_from, val_to)
		}
	}

	return res
}

fn is_export(line string) bool {
	return line.starts_with('GLEW_FUN_EXPORT')
}

fn parse_exports(lines []string) ?map[string]string {
	mut res := map[string]string{} // optimize: set cap for res (currently unsupported by V)

	for raw in lines {
		// don't get confused, the syntax for exports is GLEW_FUN_EXPORT <val> <key>
		// i don't know why either

		val_from := 16
		val_to := raw.index('__') ? - 1 // we're assuming __ is the start of __glewSomeGlFunction + accommodate for space

		key_from := val_to + 1 // add back space
		key_to := raw.len - 1 // accommodate for the semicolon

		res[raw.substr(key_from, key_to)] = raw.substr(val_from, val_to)
	}

	return res
}

fn is_define(line string) bool {
	return line.starts_with('#define gl') && !line.starts_with('#define glew')
}

fn parse_defines(lines []string) ?map[string]string {
	mut res := map[string]string{}

	for raw in lines {
		key_from := 8
		key_to := raw.index('GLEW_GET_FUN') ? - 1

		val_from := raw.index('__') ? // we're assuming __ is the start of __glewSomeFunction
		val_to := raw.len - 1 // accommodate for the ending bracket

		res[raw.substr(key_from, key_to)] = raw.substr(val_from, val_to)
	}

	return res
}

fn is_typedef(line string) bool {
	return line.starts_with('typedef') && line.contains('GLAPIENTRY')
}

fn parse_typedefs(lines []string) ?map[string]FnTypes {
	mut res := map[string]FnTypes{}

	for raw in lines {
		// TODO what the fuck do we do with APIENTRY's????
		// syntax: typedef <return> (GLAPIENTRY * PFN<fn ptr name>PROC) <args>

		returns_from := 8
		returns_to := raw.index('(GL') ? // we're assuming (GL is the start of (GLAPIENTRY
		returns_raw := raw.substr(returns_from, returns_to).trim(' ')
		returns := parse_type(returns_raw, false) ?
		closing_bracket_pos := raw.substr(returns_to, raw.len).index(')') ? + returns_to

		name_from := raw.index('APIENTRY *') ? + 11
		name_to := closing_bracket_pos // we only check a subset of raw so the return type doesn't fuck up
		name := raw.substr(name_from, name_to)

		args_from := closing_bracket_pos + 3
		args_to := raw.len - 2 // remove semicolon and ending bracket
		args_raw := raw.substr(args_from, args_to)
		args := if args_raw != 'void' { parse_args(args_raw) ? } else { []Var{} }

		res[name] = FnTypes{returns, args}
	}

	return res
}

fn parse_args(raw string) ?[]Var {
	if raw.contains('const ') {
		return parse_args(raw.replace('const ', ''))
	}

	args := raw.split(',').map(it.trim(' '))
	mut res := []Var{cap: args.len}

	for arg in args {
		mut separator := ''
		ptr := arg.contains('*')

		if arg.contains(' ') {
			if arg.contains('*') {
				if arg.index(' ') ? < arg.index('*') ? {
					// type *name
					separator = ' *'
				} else {
					// type* name
					separator = '* '
				}
			} else {
				// type name
				separator = ' '
			}
		} else {
			if arg.contains('*') {
				// type*name
				separator = '*'
			} else {
				// only type. :|
				res << Var{
					name: 'x /* no name. */'
					kind: parse_type(arg, ptr) ?
				}
				continue
			}
		}

		kind_from := 0
		kind_to := arg.index(separator) ?
		name_from := kind_to + separator.len
		name_to := arg.len

		name := arg.substr(name_from, name_to)
		kind_raw := arg.substr(kind_from, kind_to)
		kind := parse_type(kind_raw, ptr) ?

		res << Var{name, kind}
	}

	return res
}

fn parse_type(raw string, implied_ptr bool) ?Type {
	if raw.contains('const') {
		return parse_type(raw.replace('const', '').trim(' '), implied_ptr)
	}
	if !raw.contains('*') && !implied_ptr {
		return Type(translate_type(raw.trim(' ')))
	}
	return PtrType{
		child: parse_type(raw.trim(' ').substr(0, raw.len - if raw.contains('*') { 1 } else { 0 }).trim(' '),
			if raw.contains('*') && implied_ptr { true } else { false }) ?
	}
}
