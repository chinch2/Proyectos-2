import processing.serial.*; 
 
Serial myPort;                 // The serial port
byte[] inBuffer= new byte[5];  // Input Byte from serial port
int buffersize=1;
int i = 0;
int val1;                      // Usado para la lectura de datos del ADC1
int val2;                      // Usado para la lectura de datos del ADC2
int txtSamples = 2048;           // Numero de valores máximo del archivo de texto
long runTime;
boolean dig1;                  // Sensor digital 1
boolean dig2;                  // Sensor digital 2
boolean dig3;                  // Sensor digital 3
boolean dig4;                  // Sensor digital 4
boolean sync = false;          // Indica si la comunicacion serial esta sincronizada
boolean ADC1=false;            // Indica si hay datos por recibir del canal de adquisición 1
boolean ADC2=false;            // Indica si hay datos por recibir del canal de adquisición 2
String[] txtBuffer1 = new String[txtSamples];
String[] txtBuffer2 = new String[txtSamples];
float xl;
float yl;
float xp=0;
float xp1;
float yp=0;
float yp1;
int aux1;
int aux2;
int j=0;
int acierto1=0;
int acierto2=0;
int acierto3=0;
int HP=5;
int SP=5;
int vida=2;
int escudo=2;
int gameOver = 0; // 0 estas jugando. 1 perdiste. 2 ganaste.
// Variables de ploteo

int ls = 0;
int numScale = 10;
float sampleTime=500; // 213.623 us
float sampleVolt = 0.732421875; // 3000/4096 mV
PFont font;
int xSet=4;
int ySet=3;
int[] xScale={100, 500, 1000, 5000, 10000, 50000, 100000,500000}; // us
int[] yScale={50, 100, 200, 300, 500, 1000, 3000};      // Escala en mV
int xSamples, ySamples;  // Numero de puntos a graficar
float xLabel, yLabel;    // Longitud de los ejes
float xLength, yLength;  // Espacio entre puntos
int OscCount1=0;
int OscCount2=0;          // Contador de barrido
int preVar1=0;
int preVar2=0;
boolean clear=false;   // true cada vez que se llena el osciloscopio o se cambia la escala
boolean stop=false;    // se cambia con ENTER
boolean dataOK=false;
IntList val1Buffer = new IntList();
IntList val2Buffer = new IntList(); 
Target t1 = new Target(300, 300, 30, 10500, 1);
Target t2 = new Target(400, 300, 40, 30000, 2);
Target t3 = new Target(500, 300, 50,20000, 3);
Bottle b1 = new Bottle(300, 100, 40, 40, 1);
Bottle b2 = new Bottle(100, 100, 40, 40, 2);
void setup(){
  printArray(Serial.list()); 
  myPort = new Serial(this, Serial.list()[0], 115200); 
  myPort.buffer(buffersize);
  frameRate(800);
 
  // Ploteo
  size(800,500);
  background(0);
  xLabel = width - 4*ls;
  yLabel = height - 4*ls;
  font = createFont("Arial", ls);
  //textFont(font);
  drawGrid();
} 

void draw() {
  if(gameOver == 0){
  if(!stop){
    if(clear){
      drawGrid();
      val1Buffer.clear();
      val2Buffer.clear();
      OscCount1 = 0;
      OscCount2 = 0;
      clear=false;
    }
    if(val1Buffer.size() != 0){
      println("eje x: "+val1Buffer.get(0));
      val1Buffer.remove(0);
    }
      
    if(val2Buffer.size() != 0){
      println("eje y: "+val2Buffer.get(0));
      val2Buffer.remove(0);
    }
    if (val1Buffer.size() != 0 && val2Buffer.size() != 0) {
        j++;
        aux1=val1Buffer.get(0);
        aux2=val2Buffer.get(0);
        xp = xp + aux1;
        yp = yp + aux2;
        val1Buffer.remove(0);
        val2Buffer.remove(0);
      if (j == 25){
      xp1 = xp/25;
      yp1 = yp/25;
      xl = map(xp1, 490, 2160, 0, width);//770 2300
      yl = map(yp1, 879, 2490, height, 0);
      drawGrid();
      healthBar();
      if(SP>0){
      shieldBar();
      }
      val1Buffer.clear();
      val2Buffer.clear();
      OscCount1 = 0;
      OscCount2 = 0;
      if(acierto1 < 3){
      t1.show();
      }
      if(acierto2 < 3){
      t2.show();
      }
      if(acierto3 < 3){
      t3.show();
      }
      if(vida > 0){
        b1.show();
      }
      if(escudo > 0){
        b2.show();
      }
      if(acierto1 >= 3 && acierto2 >= 3 && acierto3 >= 3){
        gameOver = 2;
      }
      drawAim(xl,yl);
      if(dig2 == true && SP>0){
          shield();
      }
      xp=0;
      yp=0;
      j=0;
      }
      
    }
    
  }
   // Si tengo el gatillo presionado, ejecuto disparar.
  if(dig1==false){
    shoot();
  }
 }
 else if(gameOver == 1){
   background(255, 0, 0);
   text("YOU LOSE.", 400, 250);
 }
 else if (gameOver == 2){
   background(0, 255, 0);
   text("YOU WIN.", 400, 250);
 }
 
}
 
