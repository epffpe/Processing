import org.ejml.data.*;
import org.ejml.simple.*;
import org.ejml.ops.*;

final float pi = 3.1415926535897932384626433832795f;
final static int SERIAL_PORT_NUM = 0;

import processing.opengl.*;
import processing.serial.*;

final static int SERIAL_PORT_BAUD_RATE = 115200;

final static int NUM_HOUR = 1;

final static int NUM_ATTITUDE_SAMPLES = NUM_HOUR * 60 * 60 * 100;
float attitude[][] = new float[NUM_ATTITUDE_SAMPLES][3];
float temperatura[] = new float[NUM_ATTITUDE_SAMPLES];
float temperaturagyro[] = new float[NUM_ATTITUDE_SAMPLES];
float gyrop, gyroq, gyror, temp, tempgyro;
int attitudeIndex = 0;

PFont font;
Serial serial;

boolean synched = false;


// Global setup
void setup() {
  // Setup graphics
  size(800, 800, OPENGL);
  smooth();
  noStroke();
  frameRate(100);
  colorMode(HSB);
  
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
}

void setupEpf() {
  println("Trying to setup and synch epf...\n");
 
  serial.write("#gyrocal\r"); //Entrando en modo attitude
  delay(1000);
  // Synch with EPF
  serial.clear();  // Clear input buffer up to here
  serial.write("#s00\r");  // Request synch token
}


// Skip incoming serial stream data until token is found
boolean readToken(Serial serial, String token) {
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

float readFloat(Serial s) {
  // Convert from little endian (Razor) to big endian (Java) and interpret as float
  return Float.intBitsToFloat(s.read() + (s.read() << 8) + (s.read() << 16) + (s.read() << 24));
}

void skipBytes(Serial s, int numBytes) {
  for (int i = 0; i < numBytes; i++) {
    s.read();
  }  
}

boolean readSynch(Serial serial) {
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

void draw() {
  // Reset scene
  lights();

  // Sync with Razor 
  if (!synched) {
    background(0);
    textAlign(CENTER);
    fill(255);
     text("Connecting to EPF board...", width/2, height/2, -200);
    
    if (frameCount == 2)
      setupEpf();  // Set ouput params and request synch token
    else if (frameCount > 2)
      synched = readToken(serial, "#SYNCH00\n\r");  // Look for synch token
    return;
  }
    
  // Output "max samples reached" message?
  if (attitudeIndex >= NUM_ATTITUDE_SAMPLES - 1) {
    fill(0, 255, 255);
    text("MAX NUMBER OF SAMPLES REACHED!", width/2, 0, -250);
    println("MAX NUMBER OF SAMPLES REACHED!");
    outputToFile();
  }
  
  if (attitudeIndex % 10 == 0){
     // Output angles
    background(0);
    pushMatrix();
      translate(width/2, 0, -500);
      textAlign(CENTER);
      text("Temperatura: " + temp + ", " + tempgyro, 0, 0);
      text("GyroX: " + ((int)gyrop), 0, 100);
      text("GyroY: " + ((int)gyroq), 0, 200);
      text("GyroZ: " + ((int)gyror), 0, 300);
      text("Muestra tomadas:   " + attitudeIndex, 0, 500);
      text("Muestras restante: " + (NUM_ATTITUDE_SAMPLES - attitudeIndex), 0, 600);
      text("Muestras totales:  " + NUM_ATTITUDE_SAMPLES, 0, 700);
      noFill();
      stroke(255);
      fill(200);
      text("Tomando muestras de attitude para calcular la desviacion estandar", 0, -450, -400);
      text("Press 'r' to reset. Press SPACE to output calibration parameters to console and quit.", 0, -400, -600);
      text("EPF Supersonic", 0, 1000, 000);
    popMatrix(); 
  }
 
  pushMatrix(); {
    translate(width/2, height/2, -900);
    
    // Draw sphere and background once
    if (attitudeIndex == 0) {
      background(0);
      noFill();
      stroke(255);
      sphereDetail(10);
      //sphere(400);
      fill(200);
      text("Press 'r' to reset. Press SPACE to output calibration parameters to console and quit.", 0, 1100, -600);
    }
  
    // Read and draw new sample
    if (attitudeIndex < NUM_ATTITUDE_SAMPLES && serial.available() >= 20) {
      // Read all available magnetometer data from serial port
      while (serial.available() >= 20) {
        if ( readSynch(serial) ){
          temp = readFloat(serial);
          tempgyro = (float)serial.read();
          gyrop  = readFloat(serial);  // x
          gyroq = readFloat(serial);  // y
          gyror = readFloat(serial);  // z
          
        }
        if (attitudeIndex < NUM_ATTITUDE_SAMPLES &&  readSynch(serial) ){
          temperatura[attitudeIndex] = temp;
          temperaturagyro[attitudeIndex] = tempgyro;
          attitude[attitudeIndex][0] = gyrop;  // x
          attitude[attitudeIndex][1] = gyroq;  // y
          attitude[attitudeIndex][2] = gyror;  // z
          attitudeIndex++;
        }
      }
      
    }
    
  } popMatrix();
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
    case ' ':  // Calculate and output calibration parameters, output binary magnetometer samples file, quit
    case ENTER:
    case RETURN:
      outputToFile();  // Do the magic
      serial.write("q");
      exit();  // We're done
      break;
    case 'r':  // Reset samples and clear screen
      attitudeIndex = 0;
      break;
    case 'q':  
      serial.write("q");
      exit();
      break;
  }
}


void outputToFile() {
  // Check if we have at least 9 sample points
  if (attitudeIndex < 9) {
    println("ERROR: not enough magnetometer samples. We need at least 9 points.");
    exit();
  }
  
  /* OUTPUT RESULTS */
  // Output magnetometer samples file
  try {
    println("Trying to write " + attitudeIndex + " sample points to file attitude.float ...");
    FileOutputStream fos = new FileOutputStream(sketchPath("gyroTempRAW_30_40.float"));
    DataOutputStream dos = new DataOutputStream(fos);
    for (int i = 0; i < attitudeIndex; i++) {
      dos.writeFloat(temperatura[i]);
      dos.writeFloat(temperaturagyro[i]);
      dos.writeFloat(attitude[i][0]);
      dos.writeFloat(attitude[i][1]);
      dos.writeFloat(attitude[i][2]);
    }
    fos.close();
    println("Done.");
  } catch(Exception e) {
    println("Exception: " + e.toString());
  }
  println("\n");

}


