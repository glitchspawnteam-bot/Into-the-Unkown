shader_type canvas_item;

uniform vec4 core_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);     // قلب الكرة الأسود
uniform vec4 glow_color : source_color = vec4(0.5, 0.1, 0.8, 1.0);     // توهج الطاقة الأرجواني النيوني
uniform float speed : hint_range(0.5, 10.0) = 5.0;                     // سرعة غليان المادة الظلامية
uniform float glow_intensity : hint_range(0.1, 2.0) = 0.8;             // قوة التوهج الخارجي

float wave(vec2 uv, float t) {
    vec2 p = uv - vec2(0.5);
    float r = length(p);
    float angle = atan(p.y, p.x);
    // تم تعديل التردد هنا ليتناسب مع الحجم الصغير 24×24 دون أن يتشوه
    return sin(r * 30.0 - t * speed + sin(angle * 4.0 + t)) * 0.5 + 0.5;
}

void fragment() {
    vec2 uv = UV;
    float t = TIME;

    float dist = distance(uv, vec2(0.5));
    float energy = wave(uv, t) * wave(uv * 1.2, t * 0.6);

    // ضبط الحواف لتكون حادة وملمومة لأن الحجم صغير جداً
    float border = smoothstep(0.45, 0.15, dist - energy * 0.05 * glow_intensity);
    float core = smoothstep(0.22, 0.20, dist);

    vec4 final_color = mix(glow_color, core_color, core);
    final_color.a *= border;

    COLOR = final_color;
}