void serialEvent(Serial myPort) { 
  // Inicia conteo de tiempo de corrida
  //println("SERIAL STAR");
  // runTime = System.nanoTime();
  
  // Lectura del buffer de entrada
  myPort.readBytes(inBuffer);
  if (inBuffer != null) {
    //println("BUFFER: ");
    printArray(inBuffer);
  }
  else{
    printArray("BUFFER VACIO");
  }
  
  // Verifica si en buffer está sincronizado
  syncronize();  
  
  if(sync && inBuffer[0] >= 0){  
  // Inicia decodificación del protocolo para la señal del eje 1 (ADC1)
    if(ADC1){
      decodeADC1();
      val1Buffer.append(val1);
      println("dig1: "+dig1);
      println("dig2: "+dig2);
      ADC1=false;
    }
    
  // Inicia decodificación del protocolo para la señal del eje 2 (ADC2)
    if(ADC2){
      decodeADC2();
      val2Buffer.append(val2);
      println("dig3: "+dig3);
      println("dig4: "+dig4);
      ADC2=false;
    }
  
  // Guardado de las variables en archivos de texto para visualización
  //  storeOnTxt();
  }
  
  if(sync){  
    nextHeaderRead();
  }
  
  myPort.buffer(buffersize);
  
  // Verifica si el procesamiento se está haciendo respetando el tiempo de muestreo
  //runTime = System.nanoTime() - runTime;
  //if(runTime > (sampleTime*1000)){
  //  println("ERROR: "+ int(runTime/(sampleTime * 1000)) +" muestras perdidas.");
  //}

  //println("SERIAL END: "+ runTime);
}


  //
  // Función que cambia la bandera sync cuando encuetra el encabezado del siguiente bloque
void syncronize(){
  if(!sync){
    if(inBuffer[0] < 0){
      sync=true;
    }
  }
}

  //
  // Funcion que decodifica los bytes asignados al ADC1 en el protocolo y guarda el valor en va1
void decodeADC1(){
  // Lectura del sensor digital 1
  val1=inBuffer[0] & 0x40;            
  if(val1==64){
    dig1=true;
  }
  if(val1==0){
    dig1=false;
  }
  
  // Lectura del sensor digital 2
  val1=inBuffer[0] & 0x20;
  if(val1==32){
    dig2=true;
  }
  if(val1==0){
    dig2=false;
  }
  
  // Lectura del sensor analógico 1
  val1 = (((inBuffer[0] & 0x1F) << 7) + inBuffer[1]);
}

  //
  // Funcion que decodifica los bytes asignados al ADC2 en el protocolo y guarda el valor en val2
void decodeADC2(){
  // Lectura del sensor digital 3
  val2=inBuffer[2] & 0x40;            
  if(val2==64){
    dig3=true;
  }
  if(val2==0){
    dig3=false;
  }
  
  // Lectura del sensor digital 4
  val2=inBuffer[2] & 0x20;
  if(val2==32){
    dig4=true;
  }
  if(val2==0){
    dig4=false;
  }
  
  // Lectura del sensor analógico 2
  val2 = (((inBuffer[2] & 0x1F) << 7) + inBuffer[3]);
  //ADC2=false;
}

  //
  // Guardado de txtSample muestras en archivos de texto, uno para la señal del eje x y otro para la del eje y
