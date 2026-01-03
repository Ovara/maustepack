#version 150
#define VERTEX_SHADER

layout(std140) uniform DynamicTransforms {
    mat4 ModelViewMat;
    vec4 ColorModulator;
    vec3 ModelOffset;
    mat4 TextureMat;
};

layout(std140) uniform Projection {
    mat4 ProjMat;
};

struct Transform {
    vec4 color;
    vec3 position;
    mat4 projMat;
} transform;

in vec3 Position;
in vec4 Color;

out vec4 vertexColor;

int toInt(ivec3 v) {
	return v.x << 16 | v.y << 8 | v.z;
}

void main() {
    transform.color = Color;
    transform.position = Position;
    transform.projMat = ProjMat;

    gl_Position = ProjMat * ModelViewMat * vec4(transform.position, 1.0);

    if (transform.position.x <= 2.0) {
        switch (toInt(ivec3(transform.color.rgb*254.5))) {
            case 0xE6AF49:
            case 0x77B3E9:
            case 0xA0A0A0:
            case 0xE84F58:
            case 0xEAC864:
            case 0xCFCFCF:
            case 0x5F5F5F:
                transform.color = vec4(0);
            break;
        }
    }
    vertexColor = transform.color;
}