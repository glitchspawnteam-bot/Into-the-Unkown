shader_type canvas_item;

uniform vec4 slime_color : source_color = vec4(0.4, 0.1, 0.6, 0.6);  // تم جعل اللون شفافاً تلقائياً هنا (Alpha = 0.6)
uniform float thickness : hint_range(0.1, 1.0) = 0.8;              // سمك الهلام
uniform float speed : hint_range(1.0, 10.0) = 5.0;                  // سرعة حركة وتمزق السائل

// دالة عشوائية لتوليد تقطيع لزج برمجياً بدون ملفات خارجية
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i + vec2(0.0,0.0)), hash(i + vec2(1.0,0.0)), f.x),
               mix(hash(i + vec2(0.0,1.0)), hash(i + vec2(1.0,1.0)), f.x), f.y);
}

void fragment() {
    vec2 uv = UV;
    
    // 1. صناعة حركية السائل الثقيل الأساسية
    float wave = sin(uv.x * 8.0 - TIME * speed) * 0.1;
    float dist = abs(uv.y - 0.5 + wave);
    
    // 2. استخدام الـ Noise لتكسير وتفتيت الخط إلى قطرات متطايرة لزجة
    vec2 noise_uv = vec2(uv.x * 5.0 - TIME * speed * 0.5, uv.y * 2.0);
    float slime_noise = noise(noise_uv);
    
    // دمج المسافة مع النويز لخلق حواف متآكلة ومتقطعة
    float slime_mask = smoothstep(thickness * 0.5, (thickness * 0.5) - 0.1, dist + slime_noise * 0.25);
    
    // 3. جعل الذيل يتلاشى ويتقطع أكثر في نهايته لتبدو القطرات أحدث
    float tail_fade = smoothstep(0.0, 0.3, uv.x) * (1.0 - uv.x);
    
    // تركيب اللون النهائي مع الشفافية المدمجة والتأثير المتقطع
    vec4 final_color = slime_color;
    final_color.a *= slime_mask * tail_fade * 0.7; // الرقم 0.7 هنا يضمن شفافية التأثير الإجمالية
    
    COLOR = final_color;
}