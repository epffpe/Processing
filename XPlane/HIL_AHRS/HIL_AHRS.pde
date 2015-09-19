import processing.serial.*;
import processing.opengl.*;

/**
 * (./) udp.pde - how to use UDP library as unicast connection
 * (cc) 2006, Cousot stephane for The Atelier Hypermedia
 * (->) http://hypermedia.loeil.org/processing/
 *
 * Create a communication between Processing<->Pure Data @ http://puredata.info/
 * This program also requires to run a small program on Pd to exchange data  
 * (hum!!! for a complete experimentation), you can find the related Pd patch
 * at http://hypermedia.loeil.org/processing/udp.pd
 * 
 * -- note that all Pd input/output messages are completed with the characters 
 * ";\n". Don't refer to this notation for a normal use. --
 */

// import UDP library
import hypermedia.net.*;
XPlaneDecode xplane;
Serial serial;
UDP udp;  // define the UDP object
byte[] mensaje;
float elev, airln, rudder, yaw, pitch, roll;
final float pi = 3.1415926535897932384626433832795;
String ip       = "localhost";  // the remote IP address
int port        = 49000;    // the destination port

boolean synched = false;
/**
 * init
 */
void setup() {
  size(400, 400, OPENGL);
  //textSize(64);
  smooth();
  noStroke();
  frameRate(50);
  // create a new datagram connection on port 6000
  // and wait for incomming message
  udp = new UDP( this, 49005 );
  //udp.log( true ); 		// <-- printout the connection activity
  udp.listen( true );
  xplane = new XPlaneDecode();
  
  println(Serial.list());
  String portName = Serial.list()[1];
  serial = new Serial(this, portName, 115200);
  println("  -> Using port: " + portName);
  elev=0.0;
  airln=0.0;
  rudder=0.0;
}

void setupEPF(){
  serial.write("#sim\r"); //Entrando en modo calibracion
  delay(1000);
  serial.clear(); 
  serial.write("#s00\0");
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

float readFloat(Serial s) {
  // Convert from little endian (Razor) to big endian (Java) and interpret as float
  return Float.intBitsToFloat(s.read() + (s.read() << 8) + (s.read() << 16) + (s.read() << 24));
}



//process events
void draw() {
//  
  background(0);
  lights();

  // Sync with Razor 
  if (!synched) {
    textAlign(CENTER);
    fill(255);
    text("Connecting to EPF board...", width/2, height/2, -200);
    
    if (frameCount == 2)
      setupEPF();  // Set ouput params and request synch token
    else if (frameCount > 2)
      synched = readToken(serial, "#SYNCH00\n\r");  // Look for synch token
    return;
  }
  text("Conectado...", width/2, height/2, -200);
  // Read angles from serial port
//  while (serial.available() >= 16) {
//    if ( readSynch(serial) ){
//      yaw = readFloat(serial);
//      pitch = readFloat(serial);
//      roll = readFloat(serial);
//      //serial.clear(); 
//      elev = pitch/ 40.0;
//      airln = roll/ 60.0;
//      
//    }
//    println("elev: " + pitch + ", aleron: " + roll);
//    byte[] msg = xplane.joysticControl(elev, airln, rudder);
//    udp.send( msg, ip, port );
//  }
  
}

/** 
 * on key pressed event:
 * send the current key value over the network
 */
void keyPressed() {
  switch (key) {
    case 'q':
        mensaje = xplane.joysticControl(-999, -999, -999);
        udp.send( mensaje, ip, port );
        serial.write("q");
        exit();
        break;
    case ' ':
        mensaje = xplane.joysticControl(elev, airln, rudder);
        udp.send( mensaje, ip, port );
        elev += 0.01;
        //airln -=0.01;
        rudder += 0.01;
        break;
  }  
  
}

/**
 * To perform any action on datagram reception, you need to implement this 
 * handler in your code. This method will be automatically called by the UDP 
 * object each time he receive a nonnull message.
 * By default, this method have just one argument (the received message as 
 * byte[] array), but in addition, two arguments (representing in order the 
 * sender IP address and his port) can be set like below.
 */
// void receive( byte[] data ) { 			// <-- default handler
void receive( byte[] data, String ip, int port ) {	// <-- extended handler
  xplane.update(data);
 
  float[] velocidad = xplane.readSpeed();
  float[] Attitude = xplane.readAttitude();
  float time = xplane.time_missn();
  println(time);
//  println(" Speed: " + Float.toString(velocidad[0]) );
//  println(" Pitch: " + Float.toString(Attitude[0]) + " Roll: " + Attitude[1] + " Yaw(true/mag): " + Float.toString(Attitude[2]) + '/' + Attitude[3]);
  // print the result
   //println( "receive "+longitud+": \""+strHeader+','+ strTag+','+ strDataRef+','+ strDataRef2+','+ velocidad[1] + "\" from "+ip+" on port "+port );

}

