# Friendly OpenGL bindings for V

<!-- ```v
import gl.sys as gl
import glfw // https://github.com/manen/glfw_v

const (
  width  = 854
  height = 480
  verts  = [
    f32(0.5), 0.5, 0.0, // top right
    0.5, -0.5, 0.0, // bottom right
    -0.5, -0.5, 0.0, // bottom left
    -0.5, 0.5, 0.0, // top left
  ]
  inds   = [
    u32(0), 1, 3, // first triangle
    1, 2, 3, // second triangle
  ]
)

fn main() {
  glfw.init_glfw() ?
  glfw.window_hint(glfw.context_version_major, 3)
  glfw.window_hint(glfw.context_version_minor, 3)
  glfw.window_hint(glfw.opengl_profile, glfw.opengl_core_profile)

  win := glfw.create_window(854, 480, 'My First V Window') ?
  win.make_context_current()

  if gl.glew_init() != gl.glew_ok {
    panic('Failed to initialize GLEW')
  }
  gl.viewport(0, 0, 854, 480)

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
}
```

I know this is a big example, but OpenGL is big so I'm not sure what you expected.

If you ever feel like it feel free to finish this example
I won't so I'm just saying -->

One-to-one bindings of C OpenGL functions to friendly V functions.

For an example, look at [`test_app`](test_app)

## Generate

The bindings are automatically generated.

To generate them yourself, run this command:

```v
v run gen/cmd
```

This will generate all the bindings (OpenGL + GLEW) into the sys directory.

## Usage

I would provide a useful example of usage here, but even simple OpenGL apps are several hundred lines. Check out [`test_app`](test_app) if you're interested. (you should probably replace the C GLFW calls in that example with code from my amazing [`glfw_v`](https://github.com/manen/glfw_v) project.)
