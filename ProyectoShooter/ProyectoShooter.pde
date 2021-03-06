import processing.serial.*; 
//Documentación
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
boolean dig4;                   // Sensor digital 4
boolean sync = false;          // Indica si la comunicacion serial esta sincronizada
boolean ADC1=false;            // Indica si hay datos por recibir del canal de adquisición 1
boolean ADC2=false;            // Indica si hay datos por recibir del canal de adquisición 2
String[] txtBuffer1 = new String[txtSamples];
String[] txtBuffer2 = new String[txtSamples];

// Variables de ploteo

int ls = 30;
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

void setup(){
  printArray(Serial.list()); 
  myPort = new Serial(this, Serial.list()[0], 115200); 
  myPort.buffer(buffersize);
 
  // Ploteo
  size(800,500);
  background(0);
  xLabel = width - 4*ls;
  yLabel = height - 4*ls;
  font = createFont("Arial", ls);
  textFont(font);
  drawGrid();
} 

void draw() { 
  println("DRAW STAR");
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
      plot1(val1Buffer.get(0));
      val1Buffer.remove(0);
    }
      
    if(val2Buffer.size() != 0){
      plot2(val2Buffer.get(0));
      val2Buffer.remove(0);
    }
  }
  println("DRAW END");
}
 
void serialEvent(Serial myPort) { 
  // Inicia conteo de tiempo de corrida
  println("SERIAL STAR");
  // runTime = System.nanoTime();
  
  // Lectura del buffer de entrada
  myPort.readBytes(inBuffer);
  if (inBuffer != null) {
   // println("BUFFER: ");
    //printArray(inBuffer);
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
      println("eje x : " + val1);
      ADC1=false;
    }
    
  // Inicia decodificación del protocolo para la señal del eje 2 (ADC2)
    if(ADC2){
      decodeADC2();
      val2Buffer.append(val2);
      println("eje y : " + val2);
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

  println("SERIAL END: "+ runTime);
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
  }
  stroke(255);
  line(2*ls, 2*ls, 2*ls, height -2*ls); // xlabel
  line(2*ls, height- 2*ls, width - 2*ls, height- 2*ls); // ylabel
  fill(100);
  text("Escala X: "+ xScale[xSet] + "us", 2*ls, height -ls);
  text("Escala Y: "+ yScale[ySet] + "mV", 3*ls + textWidth("Escala X: "+ xScale[xSet] + "us") , height -ls);
  
  xSamples = int(numScale*xScale[xSet]/sampleTime);
  xLength = xLabel/xSamples;
  ySamples= int(numScale*yScale[ySet]/sampleVolt);
  yLength= yLabel/ySamples;
}

void  plot1(int var){
  stroke(255,255,0);
  if((OscCount1 < xSamples) && (OscCount1 != 0)){
    line(2*ls + (OscCount1-1) * xLength, height -2*ls - preVar1 * yLength, 2*ls + OscCount1 * xLength, height -2*ls - var * yLength);
  }
    if(OscCount1 >= xSamples){
    clear = true;
  }

  preVar1 = var;
  OscCount1++;
}
void  plot2(int var){
  stroke(48,139,206);
  if((OscCount2 < xSamples) && (OscCount2 != 0)){
    line(2*ls + (OscCount2-1) * xLength, height -2*ls - preVar2 * yLength, 2*ls + OscCount2 * xLength, height -2*ls - var * yLength);
  }
  
  if(OscCount2 >= xSamples){
    clear = true;
  }

  preVar2 = var;
  OscCount2++;
}

void keyPressed(){
    if(key == CODED){
      switch(keyCode){
        case RIGHT:
          if(xSet!=xScale.length-1)
            xSet++;
          break;
        case LEFT:
          if(xSet!=0)
            xSet--;
          break;
        case UP:
          if(ySet!=yScale.length-1)
            ySet++;
          break;
        case DOWN:
          if(ySet!=0)
            ySet--;
          break;
      }
      clear = true;
    }
    if(key == 32)
      stop = !stop;  
}