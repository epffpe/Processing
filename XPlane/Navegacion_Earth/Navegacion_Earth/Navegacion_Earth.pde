import processing.serial.*;
import processing.opengl.*;
import procontroll.*;
import java.io.*;
// import UDP library
import hypermedia.net.*;


UDP udp;  // define the UDP object
String ip       = "localhost";  // the remote IP address
int port        = 49000;    // the destination port
byte[] mensaje;


MIUAV miUAV;
Path UAVpath;


double longitud = -15.39068477661157;
double latitud =27.9225761590804;
float alturametros = 121;
float alturafeets;
float yaw, pitch, roll;

boolean sem = true;


void setup() {
  size(200, 200, OPENGL);
  //textSize(64);
  smooth();
  noStroke();
  frameRate(1);

  //miUAV = new MIUAV("UAV.kml", "C:\\Users\\epf\\Dropbox\\Proyecto\\Google Earth\\Modelo UAV\\UAV.dae", 70);
  //UAVpath = new Path("UAVpath.kml", longitud, latitud, alturametros, 30, 0, 5000);

  udp = new UDP( this, 50004 );
  udp.log( true );     // <-- printout the connection activity
  udp.listen( true );
}
void draw() {
  background(0);
  lights();
  textAlign(CENTER); 

  sem = false;
  byte[] msg2 = mensaje;
  sem = true;
  String msgstr = new String(msg2);
  
  String parametros[] = msgstr.split(",");
  
  longitud = Double.parseDouble(parametros[0]);
  latitud = Double.parseDouble(parametros[1]);
  alturametros = Float.parseFloat(parametros[2]);
  yaw = Float.parseFloat(parametros[3]);
  pitch = Float.parseFloat(parametros[4]);
  roll = Float.parseFloat(parametros[5]);
  
  //println(msgstr);

  //longitud += 0.0001;
  //miUAV.update(longitud, latitud, alturametros, yaw, pitch, roll);
  //UAVpath.addPath(longitud, latitud, alturametros);
}


void receive( byte[] data, String ip, int port ) {
  if (sem) {
    mensaje = data;
  }
}


void keyPressed() {
  switch (key) {
  case 'q':
    exit();
    break;
  case 'r':
    UAVpath.resetPath();
    break;
  }
}

