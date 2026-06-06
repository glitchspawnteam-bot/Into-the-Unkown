shader_type canvas_item;

// متغيرات للتحكم من الـ Inspector
uniform float speed : hint_range(0.0, 5.0) = 1.0; // سرعة التمايل
uniform float min_strength : hint_range(0.0, 1.0) = 0.05; // أقل قوة للريح (من الضباب البعيد)
uniform float max_strength : hint_range(0.0, 1.0) = 0.2; // أقصى قوة للريح (عندما يكون الضباب كثيفاً)

void vertex() {
    // السر في حركة العشب:
    // 1. نقيس مدى قمة العشب (كلما ارتفعنا، زادت الحركة)
    // نستخدم UV.y لأن قمة الصورة هي 0 والقاع هو 1
    float strength = mix(min_strength, max_strength, 1.0 - UV.y);

    // 2. نخلق حركة تمايل ناعمة باستخدام Sin
    float time = TIME * speed;

    // 3. نحرك النقاط (Vertices) أفقياً (VERTEX.x)
    VERTEX.x += sin(time + VERTEX.y + VERTEX.x) * strength*100.0;
}