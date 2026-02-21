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
// 3 - Pulse
//      Activates when the two lowest bits are
//      R   G   B
//      11  00  10
//      Hex example: (#FFFCFE)
// 4 - Shine
//      Activates when the two lowest bits are
//      R   G   B
//      00  01  10
//      Hex example: (#FCFDFE)

int getEffectMode(vec4 col) {
    int r = int(col.r * 255.0 + 0.5);
    int g = int(col.g * 255.0 + 0.5);
    int b = int(col.b * 255.0 + 0.5);

    if (b % 4 == 2) {
        return (r % 4) + ((g % 4) * 4);
    }
    return 0;
}

float normalizedGameTime() {
    return GameTime * 1200;
}

vec3 hsvToRgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void applyRainbow(inout vec3 pos, inout vec4 col) {
    float hue = 0.005 * (pos.x + pos.y) - normalizedGameTime();
    col.rgb = hsvToRgb(vec3(hue, 0.7, 1.0));
}

void applyWave(inout vec3 pos, inout vec4 col) {
    float wavePeriodMultiplier = 0.1;
    float waveHeight = 2;
    pos.y += sin(normalizedGameTime() + (pos.x * wavePeriodMultiplier)) * waveHeight;
}

void applyPulse(inout vec3 pos, inout vec4 col) {
    float pulse = sin(normalizedGameTime()) * 0.5 + 0.5;
    col.rgb = mix(col.rgb, vec3(1.0, 1.0, 1.0), pulse);
}

void applyShine(inout vec3 pos, inout vec4 col) {
    float speed = 2.5;
    float wavePeriodMultiplier = 0.05;
    float squish = 10;
    float f = sin(normalizedGameTime() * speed + (pos.x * wavePeriodMultiplier)) * squish + (1.0 - squish);
    float shine = smoothstep(0.0, 1.0, f);
    vec3 lowlight = col.rgb * 1.0;
    vec3 highlight = col.rgb + vec3(1.0) * 0.5;
    col.rgb = mix(lowlight, highlight, shine);
}

void applyEffects(inout int effectMode, inout vec3 pos, inout vec4 col) {
    bool isShadow = col.r < 0.23 && col.g < 0.23 && col.b < 0.23;
    // Rainbow
    if (effectMode == 1) {
        applyRainbow(pos, col);
    }
    // Wave
    else if (effectMode == 2) {
        applyWave(pos, col);
    }
    // Pulse
    else if (effectMode == 3) {
        applyPulse(pos, col);
    } 
    // Shine
    else if (effectMode == 4) {
        applyShine(pos, col);
    }

    if (isShadow) col.rgb *= 0.25;
}

void main() {
    vec3 pos = Position;
    vec4 col = Color;

    int effectMode = getEffectMode(col);

    if (effectMode > 0) {
        applyEffects(effectMode, pos, col);
    }

    sphericalVertexDistance = fog_spherical_distance(pos);
    cylindricalVertexDistance = fog_cylindrical_distance(pos);
    vertexColor = col;
    texCoord0 = UV0;
    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);
}