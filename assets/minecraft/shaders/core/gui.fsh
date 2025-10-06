#version 330

// Can't moj_import in things used during startup, when resource packs don't exist.
// This is a copy of dynamicimports.glsl
layout(std140) uniform DynamicTransforms {
    mat4 ModelViewMat;
    vec4 ColorModulator;
    vec3 ModelOffset;
    mat4 TextureMat;
    float LineWidth;
};

const float TOLERANCE = 0.01;

const vec3 SERVER_MESSAGE_BAR_COLOR = vec3(0.8157, 0.8157, 0.8157);

const vec3 MODIFIED_MESSAGE_BAR_COLOR = vec3(0.3765, 0.3765, 0.3765);

in vec3 Position;
in vec4 vertexColor;

out vec4 fragColor;

bool isTargetColor(vec4 currentColor, vec3 targetColor) {
    return distance(currentColor.rgb, targetColor) < TOLERANCE;
}

void main() {
    vec4 color = vertexColor;
    if (color.a == 0.0) {
        discard;
    }

    if (Position.x <= 2.0) {
        bool matchColor1 = isTargetColor(color, SERVER_MESSAGE_BAR_COLOR);
        bool matchColor2 = isTargetColor(color, MODIFIED_MESSAGE_BAR_COLOR);

        if (matchColor1 || matchColor2) {
            discard; 
        }
    }

    fragColor = color * ColorModulator;
}
