module gen

struct Data {
	fns   []Fn
	enums []Enum
}

struct Fn {
	name  string
	types FnTypes
}

struct FnTypes {
	returns Type
	args    []Var
}

struct Var {
	name string
	kind Type
}

struct ComplexType {
	pointer bool
	child   Type
}

type Type = ComplexType | string

struct Enum {
	name string
	val  string
}

fn (data Data) str() string {
	enums := data.enums.map(it.str()).join('\n')
	fns := data.fns.map(it.str()).join('\n')

	return 'module gl\n\n$enums\n$fns'
}

fn (fun Fn) str() string {
	name := fun.name.replace('__glew', 'gl')

	returns := ' $fun.types.returns.str()'
	args := fun.types.args.map(it.str()).join(', ')

	return 'fn C.${name}($args) $returns'
}

fn (var Var) str() string {
	return '$var.name $var.kind.str()'
}

fn (ty Type) str() string {
	return match ty {
		ComplexType { ty.str() }
		string { ty }
	}
}

fn (ty ComplexType) str() string {
	if ty.pointer && ty.child.str() == '' {
		return 'voidptr'
	}

	pointer := if ty.pointer { '&' } else { '' }
	return '$pointer$ty.child.str()'
}

fn (en Enum) str() string {
	return 'const $en.name = $en.val'
}
