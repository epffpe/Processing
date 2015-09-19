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
float elev, airln, rudder, yaw, pitch, roll, gx_prev, gy_prev, gz_prev, int_elev=0.0;
final float pi = 3.1415926535897932384626433832795;
String ip       = "localhost";  // the remote IP address
int port        = 49000;    // the destination port

boolean synched = false;
boolean autotrim = false;
/**
 * init
 */
void setup() {
  size(200, 200, OPENGL);
  //textSize(64);
  smooth();
  noStroke();
  frameRate(50);
  // create a new datagram connection on port 6000
  // and wait for incomming message
  udp = new UDP( this, 49003 );
  //udp.log( true ); 		// <-- printout the connection activity
  udp.listen( true );
  xplane = new XPlaneDecode();
  
  println(Serial.list());
  String portName = Serial.list()[0];
  serial = new Serial(this, portName, 115200);
  println("  -> Using port: " + portName);
  elev=0.0;
  airln=0.0;
  rudder=0.0;
  gx_prev=0.0;
  gy_prev=0.0;
  gz_prev=0.0;
}

void setupEPF(){
  serial.write("#hilfbw\r"); //Entrando en modo calibracion
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
  textAlign(CENTER);
  // Sync with Razor 
//  if (!synched) {
//    textAlign(CENTER);
//    fill(255);
//    text("Connecting to EPF board...", width/2, height/2, -200);
//    
//    if (frameCount == 2)
//      setupEPF();  // Set ouput params and request synch token
//    else if (frameCount > 2)
//      synched = readToken(serial, "#SYNCH00\n\r");  // Look for synch token
//    return;
//  }
  text("Conectado...", width/2, height/2, 0);
  text("Presion 'a' para autotrim", width/2, 30, 0);
  if(autotrim) text("Autotrim ON", width/2, height/2 +20, 0);
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
//    byte[] msg = xplane.flightControl(elev, airln, rudder);
//    udp.send( msg, ip, port );
  
//  }
  byte[] msg = xplane.flightControl(elev, airln, rudder);
  udp.send( msg, ip, port );
  println("elev: " + elev + " aleron: " + airln + " rudder: " + rudder);
}

/** 
 * on key pressed event:
 * send the current key value over the network
 */
void keyPressed() {
  switch (key) {
    case 'q':
        mensaje = xplane.flightControl(-999, -999, -999);
        udp.send( mensaje, ip, port );
//        serial.write("q");
        exit();
        break;
    case ' ':
        mensaje = xplane.flightControl(elev, airln, rudder);
        udp.send( mensaje, ip, port );
        elev += 0.01;
        //airln -=0.01;
        rudder += 0.01;
        break;
     case 'a':
        autotrim = !autotrim;
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
 
  float elevator = xplane.elev() * 2;
  float alerones = xplane.ailrn() * 3;
  float ruddr = xplane.ruddr();
  float velocidad = xplane.Vind_keas();
  
  float div_Q = 0.2 + pow(velocidad/30,2);
  float div_P = 0.5 + pow(velocidad/30,2);
  float div_R = 0.5 + pow(velocidad/35,2);
  float gy = xplane.Q()/div_Q;
  float gx = xplane.P()/div_P;
  float gz = xplane.R()/div_R;
  
  if(autotrim) {
    int_elev += 0.4 * (elevator - gy);
  }else{
    int_elev = 0;
  }  
  
  elev = 1 * (elevator - gy) + int_elev;
  airln = 0.6 *(alerones - gx);
  rudder = 1 * (ruddr- gz );
  
  if (elev > 1) elev = 1;
  if (elev < -1) elev = -1;
  
  if (airln > 1) airln = 1;
  if (airln < -1) airln = -1;
  
  if (rudder > 1) rudder = 1;
  if (rudder < -1) rudder = -1;
  
//  println(" Speed: " + Float.toString(velocidad[0]) );
//  println(" Pitch: " + Float.toString(Attitude[0]) + " Roll: " + Attitude[1] + " Yaw(true/mag): " + Float.toString(Attitude[2]) + '/' + Attitude[3]);
  // print the result
   //println( "receive "+longitud+": \""+strHeader+','+ strTag+','+ strDataRef+','+ strDataRef2+','+ velocidad[1] + "\" from "+ip+" on port "+port );

}

