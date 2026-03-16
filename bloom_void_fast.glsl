// --- Void Bloom (Fast/Optimized) ---
// 
// PERFORMANCE NOTE:
// This shader was modified to reduce GPU overhead on high-DPI (Retina) 120Hz displays.
// The original version used 24 texture samples per pixel, which caused visible 
// latency (1-2 seconds) during rapid scrolling or TUI redraws.
// 
// CHANGES:
// - Reduced convolution samples from 24 to 12.
// - This significantly improves frame times while maintaining the "bloom" aesthetic.

const float BLOOM_THRESHOLD = 0.30; 
const float BLOOM_KNEE      = 0.12;
const float BLOOM_INTENSITY = 0.06; 
const float BLOOM_RADIUS    = 1.2;  

// Reduced to 12 samples for better performance on high-DPI/120Hz displays
const vec3 samples[12] = vec3[12](
  vec3(0.1693761725038636,  0.9855514761735895,  1.0),
  vec3(-1.333070830962943,   0.4721463328627773,  0.7071067811865475),
  vec3(-0.8464394909806497, -1.51113870578065,    0.5773502691896258),
  vec3( 1.554155680728463,  -1.2588090085709776,  0.5),
  vec3( 1.681364377589461,   1.4741145918052656,  0.4472135954999579),
  vec3(-1.2795157692199817,  2.088741103228784,   0.4082482904638631),
  vec3(-2.4575847530631187, -0.9799373355024756,  0.3779644730092272),
  vec3( 0.5874641440200847, -2.7667464429345077,  0.35355339059327373),
  vec3( 2.997715703369726,   0.11704939884745152, 0.3333333333333333),
  vec3( 0.41360842451688395, 3.1351121305574803,  0.31622776601683794),
  vec3(-3.167149933769243,   0.9844599011770256,  0.30151134457776363),
  vec3(-1.5736713846521535, -3.0860263079123245,  0.2886751345948129)
);

float lum(vec4 c) { return 0.299*c.r + 0.587*c.g + 0.114*c.b; }

float softThreshold(float l) {
  return smoothstep(BLOOM_THRESHOLD - BLOOM_KNEE, BLOOM_THRESHOLD + BLOOM_KNEE, l);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = fragCoord.xy / iResolution.xy;
  vec4 base = texture(iChannel0, uv);
  vec2 stepPx = (BLOOM_RADIUS / iResolution.xy);
  vec4 bloomSum = vec4(0.0);
  float wSum = 0.0;

  for (int i = 0; i < 12; i++) {
    vec3 s = samples[i];
    vec4 c = texture(iChannel0, uv + s.xy * stepPx);
    float l = lum(c);
    float t = softThreshold(l);
    float w = t * s.z;
    bloomSum += c * w;
    wSum     += w;
  }

  vec4 bloom = bloomSum / max(wSum, 1e-5);
  vec3 rgb = base.rgb + bloom.rgb * BLOOM_INTENSITY;
  fragColor = vec4(clamp(rgb, 0.0, 1.0), base.a);
}