void storeOnTxt(){
  if(i<txtSamples){
    txtBuffer1[i]=str(val1);
    txtBuffer2[i]=str(val2);
    i++;
  }
  else{
    saveStrings("ejex.txt", txtBuffer1);
    saveStrings("ejey.txt", txtBuffer2);
    txtBuffer1 = new String[txtSamples];
    txtBuffer2 = new String[txtSamples];
    i=0;
    myPort.stop();
  } 
}

  //
  // Función que asigna el tamaño del buffer, bufferSize, de acuerdo al encabezado del siguiente bloque
void nextHeaderRead(){
  switch(inBuffer[buffersize-1]){
    //case -15:
      //buffersize=3;
      //ADC1=true;
      //break;
    case -14:
      buffersize=5;
      ADC1=true;
      ADC2=true;
      break;
    default:
      println("ERROR: CABECERA DESINCRONIZADA");
      sync=false;
      buffersize=1;
      break;
    }
}
  //
  // Ploteo
void drawGrid(){
  background(0);
  for(int i=0;i<numScale;i++){
    stroke(200);
    line(2*ls,height - 2*ls -(i+1)*(yLabel/numScale),2*ls + xLabel,height - 2*ls -(i+1)*(yLabel/numScale));  // Linea vertical
    line(2*ls + (i+1)*(xLabel/numScale),height - 2*ls ,2*ls + (i+1)*(xLabel/numScale),2*ls);  // Linea horizontal
    ls++;
  }
  stroke(255);
  line(2*ls, 2*ls, 2*ls, height -2*ls); // xlabel
  line(2*ls, height- 2*ls, width - 2*ls, height- 2*ls); // ylabel
  fill(100);
  //text("Escala X: "+ xScale[xSet] + "us", 2*ls, height -ls);
  //text("Escala Y: "+ yScale[ySet] + "mV", 3*ls + textWidth("Escala X: "+ xScale[xSet] + "us") , height -ls);
  
  xSamples = int(numScale*xScale[xSet]/sampleTime);
  xLength = xLabel/xSamples;
  ySamples= int(numScale*yScale[ySet]/sampleVolt);
  yLength= yLabel/ySamples;
}
void drawAim(float x, float y){
  fill(255);
  if(dig1 == false){
    fill(255,255,0);
  }
  if(dig2){
    fill(255,0,255);
  }
    
  
  ellipse(x, y, 20, 20);
}

class Target{
  int x, y, radius, attackInterval, targetColor;
  int preAttackInterval = 1000;
  int attackCounter = 0;
  Target(int xPos, int yPos, int rad, int interval, int tColor){
    x = xPos;
    y = yPos;
    radius = rad;
    attackInterval = interval;
    targetColor = tColor;
  }
  
  void show(){
    if(preAttackCheck() == true){ // Si estamos en el momento previo al ataque (cambio de color).
      fill(255, 0, 0);
    }
    else if (attackCheck() == true){ // Si estamos en el momento del ataque.
      fill(0);
      attack();
    }
    else{
      if(targetColor == 1){
        fill(255, 255, 0);
      }
      else if (targetColor == 2){
        fill(255, 0, 255);
      }
      else{
        fill(255);
      }
    }
    ellipse(x, y, radius, radius);
  }
  
  boolean preAttackCheck(){ // Vemos si estamos 30% antes del tiempo de intervalo para alertar al usuario que viene el ataque cambiando el color del objeto.
    if(millis() >= (((attackCounter + 1) * attackInterval) - preAttackInterval) && millis() < ((attackCounter + 1) * attackInterval)){
      return true;
    }
    return false;
  }
  
  boolean attackCheck(){ // Vemos si estamos en el tiempo de intervalo para atacar.
    if(millis() >= (attackCounter + 1) * attackInterval){
      attackCounter++;
      return true;
    }
    return false;
  }
  
