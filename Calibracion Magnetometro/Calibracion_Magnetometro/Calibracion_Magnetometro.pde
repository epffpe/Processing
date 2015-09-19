import org.ejml.data.*;
import org.ejml.simple.*;
import org.ejml.ops.*;

import processing.opengl.*;
import processing.serial.*;

PFont font;
Serial serial;
final static int SERIAL_PORT_NUM = 1;
final static int SERIAL_PORT_BAUD_RATE = 115200;

final float MagOffset[] = {78.3956, 222.161, -87.5116};
final float Wmag[][] = {{0.847867, 0.00292312, -0.0302894}, {0.00292312, 0.856063, -0.0148167}, {-0.0302894, -0.0148167, 0.992321}};

final float pi = 3.1415926535897932384626433832795;
MagCal magneto;


/*************************************************************** 
 *           Global Setup
 ***************************************************************/
void setup() {
  // Setup graphics
  size(1000, 800, OPENGL);
  
  
  // Load font
  font = loadFont("Univers-66.vlw");
  textFont(font);
  
  // Setup serial port I/O
  println("AVAILABLE SERIAL PORTS:");
  println(Serial.list());
  String portName = Serial.list()[SERIAL_PORT_NUM];
  println();
  println("HAVE A LOOK AT THE LIST ABOVE AND SET THE RIGHT SERIAL PORT NUMBER IN THE CODE!");
  println("  -> Using port " + SERIAL_PORT_NUM + ": " + portName);
  serial = new Serial(this, portName, SERIAL_PORT_BAUD_RATE);
  magneto = new MagCal(serial);
}

void draw() {
  lights();
  
  // Sync with Razor 
  if (!magneto.synched) {
    background(0);
    textAlign(CENTER);
    fill(255);
    text("Connecting to EPF AutoPilot...", width/2, height/2, -200);
    
    if (frameCount == 2)
      magneto.setupEpf();  // Set ouput params and request synch token
    else if (frameCount > 2)
      magneto.synched = magneto.readToken("#SYNCH00\n\r");  // Look for synch token
    return;
  }
  
  magneto.update();
  
}
void keyPressed() {
  switch (key) {
    case '0':  // Turn Razor's continuous output stream off
      serial.write("#o0");
      break;
    case '1':  // Turn Razor's continuous output stream on
      serial.write("#o1");
      break;
    case 'f':  // Request one single yaw/pitch/roll frame from Razor (use when continuous streaming is off)
      serial.write("#f");
      break;
    case 'q':  
      serial.write("q");
      exit();  // We're done
      break;
  }
}

/*************************************************************** 
 *           Clase para calibrar el magnetometro
 ***************************************************************/ 
