

class MIUAV {
  ModelGoogleEarth UAV;
  
  public MIUAV(String file, String ModelPth, float Escala) {
    UAV = new ModelGoogleEarth(file, ModelPth, Escala);
  }
  public void update(double longitud, double lat, double alt, float rumbo, float pitch, float bank) {
    UAV.update(longitud, lat, alt, rumbo, -pitch, -bank, (90 + pitch));
    UAV.printfile();
  }
}

