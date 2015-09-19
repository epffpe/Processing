import processing.serial.*;

Serial myPort;  // Create object from Serial class
int val;        // Data received from the serial port
float f = 3.14f;


void setup() 
{
  size(200, 200);
  frameRate(10);
  // I know that the first port in the serial list on my mac
  // is always my  FTDI adaptor, so I open Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port is the one you're using.
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 115200);
 // myPort.write("#testfloats\r");
}

void draw() {
  background(255);
  /*
  if (mouseOverRect() == true) {  // If mouse is over square,
    fill(204);                    // change color and
    myPort.write('H');              // send an H to indicate mouse is over square
  } 
  else {                        // If mouse is not over square,
    fill(0);                      // change color and
    myPort.write('L');              // send an L otherwise
  }
  */
  f += 0.01;
  println(f);
  int i = Float.floatToIntBits(f);
  byte[] bytes = new byte[4];
  bytes[0] = (byte)(i & 0xff);
  bytes[1] = (byte)((i >> 8) & 0xff);
  bytes[2] = (byte)((i >> 16) & 0xff);
  bytes[3] = (byte)((i >> 24) & 0xff);
  myPort.write(bytes);
  rect(50, 50, 100, 100);         // Draw a square
}

boolean mouseOverRect() { // Test if mouse is over square
  return ((mouseX >= 50) && (mouseX <= 150) && (mouseY >= 50) && (mouseY <= 150));
}


