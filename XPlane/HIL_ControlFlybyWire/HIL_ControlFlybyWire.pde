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
float elev, airln, rudder, yaw, pitch, roll, gx_prev, gy_prev, gz_prev;
final float pi = 3.1415926535897932384626433832795;
String ip       = "localhost";  // the remote IP address
int port        = 49000;    // the destination port

boolean synched = false;
boolean udprec = false;
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
  mensaje = new byte[24];
}

void setupEPF() {
  println("Configurando epf");
  serial.write("#HILFBW\r"); //Entrando en modo calibracion
  delay(1000);
  serial.clear(); 
  serial.write("#s00\0\r");
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
    text("Connecting to EPF board...", width/2, height/2, 0);

    if (frameCount == 2)
      setupEPF();  // Set ouput params and request synch token
    else if (frameCount > 2)
      synched = readToken(serial, "#SYNCH00\n\r");  // Look for synch token
    return;
  }
  text("Conectado...", width/2, height/2, 0);

  if (udprec == true) {
    udprec = false;
    serial.write(mensaje);
    //println(" Enviando trama serie" + mensaje);
  }

  // Read angles from serial port
  while (serial.available () >= 16) {
    if ( readSynch(serial) ) {
      elev = readFloat(serial);
      airln = readFloat(serial);
      rudder = readFloat(serial);
      //serial.clear(); 

      if ( Float.isNaN(elev) || Float.isNaN(airln) || Float.isNaN(rudder)) {
        
      }else {
        if (elev > 1.0) elev = 1.0;
        if (elev < -1.0) elev = -1.0;

        if (airln > 1.0) airln = 1.0;
        if (airln < -1.0) airln = -1.0;
        if (rudder > 1.0) rudder = 1.0;
        if (rudder < -1.0) rudder = -1.0;
        
        println("elev: " + elev + ", aleron: " + airln + ", rudder: " + rudder);
        byte[] msg = xplane.flightControl(elev, airln, rudder);
        udp.send( msg, ip, port );
      }
    }
  }
  //  byte[] msg = xplane.flightControl(elev, airln, rudder);
  //  udp.send( msg, ip, port );
  //  println("elev: " + elev + " aleron: " + airln + " rudder: " + rudder);
}

/** 
 * on key pressed event:
 * send the current key value over the network
 */
void keyPressed() {
  switch (key) {
  case 'q':
    serial.write("#q");
    mensaje = xplane.flightControl(-999, -999, -999);
    udp.send( mensaje, ip, port );        
    exit();
    break;
  case ' ':
    mensaje = xplane.flightControl(elev, airln, rudder);
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
  mensaje = xplane.fbwmensaje();
  udprec = true;
  println("elev: " + xplane.elev() + " aler: " + xplane.ailrn() + " ruddr: " + xplane.ruddr());
  //  float elevator = xplane.elev();
  //  float alerones = xplane.ailrn();
  //  float ruddr = xplane.ruddr();
  //  
  //  float gy = xplane.Q();
  //  float gx = xplane.P();
  //  float gz = xplane.R();
  //  
  //  byte[] variable = xplane.float2byte(elevator);
  //  mensaje[0] = variable[0];
  //  mensaje[1] = variable[1];
  //  mensaje[2] = variable[2];
  //  mensaje[3] = variable[3];
  //  variable = xplane.float2byte(alerones);
  //  mensaje[4] = variable[0];
  //  mensaje[5] = variable[1];
  //  mensaje[6] = variable[2];
  //  mensaje[7] = variable[3];
  //  variable = xplane.float2byte(ruddr);
  //  mensaje[8] = variable[0];
  //  mensaje[9] = variable[1];
  //  mensaje[10] = variable[2];
  //  mensaje[11] = variable[3];
  //  variable = xplane.float2byte(gx);
  //  mensaje[12] = variable[0];
  //  mensaje[13] = variable[1];
  //  mensaje[14] = variable[2];
  //  mensaje[15] = variable[3];
  //  variable = xplane.float2byte(gy);
  //  mensaje[16] = variable[0];
  //  mensaje[17] = variable[1];
  //  mensaje[18] = variable[2];
  //  mensaje[19] = variable[3];
  //  variable = xplane.float2byte(gz);
  //  mensaje[20] = variable[0];
  //  mensaje[21] = variable[1];
  //  mensaje[22] = variable[2];
  //  mensaje[23] = variable[3];
}

