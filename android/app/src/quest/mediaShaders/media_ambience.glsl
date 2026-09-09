// The ambience surface: a rational tail outside the screen, a polynomial
// shoulder inside, and the image blended back in over the middle. It has to
// stay one continuous surface -- a halo sprite plus a picture quad seams.
#include "media_profile.glsl"

float ambienceBandCoordinate(vec2 p, vec2 halfSize) {
    vec2 v = vec2(p.x * (halfSize.y + 0.0001) / halfSize.x, p.y);
    float ratio = min(abs(v.x), abs(v.y)) / max(max(abs(v.x), abs(v.y)), 0.000001);
    float signedRatio = sign(v.x) * sign(v.y) * ratio * 0.125;
    if (abs(v.y) < abs(v.x)) return (v.x < 0.0 ? 0.125 : 0.625) - signedRatio;
    return (v.y > 0.0 ? 0.375 : 0.875) + signedRatio;
}

vec3 ambienceBand(float coordinate) {
    // The SDK creates sRGB textures, but their alpha channel remains UNorm.
    // Three alpha rows preserve every reference byte and bilinear interpolation
    // without encoding loss or six gamma powers for every headset pixel.
    return vec3(texture(emissive, vec2(coordinate, 1.0 / 6.0)).a,
                texture(emissive, vec2(coordinate, 0.5)).a,
                texture(emissive, vec2(coordinate, 5.0 / 6.0)).a);
}

vec4 mediaAmbience(vec2 localUv, float distanceOverride) {
    vec4 dimensions = g_MaterialUniform.matParams;
    vec4 settings = g_MaterialUniform.emissiveFactor;
    vec2 halfSize = dimensions.xy * 0.5;
    vec2 p = (localUv - 0.5) * dimensions.xy;
    // The band is authored v-up: its colour strip walks the picture
    // anticlockwise from the bottom-left with y up. Our meshes (and the
    // SDK's textures) put v = 0 at the TOP, so p.y grows downwards here. Flip
    // it for the band walk only; the distance field is symmetric. Without this
    // the sky colour of a picture glows below the screen and the ground above.
    vec2 bandPoint = vec2(p.x, -p.y);
    float d = settings.w > 0.5 ? distanceOverride : ambienceDistance(p, halfSize, dimensions.z);
    if (g_MaterialUniform.albedoFactor.w > 0.5) {
        float bandOffset = 0.5 / 32.0 - 0.5 / float(textureSize(emissive, 0).x);
        vec2 lookup = vec2(ambienceBandCoordinate(bandPoint, halfSize) - bandOffset, 0.5 + 0.5 * d / (abs(d) + 0.25));
        return texture(emissive, lookup);
    }
    float intensity = settings.x;
    float immersive = dimensions.w;
    vec3 profile = ambienceProfile(d, intensity, immersive, settings.y);
    float alpha = profile.x;
    float pictureWeight = profile.y;
    float darkening = profile.z;
    vec3 band = ambienceBand(ambienceBandCoordinate(bandPoint, halfSize));
    float brightness = 1.0 - 1.0 / (1.0 + 2.0 * min(band.r, band.g) + band.r + band.g);
    band *= 1.0 - brightness * darkening;
    vec2 pictureUv = clamp(localUv, vec2(0.0), vec2(1.0));
    vec4 stereo = g_MaterialUniform.stereoParams;
    float eye = float(getStereoPassId());
    // SBS disparity is corrected against the physical 65 mm eye separation.
    if (g_MaterialUniform.albedoFactor.z > 0.5)
        pictureUv.x = clamp(pictureUv.x + (1.0 - 2.0 * eye) * 0.0325 / (dimensions.z * dimensions.x), 0.0, 1.0);
    vec2 sampleUv = pictureUv * stereo.zw + eye * stereo.xy;
    // Do not return early for halo pixels before these derivatives: divergent
    // derivatives changed boundary pixels in the reference comparison on Quest.
    vec2 footprint = (abs(dFdx(sampleUv)) + abs(dFdy(sampleUv))) * 0.25;
    vec4 picture = 0.5 * (texture(albedoSampler, sampleUv - footprint) + texture(albedoSampler, sampleUv + footprint));
    float sourceAlpha = settings.z > 0.5 ? picture.a : 1.0;
    // Compose images are already premultiplied. Preserve PNG holes and crossfades.
    return vec4(alpha * mix(band, picture.rgb, pictureWeight), alpha * mix(1.0, sourceAlpha, pictureWeight));
}
