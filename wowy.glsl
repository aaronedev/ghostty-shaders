// Uncomment below to move it with the mouse
//#define USE_MOUSE
#define g iMouse
// multiply by -1.0 to invert the direction
#define tm iTime * 0.75


mat3 rotX(float angle) {
  float s = sin(angle);
  float c = cos(angle);

  return mat3(
    1.0, 0.0, 0.0,
    0.0, c, s,
    0.0, -s, c
  );
}

mat3 rotY(float angle) {
  float s = sin(angle);
  float c = cos(angle);

  return mat3(
    c, 0.0, -s,
    0.0, 1.0, 0.0,
    s, 0.0, c
  );
}

mat3 rotZ(float angle) {
  float s = sin(angle);
  float c = cos(angle);

  return mat3(
    c, s, 0.0,
    -s, c, 0.0,
    0.0, 0.0, 1.0
  );
}

mat2 rot(float k)
{
    float c = cos(k);
    float s = sin(k);
    return mat2(c,-s,s,c);
}

vec3 render(vec2 uv, float t)
{
    uv.x *= iResolution.x/iResolution.y;
    #if defined USE_MOUSE
    vec2 m = iMouse.xy/iResolution.xy*2.0-1.0;
    m.x *= iResolution.x/iResolution.y;
    uv+=-m;
    #endif
    uv *= rot(sin(t)*10.0 - cos(t)*5.0);

    uv.x = -abs(uv.x)*2.0;
    uv.y = -abs(uv.y)*2.0;
    vec2 ldot = vec2(1.0/2.0);

    vec2 lst = uv+ldot;

    vec2 st = uv;
    vec3 mat = vec3(0.2 * (1.0+sin(t*2.0))/2.0,0.55 * (sin(cos(t) * 0.5)+1.0)/2.0,0.66 * (sin(t * 0.5)+1.0)/2.0);

    float l = length(lst + vec2(sin(t*10.0 - cos(t * cos(sin(t) * 0.01/length(uv)))*5.0)*0.25));
    vec3 col = mat * smoothstep(0.1*length(lst),l,0.1);

    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
   vec3 col = render(fragCoord/iResolution.xy*2.0-1.0, tm);
   const int lim = 5;
   for(int i=0;i<lim;i++)
   {
       col += render(fragCoord/iResolution.xy*2.0-1.0, tm+float(i)*0.03) * float(lim-i)/float(lim);
   }
   col /= float(lim);

   col = pow(col, vec3(.4545));

   fragColor = vec4(col,1.0);
}
