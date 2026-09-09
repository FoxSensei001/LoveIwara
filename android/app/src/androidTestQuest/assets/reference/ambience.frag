#version 310 es
// Reference formulation of the ambience surface, written straight from the
// equations so the shipping scene shader has something independent to be
// compared against on the GPU.
//
// One continuous surface, in four parts: a signed distance to the rounded
// screen rectangle, a rational tail outside it, a polynomial shoulder inside,
// and the picture itself blended back in over the middle. Splitting it into a
// halo sprite plus a picture quad does not reproduce it -- the alpha profile
// has to stay continuous across the screen edge.
precision highp float;
precision highp int;
precision highp sampler2D;

struct ScreenParams {
    int eye;            // 0 = left, 1 = right
    float halfWidth;    // half the screen, in local units
    float halfHeight;
    float parentScale;
    float disparity;    // per-eye horizontal shift, in picture uv
    float intensity;    // the ambience slider, 0..1
    float immersive;    // 0..1 between the two endpoints
};
uniform ScreenParams screen;

uniform sampler2D band;     // the smoothed border colours, one pixel tall
uniform sampler2D picture;  // the side-by-side source

layout(location = 0) in vec2 uv;
layout(location = 0) out vec4 color;

const float BORDER = 0.08;     // corner radius of the rounded screen rect
const float GLOW_SIZE = 60.0;  // the glow quad spans 60 local units

// Two taps a quarter of a pixel either side of the sample. The picture is only
// ever read through this, so the halo and the screen agree at grazing angles.
vec3 footprintAverage(vec2 p) {
    vec2 width = abs(dFdx(p)) + abs(dFdy(p));
    return texture(picture, p - width * 0.25).rgb * 0.5
         + texture(picture, p + width * 0.25).rgb * 0.5;
}

void main() {
    vec2 centred = uv - 0.5;
    vec2 plane = centred * GLOW_SIZE;

    // Signed distance to the rounded screen rectangle. The x term also carries
    // the eye offset, so both eyes keep the same border thickness.
    vec2 edge = vec2(abs(plane.x) + 0.0325 / screen.parentScale - (screen.halfWidth - BORDER),
                     abs(plane.y) - (screen.halfHeight - BORDER));
    float outside = length(max(edge, vec2(0.0))) - BORDER;
    float diagonal = edge.x - edge.y;
    float inside = abs(diagonal) < BORDER
        ? 0.5 * (edge.x + edge.y - sqrt(2.0 * BORDER * BORDER - diagonal * diagonal))
        : -min(abs(edge.x - BORDER), abs(edge.y - BORDER));
    float signedDistance = outside > 0.0 ? outside : inside;

    // The alpha profile. Outside the screen it is a rational tail; inside, a
    // parabolic shoulder that meets the tail with a matching gradient.
    float endpoint = 1.0 - screen.immersive;
    float shift = (1.0 - 0.6 * endpoint) * screen.intensity;
    float slope = (3.5 * endpoint - 14.5) * screen.intensity + 16.0;
    float reach = 0.4 - 0.1 * screen.intensity;
    float softness = 0.084 + 0.116 * screen.intensity;
    float knee = -2.0 * reach / slope / (1.0 - reach);
    float x = knee * shift + signedDistance;

    float tail = (1.0 - reach) / (slope * x + 1.0);
    float shoulderTerm = x * slope * (1.0 - reach) + 2.0 * reach;
    float shoulder = 1.0 - shoulderTerm * shoulderTerm / (4.0 * reach);
    float alpha = x > 0.0 ? tail : (x < knee ? 1.0 : shoulder);

    // How much the screen itself dims the glow crossing it. The subtraction is
    // asymmetric on purpose: replacing it with a plain lerp loses the
    // relationship between room brightness and screen brightness.
    float inset = signedDistance - 0.042857144;  // 3 / 70
    float falloff;
    if (inset > 0.0) {
        falloff = 0.7 / (10.0 * inset + 1.0);
    } else if (inset < -0.085714288) {           // 6 / 70
        falloff = 1.0;
    } else {
        float ramp = 7.0 * inset + 0.6;
        falloff = 1.0 - 0.83333331 * ramp * ramp;
    }
    float shade = 1.0 - (screen.intensity * falloff + (1.0 - screen.intensity) * alpha);
    shade = shade * 0.6 + 0.4;

    // Which texel of the border band this point belongs to. The band runs once
    // around the screen, an eighth of it per half edge.
    float aspect = screen.halfWidth / (screen.halfHeight + 0.0001);
    vec2 v = vec2(plane.x / aspect, plane.y);
    float ratio = min(abs(v.x), abs(v.y)) / max(max(abs(v.x), abs(v.y)), 0.000001);
    float signedRatio = sign(centred.y) * sign(v.x) * ratio * 0.125;
    float bandCoord = abs(v.y) < abs(v.x)
        ? (v.x < 0.0 ? 0.125 : 0.625) - signedRatio
        : (centred.y > 0.0 ? 0.375 : 0.875) + signedRatio;

    vec3 tint = texture(band, vec2(bandCoord, 0.5)).rgb;
    // A saturated band should not also read as bright. Weighting by red and
    // green keeps blue rooms from washing out.
    float pull = 1.0 - 1.0 / (1.0 + tint.r + tint.g + 2.0 * min(tint.r, tint.g));
    vec3 glow = (1.0 - pull * shade) * tint;

    // Hand the middle back to the picture. The quartic keeps the handover free
    // of a visible seam where the glow stops.
    float s = 1.0 - clamp(-signedDistance / softness, 0.0, 1.0);
    float fade = 4.0 * s * s * s - 3.0 * s * s * s * s;
    glow *= fade;

    vec2 pictureUv = clamp(vec2(plane.x / screen.halfWidth, plane.y / screen.halfHeight) * 0.5,
                           vec2(-0.5), vec2(0.5)) + 0.5;
    vec3 right = footprintAverage(vec2(clamp(pictureUv.x * 0.5 + 0.5 - screen.disparity * 0.25, 0.5, 1.0), pictureUv.y));
    vec3 left  = footprintAverage(vec2(clamp(pictureUv.x * 0.5 + screen.disparity * 0.25, 0.0, 0.5), pictureUv.y));
    vec3 image = mix(left, right, float(screen.eye));

    color = vec4((glow + (1.0 - fade) * image) * alpha, alpha);
}
