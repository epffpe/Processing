import processing.core.*; 
import processing.xml.*; 

import processing.opengl.*; 
import processing.serial.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class EPF_AHRS_test extends PApplet {

/*************************************************************************************
* Test Sketch for Razor AHRS v1.4.1
* 9 Degree of Measurement Attitude and Heading Reference System
* for Sparkfun "9DOF Razor IMU" and "9DOF Sensor Stick"
*
* Released under GNU GPL (General Public License) v3.0
* Copyright (C) 2011-2012 Quality & Usability Lab, Deutsche Telekom Laboratories, TU Berlin
* Written by Peter Bartz (peter-bartz@gmx.de)
*
* Infos, updates, bug reports and feedback:
*     http://dev.qu.tu-berlin.de/projects/sf-razor-9dof-ahrs
*************************************************************************************/

/*
  NOTE: There seems to be a bug with the serial library in the latest Processing
  versions 1.5 and 1.5.1: "WARNING: RXTX Version mismatch ...". The previous version
  1.2.1 works fine and is still available on the web.
*/




// IF THE SKETCH CRASHES OR HANGS ON STARTUP, MAKE SURE YOU ARE USING THE RIGHT SERIAL PORT:
// 1. Have a look at the Processing console output of this sketch.
// 2. Look for the serial port list and find the port you need (it's the same as in Arduino).
// 3. Set your port number here:
final static int SERIAL_PORT_NUM = 0;
// 4. Try again.


final static int SERIAL_PORT_BAUD_RATE = 115200;

float yaw = 0.0f;
float pitch = 0.0f;
float roll = 0.0f;
float yawOffset = 0.0f;

PFont font;
Serial serial;

boolean synched = false;

public void drawArrow(float headWidthFactor, float headLengthFactor) {
  float headWidth = headWidthFactor * 200.0f;
  float headLength = headLengthFactor * 200.0f;
  
  pushMatrix();
  
  // Draw base
  translate(0, 0, -100);
  box(100, 100, 200);
  
  // Draw pointer
  translate(-headWidth/2, -50, -100);
  beginShape(QUAD_STRIP);
    vertex(0, 0 ,0);
    vertex(0, 100, 0);
    vertex(headWidth, 0 ,0);
    vertex(headWidth, 100, 0);
    vertex(headWidth/2, 0, -headLength);
    vertex(headWidth/2, 100, -headLength);
    vertex(0, 0 ,0);
    vertex(0, 100, 0);
  endShape();
  beginShape(TRIANGLES);
    vertex(0, 0, 0);
    vertex(headWidth, 0, 0);
    vertex(headWidth/2, 0, -headLength);
    vertex(0, 100, 0);
    vertex(headWidth, 100, 0);
    vertex(headWidth/2, 100, -headLength);
  endShape();
  
  popMatrix();
}

public void drawAlas(){
  // Ala principal
  pushMatrix();
  translate(0, -30, -25);
  box(600, 10, 100);
  popMatrix();
  
  pushMatrix();
  translate(0, -25, -75);
  beginShape(QUADS);
    vertex(-300, 0 ,0);
    vertex(-300, -10, 0);
    vertex(0, -10 ,-60);
    vertex(0, 0, -60);
    vertex(300, 0, 0);
    vertex(300, -10, 0);
    vertex(0, -10 ,-60);
    vertex(0, 0, -60);
  endShape();
  beginShape(TRIANGLES);
    vertex(-300, 0, 0);
    vertex(300, 0, 0);
    vertex(0, 0, -60);
    vertex(-300, -10, 0);
    vertex(300, -10, 0);
    vertex(0, -10, -60);
  endShape();
  popMatrix(); 
  
  //Estabilizador horizontal
  pushMatrix();
  translate(0, -30, 180);
  box(200, 10, 40);
  popMatrix();
  
  pushMatrix();
  translate(0, -25, 160);
  beginShape(QUADS);
    vertex(-100, 0 ,0);
    vertex(-100, -10, 0);
    vertex(0, -10 ,-30);
    vertex(0, 0, -30);
    vertex(100, 0, 0);
    vertex(100, -10, 0);
    vertex(0, -10 ,-30);
    vertex(0, 0, -30);
  endShape();
  beginShape(TRIANGLES);
    vertex(-100, 0, 0);
    vertex(100, 0, 0);
    vertex(0, 0, -30);
    vertex(-100, -10, 0);
    vertex(100, -10, 0);
    vertex(0, -10, -30);
  endShape();
  popMatrix(); 
  
  //Deriva, estabilizador vertical
  pushMatrix();
  fill(0, 255, 0);
  translate(0, -75, 180);
  rotateZ(radians(-90.0f));  
  box(100, 10, 39);
  popMatrix();
  
  pushMatrix();
  fill(0, 255, 0);
  translate(0, -25, 160);
  rotateZ(radians(-90.0f)); 
  beginShape(QUADS);
    vertex(0, -5 ,0);
    vertex(0, 5, 0);
    vertex(100, 5 ,0);
    vertex(100, -5, 0);
    vertex(100, -5, 0);
    vertex(0, -5, -70);
    vertex(0, 5 ,-70);
    vertex(100, 5, 0);
  endShape();
  beginShape(TRIANGLES);
    vertex(0, -5, 0);
    vertex(100, -5, 0);
    vertex(0, -5, -70);
    vertex(0, 5, 0);
    vertex(100, 5, 0);
    vertex(0, 5, -70);
  endShape();
  popMatrix(); 

}

public void printEPF(){
  pushMatrix();
  fill(0, 255, 0);
  translate(0, -30, -40);
  rotateX(radians(90.0f));
  scale(4.0f);
  textAlign(CENTER);
  //fill(0, 255, 0);
  text("epf",0,0,2);
  popMatrix();
  
  pushMatrix();
  fill(0, 255, 0);
  translate(180, -30, -10);
  rotateX(radians(-90.0f));
  rotateZ(radians(180.0f));
  scale(4.0f);
  textAlign(CENTER);
  //fill(0, 255, 0);
  text("epf",0,0,2);
  popMatrix();
  
  pushMatrix();
  fill(0, 255, 0);
  translate(-150, -30, -20);
  rotateX(radians(-90.0f));
  rotateZ(radians(180.0f));
  scale(2.0f);
  textAlign(CENTER);
  //fill(0, 255, 0);
  text("Supersonic",0,0,5);
  popMatrix();
}

public void drawBoard() {
  pushMatrix();

  rotateY(-radians(yaw - yawOffset));
  rotateX(-radians(pitch));
  rotateZ(radians(roll));
  
  //stroke(255);
  //line(-300,0,0,300,0,0);
  //noStroke(); 
  //rotateX(mouseY/180.0f);
  // Board body
  fill(0, 0, 255);
  box(50, 50, 400);
  
  drawAlas();
  printEPF();
  // Forward-arrow
  pushMatrix();
  translate(0, 0, -200);
  scale(0.5f, 0.2f, 0.25f);
  fill(0, 255, 0);
  drawArrow(1.0f, 2.0f);
  popMatrix();
    
  popMatrix();
}

// Skip incoming serial stream data until token is found
public boolean readToken(Serial serial, String token) {
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

// Global setup
public void setup() {
  // Setup graphics
  size(640, 480, OPENGL);
  smooth();
  noStroke();
  frameRate(50);
  
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

public void setupRazor() {
  println("Trying to setup and synch Razor...");
  
  // On Mac OSX and Linux (Windows too?) the board will do a reset when we connect, which is really bad.
  // See "Automatic (Software) Reset" on http://www.arduino.cc/en/Main/ArduinoBoardProMini
  // So we have to wait until the bootloader is finished and the Razor firmware can receive commands.
  // To prevent this, disconnect/cut/unplug the DTR line going to the board. This also has the advantage,
  // that the angles you receive are stable right from the beginning. 
  delay(1000);  // 3 seconds should be enough
  /*
  // Set Razor output parameters
  serial.write("#ob");  // Turn on binary output
  serial.write("#o1");  // Turn on continuous streaming output
  serial.write("#oe0"); // Disable error message output
  */
  // Synch with Razor
  serial.clear();  // Clear input buffer up to here
  serial.write("#s00");  // Request synch token
}

public float readFloat(Serial s) {
  // Convert from little endian (Razor) to big endian (Java) and interpret as float
  return Float.intBitsToFloat(s.read() + (s.read() << 8) + (s.read() << 16) + (s.read() << 24));
}

public void draw() {
   // Reset scene
  background(0);
  lights();

  // Sync with Razor 
  if (!synched) {
    textAlign(CENTER);
    fill(255);
    text("Connecting to EPF board...", width/2, height/2, -200);
    
    if (frameCount == 2)
      setupRazor();  // Set ouput params and request synch token
    else if (frameCount > 2)
      synched = readToken(serial, "#SYNCH00\r\n");  // Look for synch token
    return;
  }
  
  // Read angles from serial port
  while (serial.available() >= 12) {
    yaw = readFloat(serial);
    pitch = readFloat(serial);
    roll = readFloat(serial);
  }

  // Draw board
  pushMatrix();
  translate(width/2, height/2, -350);
  drawBoard();
  popMatrix();
  
  textFont(font, 20);
  fill(255);
  textAlign(LEFT);

  // Output info text
  text("Point EPF Autopilot towards screen and press 'a' to align", 10, 25);

  // Output angles
  pushMatrix();
  translate(10, height - 10);
  textAlign(LEFT);
  text("Yaw: " + ((int) yaw), 0, 0);
  text("Pitch: " + ((int) pitch), 150, 0);
  text("Roll: " + ((int) roll), 300, 0);
  popMatrix();
}

public void keyPressed() {
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
    case 'a':  // Align screen with Razor
      yawOffset = yaw;
  }
}



  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#F0F0F0", "EPF_AHRS_test" });
  }
}
