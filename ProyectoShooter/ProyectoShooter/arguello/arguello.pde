int xAim = 50;
int yAim = 50;
boolean digital2 = false;
// Asi se declara una clase. Si quieres varios targets al mismo tiempo tienes que hacer un arreglo de Targets.
Target t1 = new Target(50, 50, 30);

void setup(){
  size(400, 200);
  frameRate(60);
}

void draw(){
  background(200);
  // Si tengo el gatillo presionado, ejecuto disparar.
  if(digital2){
    shoot();
  }
  // Importante: Dibujar el fondo y LUEGO el target, si no no se ve en pantalla.
  // Ahorita no se esta dibujando la mira, pero deberias primero dibujar el target y LUEGO la mira, si no el la mira se va a ver por debajo del target.
  t1.show();
  // AQUI DIBUJAR LA MIRA.
}

class Target{
  // La posicion x, y y el radio de UN TARGET PARTICULARMENTE.
  int x, y, radius;
  Target(int xPos, int yPos, int rad){
    x = xPos;
    y = yPos;
    radius = rad;
  }
  void show(){
    fill(0);
    ellipse(x, y, radius, radius);
  }
}

void shoot(){
  // Comparo si la mira esta dentro del objetivo. Esto se hace restando las posiciones de los centros. 
  // Si AMBAS son menores al radio del objetivo quiere decir que la mira esta dentro.
  if(abs(xAim - t1.x) < t1.radius && abs(yAim - t1.y) < t1.radius){
    // Si estoy dentro del objetivo, cambio su posicion en x y y a un nuevo valor aleatorio.
    // Se hace de t1.radius a width - t1.radius para que siempre este la elipse en la pantalla.
    // ejemplo: si saliera la posicion 0,0, solo se veria un cuarto del circulo, ya que lo demas estaria en valores negativos de la pantalla.
    t1.x = (int) random(t1.radius, width - t1.radius);
    t1.y = (int) random(t1.radius, height - t1.radius);
  }
}