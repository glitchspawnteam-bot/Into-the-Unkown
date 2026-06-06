shader_type canvas_item;

// مقابض تحكم ستظهر لك في الـ Inspector
uniform sampler2D noise_img : repeat_enable; // نسيج الضوضاء
uniform float speed : hint_range(0.0, 0.5) = 0.5; // سرعة الرياح
uniform float noise_scale : hint_range(0.1, 5.0) = 2.0; // حجم الغيوم (Scale)
uniform float alpha_intensity : hint_range(0.0, 1.0) = 0.1; // قوة الشفافية

void fragment() {
    // التحكم في الحجم والسرعة
    vec2 uv = UV * noise_scale;
    uv.x += TIME * speed;

    float noise_value = texture(noise_img, uv).r;

    // اللون رمادي غامق مثل "عبود برو"
    COLOR = vec4(vec3(0.5), noise_value * alpha_intensity*3.0);
}