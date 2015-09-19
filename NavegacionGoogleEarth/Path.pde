class Path{
  String fileName;
  double longitud;
  double latitud;
  double altura;
  float heading, tilt, range;
  String trayecto;
  String ArchivoKML = 
"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n"+
"<kml xmlns=\"http://www.opengis.net/kml/2.2\" xmlns:gx=\"http://www.google.com/kml/ext/2.2\" xmlns:kml=\"http://www.opengis.net/kml/2.2\" xmlns:atom=\"http://www.w3.org/2005/Atom\">\r\n"+
"<Document>\r\n"+
"  <name>Recorrido</name>\r\n"+
"  <Style id=\"sh_ylw-pushpin\">\r\n"+
"    <IconStyle>\r\n"+
"      <scale>1.3</scale>\r\n"+
"      <Icon>\r\n"+
"        <href>http://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png</href>\r\n"+
"      </Icon>\r\n"+
"      <hotSpot x=\"20\" y=\"2\" xunits=\"pixels\" yunits=\"pixels\"/>\r\n"+
"    </IconStyle>\r\n"+
"    <LineStyle>\r\n"+
"      <color>7f00ffff</color>\r\n"+
"      <width>4</width>\r\n"+
"    </LineStyle>\r\n"+
"    <PolyStyle>\r\n"+
"      <color>7f00ff00</color>\r\n"+
"    </PolyStyle>\r\n"+
"  </Style>\r\n"+
"  <StyleMap id=\"msn_ylw-pushpin\">\r\n"+
"    <Pair>\r\n"+
"      <key>normal</key>\r\n"+
"      <styleUrl>#sn_ylw-pushpin</styleUrl>\r\n"+
"    </Pair>\r\n"+
"    <Pair>\r\n"+
"      <key>highlight</key>\r\n"+
"      <styleUrl>#sh_ylw-pushpin</styleUrl>\r\n"+
"    </Pair>\r\n"+
"  </StyleMap>\r\n"+
"  <Style id=\"sn_ylw-pushpin\">\r\n"+
"    <IconStyle>\r\n"+
"      <scale>1.1</scale>\r\n"+
"      <Icon>\r\n"+
"        <href>http://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png</href>\r\n"+
"      </Icon>\r\n"+
"      <hotSpot x=\"20\" y=\"2\" xunits=\"pixels\" yunits=\"pixels\"/>\r\n"+
"    </IconStyle>\r\n"+
"    <LineStyle>\r\n"+
"      <color>7f00ffff</color>\r\n"+
"      <width>4</width>\r\n"+
"    </LineStyle>\r\n"+
"    <PolyStyle>\r\n"+
"      <color>7f00ff00</color>\r\n"+
"    </PolyStyle>\r\n"+
"  </Style>\r\n"+
"  <Placemark>\r\n"+
"    <name>Prueba1</name>\r\n"+
"    <LookAt>\r\n"+
"      <longitude>%g</longitude>\r\n"+
"      <latitude>%g</latitude>\r\n"+
"      <altitude>%g</altitude>\r\n"+
"      <heading>%g</heading>\r\n"+
"      <tilt>%g</tilt>\r\n"+
"      <range>%g</range>\r\n"+
"      <gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode>\r\n"+
"    </LookAt>\r\n"+
"    <styleUrl>#msn_ylw-pushpin</styleUrl>\r\n"+
"    <LineString>\r\n"+
"      <extrude>1</extrude>\r\n"+
"      <tessellate>1</tessellate>\r\n"+
"      <altitudeMode>absolute</altitudeMode>\r\n"+
"      <coordinates>\r\n"+
"        %s\r\n"+
"      </coordinates>\r\n"+
"    </LineString>\r\n"+
"  </Placemark>\r\n"+
"</Document>\r\n"+
"</kml>\r\n";
 public Path(String file, double longtd, double lat,double alt, float rumbo, float pitch, float rango) {
     fileName = file;
    longitud = longtd;
    latitud = lat;
    altura = alt;
    heading = rumbo;
    range = rango;
    tilt = pitch;
    trayecto = new String("");
 }
 public void addPath(double longtd, double lat,double alt){
   String nuevaPosicion = String.format("%g,%g,%g ", longtd, lat, alt);
   trayecto = trayecto + nuevaPosicion;
   
   String UAVpath = String.format(ArchivoKML, longitud, latitud, altura, heading, tilt, range,trayecto);
   try {
      File PATHGoogleEarthfile = new File(sketchPath(fileName));
      PrintWriter wrtPATH = new PrintWriter(PATHGoogleEarthfile);
      wrtPATH.println(UAVpath);
      wrtPATH.close();
      //println("Done.");
    } 
    catch(Exception e) {
      println("Exception: " + e.toString());
    }   
 }
 
 public void resetPath(){
   trayecto = new String("");
 }
 
}
