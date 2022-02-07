module main

import sys as gl
import os

#pkgconfig glfw3
#include <GLFW/glfw3.h>
// you probably don't want to use GLFW like this.
// look at glfw_v instead: https://github.com/manen/glfw_v (shameless plug)

fn C.glfwDefaultWindowHints()
fn C.glfwWindowHint(hint int, val int)
fn C.glfwWindowHintString(hint int, val &char)
fn C.glfwCreateWindow(width int, height int, title &char, monitor voidptr, share voidptr) voidptr
fn C.glfwDestroyWindow(window voidptr)
fn C.glfwWindowShouldClose(window voidptr) int
fn C.glfwSetWindowShouldClose(window voidptr, val int)
fn C.glfwSetWindowTitle(window voidptr, title &char)
fn C.glfwSetWindowIcon(window voidptr, count int, images voidptr)
fn C.glfwGetWindowPos(window voidptr, xpos &int, ypos &int)
fn C.glfwSetWindowPos(window voidptr, xpos int, ypos int)
fn C.glfwGetWindowSize(window voidptr, width &int, height &int)
fn C.glfwSetWindowSizeLimits(window voidptr, minwidth int, minheight int, maxwidth int, maxheight int)
fn C.glfwSetWindowAspectRatio(window voidptr, number int, denom int)
fn C.glfwSetWindowSize(window voidptr, width int, height int)
fn C.glfwGetFramebufferSize(window voidptr, width &int, height &int)
fn C.glfwGetWindowFrameSize(window voidptr, left &int, top &int, right &int, bottom &int)
fn C.glfwGetWindowContentScale(window voidptr, xscale &f32, yscale &f32)
fn C.glfwGetWindowOpacity(window voidptr) f32
fn C.glfwSetWindowOpacity(window voidptr, opacity f32)
fn C.glfwIconifyWindow(window voidptr)
fn C.glfwRestoreWindow(window voidptr)
fn C.glfwMaximizeWindow(window voidptr)
fn C.glfwShowWindow(window voidptr)
fn C.glfwHideWindow(window voidptr)
fn C.glfwFocusWindow(window voidptr)
fn C.glfwRequestWindowAttention(window voidptr)
fn C.glfwGetWindowMonitor(window voidptr) voidptr
fn C.glfwSetWindowMonitor(window voidptr, monitor voidptr, xpos int, ypos int, width int, height int, refreshRate int)
fn C.glfwGetWindowAttrib(window voidptr, attrib int) int
fn C.glfwSetWindowAttrib(window voidptr, attrib int, val int)
fn C.glfwSetWindowUserPointer(window voidptr, pointer voidptr)
fn C.glfwGetWindowUserPointer(window voidptr) voidptr
fn C.glfwSetWindowPosCallback(window voidptr, callback voidptr)
fn C.glfwSetWindowSizeCallback(window voidptr, callback voidptr)
fn C.glfwSetWindowCloseCallback(window voidptr, callback voidptr)
fn C.glfwSetWindowRefreshCallback(window voidptr, callback voidptr)
fn C.glfwSetWindowFocusCallback(window voidptr, callback voidptr)
fn C.glfwSetWindowIconifyCallback(window voidptr, callback voidptr)
fn C.glfwSetWindowMaximizeCallback(window voidptr, callback voidptr)
fn C.glfwSetFramebufferSizeCallback(window voidptr, callback voidptr)
fn C.glfwSetWindowContentScaleCallback(window voidptr, callback voidptr)
fn C.glfwPollEvents()
fn C.glfwWaitEvents()
fn C.glfwWaitEventsTimeout(timeout f64)
fn C.glfwPostEmptyEvent()
fn C.glfwSwapBuffers(window voidptr)

fn C.glfwMakeContextCurrent(window voidptr)

fn C.glfwInit() int
fn C.glfwTerminate()

const (
	width  = 854
	height = 480
	verts  = [
		f32(0.5),
		0.5,
		0.0, // top right
		0.5,
		-0.5,
		0.0, // bottom right
		-0.5,
		-0.5,
		0.0, // bottom left
		-0.5,
		0.5,
		0.0, // top left
	]
	inds   = [
		u32(0),
		1,
		3, // first triangle
		1,
		2,
		3, // second triangle
	]
)

