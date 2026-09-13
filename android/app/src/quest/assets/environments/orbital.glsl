// Shared by the GLES compositor renderer and the WebGL inspection viewer.
// Units are metres. Textures are sRGB and decoded by the sampler; output is
// linear, premultiplied RGBA. A sphere's unlit side remains opaque.
const float ORBIT_PI = 3.141592653589793;
const vec3 ORBIT_SUN = normalize(vec3(-0.30, 0.65, -0.85));
uniform sampler2D surfaceMap;
uniform sampler2D cloudMap;
uniform vec3 bodyCenter;
uniform vec3 geoEast;
uniform vec3 geoNorth;
uniform vec3 geoMeridian;
// radius, central longitude (radians), surface spin, cloud spin
uniform vec4 bodyParameters;
uniform bool earth;

vec3 orbitSrgb(vec3 c) {
    c = max(c, vec3(0.0));
    return mix(c * 12.92, 1.055 * pow(c, vec3(1.0 / 2.4)) - 0.055,
        step(vec3(0.0031308), c));
}

vec4 orbitalRadiance(vec3 eye, vec3 ray) {
    float radius = bodyParameters.x;
    vec3 toCenter = (bodyCenter - eye) / radius;
    float projection = dot(ray, toCenter);
    float impact2 = max(dot(toCenter, toCenter) - projection * projection, 0.0);
    float impact = sqrt(impact2);
    float aa = max(fwidth(impact) * 0.7, 0.00008);
    float coverage = (1.0 - smoothstep(1.0 - aa, 1.0 + aa, impact)) * step(0.0, projection);
    vec3 normal = normalize(ray * (projection - sqrt(max(1.0 - impact2, 0.0))) - toCenter);
    vec2 meridianDirection = vec2(dot(normal, geoEast), dot(normal, geoMeridian));
    float longitude = dot(meridianDirection, meridianDirection) > 0.000000000001
        ? atan(meridianDirection.x, meridianDirection.y) : 0.0;
    vec2 uv = vec2(longitude / (2.0 * ORBIT_PI)
        + 0.5 + bodyParameters.y / (2.0 * ORBIT_PI),
        0.5 - asin(clamp(dot(normal, geoNorth), -1.0, 1.0)) / ORBIT_PI);
    // REPEAT alone is insufficient with mipmaps: derivatives across atan's
    // branch cut must also wrap, or an unrelated coarse mip creates a seam.
    vec2 dx = dFdx(uv), dy = dFdy(uv);
    dx.x -= round(dx.x); dy.x -= round(dy.x);
    vec3 albedo = textureGrad(surfaceMap, uv - vec2(bodyParameters.z / (2.0 * ORBIT_PI), 0.0), dx, dy).rgb;
    float clouds = earth ? textureGrad(cloudMap, uv - vec2(bodyParameters.w / (2.0 * ORBIT_PI), 0.0), dx, dy).r : 0.0;
    float sunlight = max(dot(normal, ORBIT_SUN), 0.0);
    vec3 color;
    if (earth) {
        albedo = albedo * (1.0 - clouds * 0.90) + clouds * vec3(0.80, 0.84, 0.88);
        color = albedo * (0.95 * sunlight + 0.0008);
        float mu = max(dot(normal, -ray), 0.0);
        color += (0.065 + 0.20 * pow(1.0 - mu, 3.0)) * sunlight * vec3(0.065, 0.30, 0.78);
    } else {
        color = albedo * (1.25 * sunlight + 0.002);
    }
    color *= coverage;
    float alpha = coverage;
    if (earth) {
        vec3 tangent = ray * projection - toCenter;
        tangent /= max(length(tangent), 0.000001);
        float height = abs(impact - 1.0);
        float glow = 0.28 * exp(-height / 0.008)
            * (1.0 - smoothstep(0.025, 0.04, height))
            * smoothstep(-0.08, 0.45, dot(tangent, ORBIT_SUN)) * step(0.0, projection);
        color += glow * vec3(0.055, 0.29, 0.90);
        alpha += (1.0 - coverage) * glow;
    }
    return vec4(color, alpha);
}
