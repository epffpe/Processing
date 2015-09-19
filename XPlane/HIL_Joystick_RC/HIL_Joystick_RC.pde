import processing.serial.*;
import processing.opengl.*;
import procontroll.*;
import java.io.*;
// import UDP library
import hypermedia.net.*;


XPlaneDecode xplane;
Serial serial;

ControllIO controll;
//ControllDevice device;
//ControllStick stick;
//ControllButton button;
//ControllSlider throtelslider;
//ControllSlider rudderslider;
Joystick x52;


boolean synched = false;
boolean sem = true;
int Joy = 0;



UDP udp;  // define the UDP object
String ip       = "localhost";  // the remote IP address
int port        = 49000;    // the destination port
byte[] mensaje;

/**
 * init
 */
void setup() {
  size(200, 200, OPENGL);
  //textSize(64);
  smooth();
  noStroke();
  frameRate(100);
  
  println(Serial.list());
  String portName = Serial.list()[2];
  serial = new Serial(this, portName, 115200);
  println("  -> Using port: " + portName);
  
  xplane = new XPlaneDecode();
  controll = ControllIO.getInstance(this);
  x52 = new Joystick(controll);
  
  
  udp = new UDP( this, 50003 );
  //udp.log( true );     // <-- printout the connection activity
  udp.listen( true );
  
}

void setupEPF(){
  println("Configurando epf");
  serial.write("#JOYSTICKTEST\r"); //Entrando en modo calibracion
  
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
  
  text("Conectado...", width/2, height/2 + 20, 0);
  
//  while (serial.available() >= 16) {
//    if ( readSynch(serial) ){
//      rumbo = readFloat(serial);
//      altura = readFloat(serial);
//      velocidad = readFloat(serial);
//      //serial.clear(); 
//      if( (Float.isNaN(rumbo)==false) && (Float.isNaN(altura)==false) && (Float.isNaN(velocidad)==false)){
//        
//      }      
//    }
  
//  }

  
  if(Joy++ >= 5){
    Joy = 0;
    
//    float elevator = x52.getY();
//    float alerones = x52.getX();
//    float speedCnt = x52.getThrl();
//    speedCnt = 2 * ( speedCnt - 0.5);
//    float ruddr = x52.getZ();
//    byte[] msg2 = xplane.Joystickmensaje(elevator,alerones, ruddr, speedCnt);

    sem = false;
    byte[] msg2 = mensaje;
    sem = true;
    
    
    serial.write(msg2);
   //println(msg2);
//    println(" Elev: " + elevator + " Alirn: " + alerones + " Rudder: " + ruddr + " Throttle: " + speedCnt);    
  }
}

/** 
 * on key pressed event:
 * send the current key value over the network
 */
void keyPressed() {
  switch (key) {
    case 'q':
        serial.write("#qq\r");
        exit();
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

void receive( byte[] data, String ip, int port ) {
  if (sem) {
    mensaje = data;
  }  
}