fn main() {
	win := create_window() ?
	init_glew() ?

	gl.viewport(0, 0, width, height)

	mut vbo, mut vao, mut ebo := u32(0), u32(0), u32(0)
	gl.gen_buffers(1, &mut vbo)
	gl.bind_buffer(gl.array_buffer, vbo)
	gl.buffer_data(gl.array_buffer, verts.len * 4, verts.data, gl.static_draw)

	gl.gen_vertex_arrays(1, &mut vao)
	gl.bind_vertex_array(vao)
	gl.bind_buffer(gl.array_buffer, vbo)
	gl.buffer_data(gl.array_buffer, verts.len * 4, verts.data, gl.static_draw)

	gl.gen_buffers(1, &mut ebo)
	gl.bind_buffer(gl.element_array_buffer, ebo)
	gl.buffer_data(gl.element_array_buffer, inds.len * 4, inds.data, gl.static_draw)

	gl.vertex_attrib_pointer(0, 3, gl.float, gl.gl_false, 3 * 4, voidptr(0))
	gl.enable_vertex_attrib_array(0)

	prog := load_shaders('./test_app/vert.glsl', './test_app/frag.glsl') ?

	for C.glfwWindowShouldClose(win) == 0 {
		gl.clear_color(0.2, 0.3, 0.3, 1.0)
		gl.clear(gl.color_buffer_bit | gl.depth_buffer_bit)

		gl.use_program(prog)
		gl.bind_vertex_array(vao)
		gl.draw_elements(gl.triangles, 6, gl.unsigned_int, voidptr(0))
		gl.bind_vertex_array(0)

		C.glfwSwapBuffers(win)
		C.glfwPollEvents()
	}
}

fn create_window() ?voidptr {
	if C.glfwInit() == 0 {
		return error('Failed to initialize GLFW. yikes')
	}

	C.glfwWindowHint(C.GLFW_CONTEXT_VERSION_MAJOR, 3)
	C.glfwWindowHint(C.GLFW_CONTEXT_VERSION_MINOR, 3)
	C.glfwWindowHint(C.GLFW_OPENGL_PROFILE, C.GLFW_OPENGL_CORE_PROFILE)

	win := C.glfwCreateWindow(width, height, 'Something'.str, voidptr(0), voidptr(0))
	if win == voidptr(0) {
		C.glfwTerminate()
		return error('Failed to open window')
	}
	C.glfwMakeContextCurrent(win)

	return win
}

fn init_glew() ? {
	if gl.glew_init() != 0 {
		return error('Failed to initialize GLEW')
	}
}

fn load_shaders(vert_path string, frag_path string) ?u32 {
	vert_src := os.read_file(vert_path) ?
	frag_src := os.read_file(frag_path) ?

	vert := gl.create_shader(gl.vertex_shader)
	frag := gl.create_shader(gl.fragment_shader)

	compile_single_shader(vert_path, vert_src, vert) ?
	compile_single_shader(frag_path, frag_src, frag) ?

	prog := gl.create_program()
	gl.attach_shader(prog, vert)
	gl.attach_shader(prog, frag)
	gl.link_program(prog)

	single_shader_log('', prog, true) ?

	gl.delete_shader(vert)
	gl.delete_shader(frag)

	return prog
}

fn compile_single_shader(path string, src string, shader u32) ? {
	gl.shader_source(shader, 1, &src.str, voidptr(0))
	gl.compile_shader(shader)

	single_shader_log(path, shader, false) ?
}

fn single_shader_log(path string, shader u32, prog bool) ? {
	mut success := 0
	mut log_l := 0

	if !prog {
		gl.get_shaderiv(shader, gl.compile_status, &mut success)
	} else {
		gl.get_programiv(shader, gl.link_status, &mut success)
	}
	if success == 0 {
		if !prog {
			gl.get_shaderiv(shader, gl.info_log_length, &mut log_l)
		} else {
			gl.get_programiv(shader, gl.info_log_length, &mut log_l)
		}

		mut b := []byte{len: log_l}
		if !prog {
			gl.get_shader_info_log(shader, log_l, voidptr(0), b.data)
		} else {
			gl.get_program_info_log(shader, log_l, voidptr(0), b.data)
		}

		str := b.bytestr()

		if !prog {
			return error('Compiling shader $path failed: $str')
		} else {
			return error('Linking program failed: $str')
		}
	}
}
