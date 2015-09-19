import processing.serial.*;
import processing.opengl.*;
import procontroll.*;
import java.io.*;
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
byte[] msg;
byte[] msg2;
float elev, airln, rudder, yaw, pitch, roll, gx_prev, gy_prev, gz_prev, int_elev=0.0, int_airln = 0.0;
float int_pitch = 0.0, int_heading = 0.0, int_speed = 0.0;
final float pi = 3.1415926535897932384626433832795;
String ip       = "localhost";  // the remote IP address
int port        = 49000;    // the destination port

ControllIO controll;
//ControllDevice device;
//ControllStick stick;
//ControllButton button;
//ControllSlider throtelslider;
//ControllSlider rudderslider;
Joystick x52;


boolean synched = false;
boolean autotrim = false;
boolean autopilotMode = false;
int XPlaneRx = 0;

float Href = 1000;
float Headingref = 0.0;
float Speedref = 40.0;
float speedCnt;

float rumbo, altura, velocidad;
int distancia, nRuta;

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


  controll = ControllIO.getInstance(this);
  x52 = new Joystick(controll);
}

void setupEPF() {
  println("Configurando epf");
  serial.write("#HILAUTOPILOT\r"); //Entrando en modo calibracion

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

int readInt(Serial s) {
  int byte0 = s.read() & 0xFF;
  int byte1 = s.read() & 0xFF;
  int byte2 = s.read() & 0xFF;
  int byte3 = s.read() & 0xFF;
  return (byte0 + (byte1 << 8) + (byte2 << 16) + (byte3 << 24));
}

//process events
void draw() {
  //  
  background(0);
  lights();
  textAlign(CENTER);
  // Sync with EPF 
  if (!synched) {
    textAlign(CENTER);
    fill(255);
    text("Connecting to EPF board...", width/2, height/2);

    if (frameCount == 2)
      setupEPF();  // Set ouput params and request synch token
    else if (frameCount > 2)
      synched = readToken(serial, "#SYNCH00\n\r");  // Look for synch token
    return;
  }
  //  if(x52.btn1pressed()){
  //    autopilotMode = !autopilotMode;
  //    autotrim = !autotrim;
  //  }

  //  println("eje X -> " + stick.getX());
  //  println("eje Y -> " + stick.getY());
  //  println("eje X -> " + (0.5 - throtelslider.getValue()/2 ));
  //  println("eje Y -> " + rudderslider.getValue());
  //  println(x52.getX());

  text("Conectado...", width/2, 135, 0);
  text("Presion 'a' para autotrim", width/2, 10, 0);
  text("Presion 's' para autopilot ON", width/2, 25, 0);
  text("Presion 'x' y 'z' para Waypoint", width/2, 40, 0);
  float rumbo = Headingref;
  if (rumbo < 0) rumbo +=360;
  text("Rumbo: " + ((int)rumbo), width/2, 60, 0);
  text("Altura: " + ((int)Href), width/2, 75, 0);
  text("Speed: " + ((int)Speedref), width/2, 90, 0);
  text("Dist: " + distancia, width/2, 105, 0);
  text("Waypoint: " + nRuta, width/2, 120, 0);
  if (autotrim) text("Autotrim ON", width/2, 150, 0);
  if (autopilotMode) text("AutoPilot ON", width/2, 165, 0);
  // Read angles from serial port

  while (serial.available () >= 24) {
    if ( readSynch(serial) ) {
      rumbo = readFloat(serial);
      altura = readFloat(serial);
      velocidad = readFloat(serial);
      float dist = readFloat(serial);
      float nr = readFloat(serial);
      //serial.clear(); 
      if ( (Float.isNaN(rumbo)==false) && (Float.isNaN(altura)==false) && (Float.isNaN(velocidad)==false)) {
        Href = altura;
        Headingref = rumbo;
        Speedref = velocidad; 
        //println(dist);
        distancia = (int)dist;
        nRuta = (int)nr;
      }
    }
    //    println("elev: " + pitch + ", aleron: " + roll);
    //    byte[] msg = xplane.flightControl(elev, airln, rudder);
    //    udp.send( msg, ip, port );
  }
  //  msg = xplane.flightControl(elev, airln, rudder);
  msg = xplane.flightSpeedControl(elev, airln, rudder, speedCnt);
  udp.send( msg, ip, port );

  msg = xplane.Joystickmensaje();
  udp.send( msg, ip, 50003 );
  
  msg = xplane.Mapsmensaje();
  udp.send( msg, ip, 50004 );
  
  //println(speedCnt);
  if (XPlaneRx >= 2) {
    XPlaneRx = 0;
    msg2 = xplane.autopilotmensaje();
    serial.write(msg2);
    //serial.clear();
    //delay(10);
  }
  //  msg = xplane.SpeedControl(speedCnt);
  //  udp.send( msg, ip, port );
  //println(speedCnt);
  //  println("elev: " + elev + " aleron: " + airln + " rudder: " + rudder);
}

/** 
 * on key pressed event:
 * send the current key value over the network
 */
void keyPressed() {
  switch (key) {
  case 'q':
    mensaje = xplane.flightSpeedControl(-999, -999, -999, -999);
    udp.send( mensaje, ip, port );
    serial.write("#qqq\r");
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
  case 's':
    autopilotMode = !autopilotMode;
    autotrim = true;
    break;
  case 'x':
    serial.write("#xxx\r");
    println('x');
    break;
  case 'z':
    serial.write("#zzz\r");
    println('z');
    break;
  case 't':
    Href += 50;
    break;
  case 'g':
    Href -=50;
    break;
  case 'h':
    Headingref += 5;
    if ( Headingref > 180) Headingref -=360;
    if ( Headingref < -180) Headingref +=360;
    break;
  case 'f':
    Headingref -=5;
    if ( Headingref > 180) Headingref -=360;
    if ( Headingref < -180) Headingref +=360;
    break;
  case 'u':
    Speedref += 5;
    if ( Speedref < 0) Speedref=0;
    break;
  case 'j':
    Speedref -=5;
    if ( Speedref < 0) Speedref=0;
    break;
  case 'o':
    byte[] msg = xplane.autopilotmensaje();
    serial.write(msg);
    break;
  case 'p':
    synched = !synched;
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
  XPlaneRx++;
  float altitude = xplane.alt_ftmsl();
  float velocidad = xplane.Vind_keas();

  float elevator; 
  float alerones;
  if (autopilotMode) {
    //*********************************************************
    //Bucle en pitch
    //    float pitchd = -15 * pi/180;
    float VVI = xplane.VVI();
    int_pitch = 0.06 * (Href - altitude);
    float pitchd = 0.06 * ( Href - (altitude + 0.1 * VVI)) + int_pitch;
    if ( pitchd > 15) pitchd = 15;
    if ( pitchd < -20) pitchd = -20;
    pitchd *= pi/180;
    float pitch = xplane.pitch_deg() * pi/180; 

    elevator = 2 * ( pitchd - pitch );
    if (elevator > 0.1) elevator = 0.1;
    if (elevator < -0.1) elevator = -0.1;

    //*********************************************************
    //Bucle en heading
    //    float alerones = xplane.ailrn() * 3;
    //float heading = xplane.hding_true();
    //float heading = xplane.hding_mag();
    float heading = xplane.AoA_hpath();
    if ( heading > 180) heading -=360;
    if ( heading < -180) heading +=360;

    float rolld = (Headingref - heading);
    if ( rolld > 180) rolld -=360;
    if ( rolld < -180) rolld +=360;
    rolld *= 0.8;

    if (rolld > 30) rolld = 30;
    if (rolld < -30) rolld = -30;
    //println(rolld + ", " + heading);
    rolld *= pi/180;
    float roll = xplane.roll_deg() * pi / 180; 
    if ( roll > pi) roll -=2*pi;
    if ( roll < -pi) roll +=2*pi;

    alerones = 1 * ( rolld - roll );
    if (alerones > 0.7) alerones = 0.7;
    if (alerones < -0.7) alerones = -0.7;

    //*********************************************************
    //Bucle en velocidad

    int_speed += (Speedref - velocidad)/700;
    if (int_speed > 1) int_speed = 1;
    if (int_speed < 0) int_speed = 0;


    //    speedCnt = 0*(Speedref - velocidad)/1000 + int_speed;
    speedCnt = int_speed;
    if (speedCnt > 1.0) speedCnt = 1.0;
    if (speedCnt < 0) speedCnt = 0;
    //    println( speedCnt + ", " + int_speed );
  }
  else {
    //    elevator = xplane.elev() * 2;
    elevator = x52.getY() * 2;
    int_pitch = 0.0;

    //    alerones = xplane.ailrn() * 3;
    alerones = x52.getX() * 3;
    int_heading = 0.0;


    //    speedCnt = xplane.thro1();
    speedCnt = x52.getThrl();
    int_speed = speedCnt;
  }
  //dprintln(alerones);


  //  float ruddr = xplane.ruddr();
  float ruddr = x52.getZ();
  //  float velocidad = xplane.Vind_keas();

  float div_Q = 0.2 + pow(velocidad/30, 2);
  float div_P = 0.5 + pow(velocidad/30, 2);
  float div_R = 0.1 + pow(velocidad/35, 2);
  float gy = xplane.Q()/div_Q;
  float gx = xplane.P()/div_P;
  float gz = xplane.R()/div_R;

  if (autotrim) {
    int_elev += 0.4 * (elevator - gy);
    int_airln += 0.6 * (alerones - gx);
  }
  else {
    int_elev = 0;
    int_airln = 0;
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

