import processing.opengl.*;


String ArchivoKML = 
"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n"+
"<kml xmlns=\"http://www.opengis.net/kml/2.2\" xmlns:gx=\"http://www.google.com/kml/ext/2.2\" xmlns:kml=\"http://www.opengis.net/kml/2.2\" xmlns:atom=\"http://www.w3.org/2005/Atom\">\r\n"+
"<Placemark>\r\n"+
"  <name>Mi GPS</name>\r\n"+
"  <Point>\r\n"+
"    <coordinates>%.14g,%.14g,%.6g</coordinates>\r\n"+
"  </Point>\r\n"+
"</Placemark>\r\n"+
"</kml>\r\n";

double longitud = -15.608013;
double latitud = 27.771523;
float alturametros = 0;
float alturafeets;

void setup() {
  size(200, 200, OPENGL);
  //textSize(64);
  smooth();
  noStroke();
  frameRate(1);
}
void draw() {
  background(0);
  lights();
  textAlign(CENTER); 

  longitud += 0.000001;
  String UAV = String.format(ArchivoKML, longitud, latitud, alturametros);
  System.out.printf(UAV);

  try {

    //    FileOutputStream fos = new FileOutputStream(sketchPath("UAV.kml"));
    //    DataOutputStream dos = new DataOutputStream(fos);
    //    dos.writeBytes(UAV);
    //    fos.close();
    
    File fleExample = new File(sketchPath("UAV.kml"));
    PrintWriter pwInput = new PrintWriter(fleExample);

    // Write a string to the file
    pwInput.println("Francine");
    // Write a string to the file
    pwInput.println("Mukoko");
    // Write a double-precision number to the file
    pwInput.println(22.85);
    // Write a Boolean value to the file
    pwInput.print(true);

    // After using the PrintWriter object, de-allocated its memory
    pwInput.close();
    println("Done.");
  } 
  catch(Exception e) {
    println("Exception: " + e.toString());
  }
}



void keyPressed() {
  switch (key) {
  case 'q':
    exit();
    break;
  }
}

