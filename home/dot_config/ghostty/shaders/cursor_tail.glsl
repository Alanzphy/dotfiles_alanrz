// Cursor Tail shader from https://github.com/sahaj-b/cursor-shaders
// MIT License, Copyright (c) sahaj-b
// This is the repository's Kitty-like fading cursor trail.

vec3 sRGBToLinear(vec3 c) {
    return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(vec3(0.04045), c));
}

vec4 TRAIL_COLOR = vec4(sRGBToLinear(iCurrentCursorColor.rgb), iCurrentCursorColor.a);
const float DURATION = 0.09;
const float MAX_TRAIL_LENGTH = 0.2;
const float THRESHOLD_MIN_DISTANCE = 1.5;
const float BLUR = 2.0;

float ease(float x) {
    return sqrt(1.0 - pow(x - 1.0, 2.0));
}

float sdfRectangle(vec2 p, vec2 center, vec2 halfSize) {
    vec2 d = abs(p - center) - halfSize;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float segment(vec2 p, vec2 a, vec2 b, inout float signValue, float d) {
    vec2 e = b - a;
    vec2 w = p - a;
    vec2 proj = a + e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
    d = min(d, dot(p - proj, p - proj));
    float c0 = step(0.0, p.y - a.y);
    float c1 = 1.0 - step(0.0, p.y - b.y);
    float c2 = 1.0 - step(0.0, e.x * w.y - e.y * w.x);
    float allCond = c0 * c1 * c2;
    float noneCond = (1.0 - c0) * (1.0 - c1) * (1.0 - c2);
    signValue *= mix(1.0, -1.0, step(0.5, allCond + noneCond));
    return d;
}

float sdfParallelogram(vec2 p, vec2 v0, vec2 v1, vec2 v2, vec2 v3) {
    float s = 1.0;
    float d = dot(p - v0, p - v0);
    d = segment(p, v0, v3, s, d);
    d = segment(p, v1, v0, s, d);
    d = segment(p, v2, v1, s, d);
    d = segment(p, v3, v2, s, d);
    return s * sqrt(d);
}

vec2 normalizeCoord(vec2 value, float isPosition) {
    return (value * 2.0 - iResolution.xy * isPosition) / iResolution.y;
}

float antialias(float distanceValue) {
    return 1.0 - smoothstep(0.0, normalizeCoord(vec2(BLUR), 0.0).x, distanceValue);
}

float topRightLeading(vec2 a, vec2 b) {
    float c1 = step(b.x, a.x) * step(a.y, b.y);
    float c2 = step(a.x, b.x) * step(b.y, a.y);
    return 1.0 - max(c1, c2);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    vec2 p = normalizeCoord(fragCoord, 1.0);
    vec4 current = vec4(normalizeCoord(iCurrentCursor.xy, 1.0), normalizeCoord(iCurrentCursor.zw, 0.0));
    vec4 previous = vec4(normalizeCoord(iPreviousCursor.xy, 1.0), normalizeCoord(iPreviousCursor.zw, 0.0));
    vec2 offset = vec2(-0.5, 0.5);
    vec2 currentCenter = current.xy - current.zw * offset;
    vec2 previousCenter = previous.xy - previous.zw * offset;
    vec2 delta = previousCenter - currentCenter;
    float distanceMoved = length(delta);
    float sdfCursor = sdfRectangle(p, currentCenter, current.zw * 0.5);

    if (distanceMoved > current.w * THRESHOLD_MIN_DISTANCE) {
        float progress = clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1.0);
        float tailDelay = MAX_TRAIL_LENGTH / distanceMoved;
        float isLongMove = step(MAX_TRAIL_LENGTH, distanceMoved);
        float headShort = ease(progress);
        float tailShort = ease(smoothstep(tailDelay, 1.0, progress));
        float head = mix(1.0, headShort, isLongMove);
        float tail = mix(ease(progress), tailShort, isLongMove);

        vec2 absDelta = abs(currentCenter - previousCenter);
        float straight = max(step(absDelta.y, 0.001), step(absDelta.x, 0.001));
        float topLeading = topRightLeading(current.xy, previous.xy);
        float bottomLeading = 1.0 - topLeading;
        vec2 headPos = mix(previous.xy, current.xy, head);
        vec2 tailPos = mix(previous.xy, current.xy, tail);
        vec2 v0 = vec2(headPos.x + current.z * topLeading, headPos.y - current.w);
        vec2 v1 = vec2(headPos.x + current.z * bottomLeading, headPos.y);
        vec2 v2 = vec2(tailPos.x + current.z * bottomLeading, tailPos.y);
        vec2 v3 = vec2(tailPos.x + current.z * topLeading, tailPos.y - previous.w);
        float diagonalSdf = sdfParallelogram(p, v0, v1, v2, v3);

        vec2 headCenter = mix(previousCenter, currentCenter, head);
        vec2 tailCenter = mix(previousCenter, currentCenter, tail);
        vec2 minCenter = min(headCenter, tailCenter);
        vec2 maxCenter = max(headCenter, tailCenter);
        vec2 boxSize = maxCenter - minCenter + current.zw;
        float straightSdf = sdfRectangle(p, (minCenter + maxCenter) * 0.5, boxSize * 0.5);
        float trailSdf = mix(diagonalSdf, straightSdf, straight);
        vec4 original = fragColor;
        vec4 trailColor = mix(original, TRAIL_COLOR, antialias(trailSdf));
        fragColor = mix(trailColor, original, step(sdfCursor, 0.0));
    }
}
