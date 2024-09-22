#version 330 core

in vec2 UV;

out vec4 FragColor;

const float UnitSquareTimesTen = 1.0f / 30.0f; // world is 300, so var name makes sense

void main() {
    int x = int(UV.x / UnitSquareTimesTen);
    int y = int(UV.y / UnitSquareTimesTen);

    int Black = (x + y) & 1;

    FragColor = vec4(vec3(Black), 1.0);
}
