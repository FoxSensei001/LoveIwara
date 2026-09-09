#ifndef MEDIA_PROFILE_GLSL
#define MEDIA_PROFILE_GLSL
float ambienceDistance(vec2 p, vec2 halfSize, float parentScale) {
    vec2 q = abs(p) + vec2(0.0325 / parentScale, 0.0) - (halfSize - 0.08);
    float difference = q.x - q.y;
    float inner = abs(difference) < 0.08
        ? 0.5 * (q.x + q.y - sqrt(max(0.0128 - difference * difference, 0.0)))
        : -min(abs(q.x - 0.08), abs(q.y - 0.08));
    float outer = length(max(q, vec2(0.0))) - 0.08;
    return outer > 0.0 ? outer : inner;
}

// Alpha envelope, image weight, and colour darkening. Shared by the native
// video-layer preprocessor and the scene shader so their boundary cannot drift.
vec3 ambienceProfile(float d, float intensity, float immersive, float feather) {
    float rate = 16.0 - intensity * (11.0 + 3.5 * immersive);
    float shoulder = 0.4 - 0.1 * intensity;
    float knee = -2.0 * shoulder / (rate * (1.0 - shoulder));
    float shifted = d + knee * (0.4 + 0.6 * immersive) * intensity;
    float alpha;
    if (shifted < knee) alpha = 1.0;
    else if (shifted > 0.0) alpha = (1.0 - shoulder) / (1.0 + rate * shifted);
    else {
        float t = shifted * rate * (1.0 - shoulder) + 2.0 * shoulder;
        alpha = 1.0 - t * t / (4.0 * shoulder);
    }
    float edgeWidth = (0.084 + 0.116 * intensity) * feather;
    float edge = edgeWidth > 0.000001 ? 1.0 - clamp(-d / edgeWidth, 0.0, 1.0) : step(0.0, d);
    float imageWeight = 1.0 - (4.0 * edge * edge * edge - 3.0 * edge * edge * edge * edge);
    float colourDistance = d - 0.042857144;
    float colourEnvelope;
    if (colourDistance < -0.085714288) colourEnvelope = 1.0;
    else if (colourDistance > 0.0) colourEnvelope = 0.7 / (1.0 + 10.0 * colourDistance);
    else {
        float t = 7.0 * colourDistance + 0.6;
        colourEnvelope = 1.0 - t * t * 0.833333313;
    }
    return vec3(alpha, imageWeight, (1.0 - mix(alpha, colourEnvelope, intensity)) * 0.6 + 0.4);
}

float ambiencePictureAlpha(vec3 profile) {
    float haloAlpha = profile.x * (1.0 - profile.y);
    return profile.x * profile.y / max(1.0 - haloAlpha, 0.000001);
}
#endif