class MagCal {
  int NUM_MAGN_SAMPLES;
  float magnetom[][];
  int magraw[];
  float magsensor[];
  float magPC[];
  float magtemp[];
  float attitude[];
  float yaw;
  float pitch;
  float roll;
  float Xh,Yh;
// 	float Hh;
  float psi;
  float yawpc;
  float cos_roll;
  float sin_roll;
  float cos_pitch;
  float sin_pitch;
  int magnetomIndex;
  boolean synched;
  Serial serial;
/***************************************************************/  
  MagCal(Serial s){
    smooth();
    noStroke();
    frameRate(50);
    colorMode(HSB);
    NUM_MAGN_SAMPLES = 10000;
    magnetomIndex = 0;  
    synched = false;
    magnetom = new float[NUM_MAGN_SAMPLES][3];
    magraw = new int[3];
    magsensor = new float[3];
    magPC = new float[3];
    magtemp = new float[3];
    attitude = new float[3];
    yaw = 0;
    pitch = 0;
    roll = 0;
    serial = s;
  }
/***************************************************************/  
  boolean readToken(String token) {
    // Wait until enough bytes are available
    if (serial.available() < token.length())
      return false;
  
    // Check if incoming bytes match token
    for (int i = 0; i < token.length(); i++) {
      if (serial.read() != token.charAt(i))
        return false;
    }
  
    return true;
  }
/***************************************************************/
  void setupEpf() {
    println("Trying to setup and synch epf...\n");
    serial.write("#magtest\r"); //Entrando en modo calibracion
    delay(1000);
    // Synch with epf
    serial.clear();  // Clear input buffer up to here
    serial.write("#s00\r");  // Request synch token
  }
/***************************************************************/  
  float readFloat() {
    return Float.intBitsToFloat(serial.read() + (serial.read() << 8) + (serial.read() << 16) + (serial.read() << 24));
  }
/***************************************************************/  
  int readInteger() {
    return (serial.read() + (serial.read() << 8) + (serial.read() << 16) + (serial.read() << 24));
  }
/***************************************************************/
  void skipBytes(int numBytes) {
    for (int i = 0; i < numBytes; i++) {
      serial.read();
    }  
  }
/***************************************************************/
  boolean readSynch() {
    // Wait until enough bytes are available
    if (serial.available() < 4)
      return false;
  
    // Check if incoming bytes match token
    for (int i = 0; i < 4; i++) {
      if (serial.read() != 0xAA )
        return false;
    }
    return true;
  }
/***************************************************************/
/*
  boolean synchEpfBoard(){
    if (!synched) {
      background(0);
      textAlign(CENTER);
      fill(255);
      text("Conectando con EPF Board...", width/2, height/2, -200);
    
      if (frameCount == 2)
        setupEpf();  
      else if (frameCount > 2)
        synched = readToken("#SYNCH00\n\r");
      return true;
    }
  }
 */
/***************************************************************/
  void update(){
   background(0);
   textAlign(CENTER);
   text("Presiona 'q' para terminar", width/2, height-20, -500);
   text("Test Sensor Manetometro EPF Autopilot", width/2, -100, -300);
   //println("MAX NUMBER OF SAMPLES REACHED!");
   
    // Read and draw new sample
    if (serial.available() >= 40) {
    
      while (serial.available() >= 40) {
        if ( readSynch() ){
          magraw[0] = readInteger();
          magraw[1] = readInteger();
          magraw[2] = readInteger();
          magsensor[0] = readFloat();  // x
          magsensor[1] = readFloat();  // y
          magsensor[2] = readFloat();  // z
          attitude[0] = readFloat();  //yaw
          attitude[1] = readFloat();  //pitch
          attitude[2] = readFloat();  //roll
        }
      }   
    }
    cos_roll = cos(attitude[2]);
    sin_roll = sin(attitude[2]);
    cos_pitch = cos(attitude[1]); 
    sin_pitch = sin(attitude[1]);
    
    
    yaw = attitude[0] * 180/pi;
    pitch = attitude[1] * 180/pi;
    roll = attitude[2] * 180/pi;
    
    
    
    textAlign(LEFT);
    text("Mag Raw X: " + magraw[0], -200, 0, -300);
    text(" Y: " + magraw[1], 400, 0, -300);
    text(" Z: " + magraw[2], 800, 0, -300);
    
    text("Mag PCB X: " + magsensor[0], -200, 50, -300);
    text(" Y: " + magsensor[1], 400, 50, -300);
    text(" Z: " + magsensor[2], 800, 50, -300);
    
    magtemp[0] = magraw[0] - MagOffset[0];
    magtemp[1] = magraw[1] - MagOffset[1];
    magtemp[2] = magraw[2] - MagOffset[2];
    
    magPC[0] = Wmag[0][0] *  magtemp[0] + Wmag[0][1] *  magtemp[1] + Wmag[0][2] *  magtemp[2];
    magPC[1] = Wmag[1][0] *  magtemp[0] + Wmag[1][1] *  magtemp[1] + Wmag[1][2] *  magtemp[2];
    magPC[2] = Wmag[2][0] *  magtemp[0] + Wmag[2][1] *  magtemp[1] + Wmag[2][2] *  magtemp[2];
    
    
    Xh  = magPC[0] * cos_pitch + magPC[1] * sin_roll * sin_pitch + magPC[2] * cos_roll * sin_pitch;
    Yh  = magPC[1] * cos_roll - magPC[2] * sin_roll;
// 	Hh = sqrt(Xh*Xh + Yh*Yh);
    psi = atan2(-Yh, Xh);
//  	psi = -atan2(my, mx);
    yawpc = psi * 180/pi;
    
    text("Mag PC X: " + magPC[0], -200, 100, -300);
    text(" Y: " + magPC[1], 400, 100, -300);
    text(" Z: " + magPC[2], 800, 100, -300);
    
    
    text("Yaw PCB = " + yaw, -200, 200, -300);
    text("Yaw PC  = " + yawpc, -200, 300, -300);
    text("Pitch   = " + pitch, -200, 400, -300);
    text("Roll    = " + roll, -200, 500, -300);
    
    
  }
  
  
}

/*************************************************************** 
 *           Fin del fichero
 ***************************************************************/ 
 
 
