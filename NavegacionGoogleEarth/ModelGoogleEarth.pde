class ModelGoogleEarth {
  double longitud;
  double latitud;
  double altura;
  float heading, tilt, roll,tiltView;
  float Scale;
  String fileName;
  String ModelPath;
  String ArchivoKML = 
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n"+
    "<kml xmlns=\"http://www.opengis.net/kml/2.2\" xmlns:gx=\"http://www.google.com/kml/ext/2.2\" xmlns:kml=\"http://www.opengis.net/kml/2.2\" xmlns:atom=\"http://www.w3.org/2005/Atom\">\r\n"+
    "<Document>\r\n"+
    "  <name>KmlFile</name>\r\n"+
    "  <Style id=\"transBluePoly\">\r\n"+
    "      <LineStyle>\r\n"+
    "        <width>1.5</width>\r\n"+
    "      </LineStyle>\r\n"+
    "      <PolyStyle>\r\n"+
    "        <color>7dff0000</color>\r\n"+
    "      </PolyStyle>\r\n"+
    "    </Style>\r\n"+
    "  <Style id=\"default\">\r\n"+
    "  </Style>\r\n"+
    "  <Style id=\"default0\">\r\n"+
    "  </Style>\r\n"+
    "  <StyleMap id=\"default1\">\r\n"+
    "    <Pair>\r\n"+
    "      <key>normal</key>\r\n"+
    "      <styleUrl>#default</styleUrl>\r\n"+
    "    </Pair>\r\n"+
    "    <Pair>\r\n"+
    "      <key>highlight</key>\r\n"+
    "      <styleUrl>#default0</styleUrl>\r\n"+
    "    </Pair>\r\n"+
    "  </StyleMap>\r\n"+
    "  <Placemark>\r\n"+
    "    <name>Model</name>\r\n"+
    "    <LookAt>\r\n"+
    "      <altitudeMode>absolute</altitudeMode>\r\n"+
    "      <longitude>%g</longitude>\r\n"+
    "      <latitude>%g</latitude>\r\n"+
    "      <altitude>%g</altitude>\r\n"+
    "      <heading>%g</heading>\r\n"+
    "      <tilt>%g</tilt>\r\n"+
    "      <range>0</range>\r\n"+
    "    </LookAt>\r\n"+
    "    <styleUrl>#default1</styleUrl>\r\n"+
    "    <Model id=\"model_2\">\r\n"+
    "      <altitudeMode>absolute</altitudeMode>\r\n"+
    "      <Location>\r\n"+
    "        <longitude>%g</longitude>\r\n"+
    "        <latitude>%g</latitude>\r\n"+
    "        <altitude>%g</altitude>\r\n"+
    "      </Location>\r\n"+
    "      <Orientation>\r\n"+
    "        <heading>%g</heading>\r\n"+
    "        <tilt>%g</tilt>\r\n"+
    "        <roll>%g</roll>\r\n"+
    "      </Orientation>\r\n"+
    "      <Scale>\r\n"+
    "        <x>%g</x>\r\n"+
    "        <y>%g</y>\r\n"+
    "        <z>%g</z>\r\n"+
    "      </Scale>\r\n"+
    "      <Link>\r\n"+
    "        <href>%s</href>\r\n"+
    "      </Link>\r\n"+
    "      <ResourceMap>\r\n"+
    "      </ResourceMap>\r\n"+
    "    </Model>\r\n"+
    "  </Placemark>\r\n"+
    "</Document>\r\n"+
    "</kml>\r\n";


  public ModelGoogleEarth(String file, String ModelPth, float Escala) {
    fileName = file;
    ModelPath = ModelPth;
    Scale = Escala;
  }
  
  
  public void update(double longtd, double lat,double alt, float rumbo, float pitch, float bank, float pitchView) {
    longitud = longtd;
    latitud = lat;
    altura = alt;
    heading = rumbo;
    tilt = pitch;
    tiltView = pitchView;
    roll = bank;
  }
  
  
  public void printfile() {
     
    String UAVstr = String.format(ArchivoKML, longitud, latitud, altura, heading, tiltView, longitud, latitud, altura, heading,tilt, roll, Scale, Scale, Scale, ModelPath);
    try {
      File UAVGoogleEarthfile = new File(sketchPath(fileName));
      PrintWriter wrtUAV = new PrintWriter(UAVGoogleEarthfile);
      wrtUAV.println(UAVstr);
      wrtUAV.close();
      //println("Done.");
    } 
    catch(Exception e) {
      println("Exception: " + e.toString());
    }
  }
  
  
}

