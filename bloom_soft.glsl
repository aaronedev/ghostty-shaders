// --- knobs ---
const float BLOOM_THRESHOLD = 0.35; // higher = less bloom
const float BLOOM_KNEE      = 0.10; // softness around threshold
const float BLOOM_INTENSITY = 0.08; // overall strength
const float BLOOM_RADIUS    = 1.00; // sample spread (1.414 = wider)

float lum(vec4 c) { return 0.299*c.r + 0.587*c.g + 0.114*c.b; }

// Soft threshold (classic bloom trick)
float softThreshold(float l) {
  // smoothstep over [threshold-knee, threshold+knee]
  return smoothstep(BLOOM_THRESHOLD - BLOOM_KNEE, BLOOM_THRESHOLD + BLOOM_KNEE, l);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = fragCoord.xy / iResolution.xy;
  vec4 base = texture(iChannel0, uv);

  vec2 stepPx = vec2(BLOOM_RADIUS) / iResolution.xy;

  vec4 bloomSum = vec4(0.0);
  float wSum = 0.0;

  for (int i = 0; i < 24; i++) {
    vec3 s = samples[i];
    vec4 c = texture(iChannel0, uv + s.xy * stepPx);

    float l = lum(c);
    float t = softThreshold(l);      // 0..1 gate
    float w = t * s.z;

    bloomSum += c * w;
    wSum     += w;
  }

  vec4 bloom = (wSum > 0.0) ? (bloomSum / wSum) : vec4(0.0);

  vec4 outc = base + bloom * BLOOM_INTENSITY;
  outc.rgb = clamp(outc.rgb, 0.0, 1.0); // optional, but keeps it from blasting
  fragColor = outc;
}