  void attack(){ // Funcion de atacar de cada objetivo, si el digital 2 esta apagado en este momento, perdemos.
    if(dig2 == true && SP>0){
      SP--;
    }
    else {
      HP--;
    }
    if(HP==0){
      gameOver = 1;
    }
    
  }
}
class Bottle{
  int x, y, ancho, largo, bottleColor;
  Bottle(int xPos, int yPos, int anch, int larg, int bColor){
    x = xPos;
    y = yPos;
    ancho = anch;
    largo= larg;
    bottleColor = bColor;
  }
  
  void show(){
      if(bottleColor == 1){
        fill(0, 255, 0);
      }
      else if (bottleColor == 2){
        fill(255, 255, 255,50);
      }
    rect(x, y, ancho, largo);
  }
}

void shoot(){
  // Comparo si la mira esta dentro del objetivo. Esto se hace restando las posiciones de los centros. 
  // Si AMBAS son menores al radio del objetivo quiere decir que la mira esta dentro.
  if(abs(xl - t1.x) < t1.radius && abs(yl - t1.y) < t1.radius){
    // Si estoy dentro del objetivo, cambio su posicion en x y y a un nuevo valor aleatorio.
    // Se hace de t1.radius a width - t1.radius para que siempre este la elipse en la pantalla.
    // ejemplo: si saliera la posicion 0,0, solo se veria un cuarto del circulo, ya que lo demas estaria en valores negativos de la pantalla.
    t1.x = (int) random(t1.radius, width - t1.radius);
    t1.y = (int) random(t1.radius, height - t1.radius);
    acierto1++;
  }
  if(abs(xl - t2.x) < t2.radius && abs(yl - t2.y) < t2.radius){
    // Si estoy dentro del objetivo, cambio su posicion en x y y a un nuevo valor aleatorio.
    // Se hace de t1.radius a width - t1.radius para que siempre este la elipse en la pantalla.
    // ejemplo: si saliera la posicion 0,0, solo se veria un cuarto del circulo, ya que lo demas estaria en valores negativos de la pantalla.
    t2.x = (int) random(t2.radius, width - t2.radius);
    t2.y = (int) random(t2.radius, height - t2.radius);
    acierto2++;
  }
  if(abs(xl - t3.x) < t3.radius && abs(yl - t3.y) < t3.radius){
    // Si estoy dentro del objetivo, cambio su posicion en x y y a un nuevo valor aleatorio.
    // Se hace de t1.radius a width - t1.radius para que siempre este la elipse en la pantalla.
    // ejemplo: si saliera la posicion 0,0, solo se veria un cuarto del circulo, ya que lo demas estaria en valores negativos de la pantalla.
    t3.x = (int) random(t3.radius, width - t3.radius);
    t3.y = (int) random(t3.radius, height - t3.radius);
    acierto3++;
  }
  if(abs(xl - b1.x) < b1.ancho && abs(yl - b1.y) < b1.largo){
    // Si estoy dentro del objetivo, cambio su posicion en x y y a un nuevo valor aleatorio.
    // Se hace de t1.radius a width - t1.radius para que siempre este la elipse en la pantalla.
    // ejemplo: si saliera la posicion 0,0, solo se veria un cuarto del circulo, ya que lo demas estaria en valores negativos de la pantalla.
    b1.x = (int) random(b1.ancho, width - b1.ancho);
    b1.y = (int) random(b1.largo, height - b1.largo);
    HP++;
    vida--;
  }
  if(abs(xl - b2.x) < b2.ancho && abs(yl - b2.y) < b2.largo){
    // Si estoy dentro del objetivo, cambio su posicion en x y y a un nuevo valor aleatorio.
    // Se hace de t1.radius a width - t1.radius para que siempre este la elipse en la pantalla.
    // ejemplo: si saliera la posicion 0,0, solo se veria un cuarto del circulo, ya que lo demas estaria en valores negativos de la pantalla.
    b2.x = (int) random(b2.ancho, width - b2.ancho);
    b2.y = (int) random(b2.largo, height - b2.largo);
    SP++;
    escudo--;
  }
}
void shield(){
  fill(255,255,255,50);
  rect(0,0,800,500);
}
void healthBar(){
  fill(0,255,0);
  rect(0,0,50*HP,20);
}
void shieldBar(){
  fill(255,255,255,50);
  rect(400,0,50*SP,20);
}
