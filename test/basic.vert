#version 330 core

in vec2 position;
// // in vec2 texcoord;

// // out vec2 texCoord;

void main() {
    gl_Position = vec4(position, 0.0, 1.0);
}

// layout (location = 0) in vec3 aPos;

// void main()
// {
//     gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
// }