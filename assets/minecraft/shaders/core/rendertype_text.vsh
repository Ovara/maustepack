#version 330

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>
#moj_import <minecraft:globals.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler2;

out float sphericalVertexDistance;
out float cylindricalVertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;


// Effect modes:
// 0 - No effect
// 1 - Rainbow
//      Activates when the two lowest bits are
//      R   G   B
//      01  00  10
//      Hex example: (#FDFCFE)
// 2 - Wave
//      Activates when the two lowest bits are
//      R   G   B
//      10  00  10
//      Hex example: (#FEFCFE)


int getEffectMode(vec4 col) {
    int r = int(col.r * 255.0 + 0.5);
    int g = int(col.g * 255.0 + 0.5);
    int b = int(col.b * 255.0 + 0.5);

    if (b % 4 == 2) {
        return (r % 4) + ((g % 4) * 4);
    }
    return 0;
}

vec3 hsvToRgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
    vec3 pos = Position;
    vec4 col = Color;

    bool isShadow = col.r < 0.23 && col.g < 0.23 && col.b < 0.23;

    int mode = getEffectMode(col);

    if (mode > 0) {
        if (mode == 1) {
            float hue = 0.005 * (pos.x + pos.y) - GameTime * 300.0;
            col.rgb = hsvToRgb(vec3(hue, 0.7, 1.0));
        }
        else if (mode == 2) {
            pos.y += sin(GameTime * 1500.0 + (pos.x * 0.1)) * 2.5;
        }
        else if (mode == 3) {
            float pulse = sin(GameTime * 800.0 * 6.28318) * 0.5 + 0.5;
            col.rgb = mix(col.rgb, vec3(1.0, 1.0, 1.0), pulse);
        }

        if (isShadow) col.rgb *= 0.25;
    }

    sphericalVertexDistance = fog_spherical_distance(pos);
    cylindricalVertexDistance = fog_cylindrical_distance(pos);
    vertexColor = col;
    texCoord0 = UV0;
    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);
}