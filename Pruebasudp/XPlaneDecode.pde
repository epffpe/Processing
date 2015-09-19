class XPlaneDecode {
  float[] Times;
  float[] Velocidad;
  float[] MVVIGload;
  float[] Control;
  float[] Gyros;
  float[] Attitude;
  float[] AoA;
  float[] GPS;
  float[] Gases;
  byte[] mensajes;

  public XPlaneDecode() {
    Times = new float[8];
    MVVIGload = new float[8];
    Velocidad = new float[8];
    Control = new float[8];
    Gyros = new float[8];
    Attitude = new float[8];
    AoA = new float[8];
    GPS = new float[8];
    Gases = new float[8];
  }
  public void update(byte[] buffer) {

    String Header = new String( buffer, 0, 4 ).trim();
    byte[] Tag = subset( buffer, 4, 1 );
    if (Header.equals("DATA")) {
      int num_msg = (buffer.length - 5) / 36;
      byte[] refbuffer = subset(buffer, 5, buffer.length - 5);
      //println(Tag);

      for (int seg = 0; seg < num_msg; seg++) {

        mensajes = subset(refbuffer, seg * 36, 36);
        String Ref = extractDataRef(mensajes);

        byte[] variables = subset(mensajes, 4, 32);

        //println(Ref);
        if (Ref.equals("3")) { //Speeds
          for (int i = 0; i<8; i++) {
            byte[] var = subset(variables, i*4, 4);
            Velocidad[i] = var2Float(var);
          }
          //println(" Speed: " + Velocidad[0] + ',' + Velocidad[1] + ',' + Velocidad[2]);
        }
        else if (Ref.equals("1")) { //joystick ail/elev/rud
          for (int i = 0; i<8; i++) {
            byte[] var = subset(variables, i*4, 4);
            Times[i] = var2Float(var);
          }
        }
        else if (Ref.equals("4")) { //joystick ail/elev/rud
          for (int i = 0; i<8; i++) {
            byte[] var = subset(variables, i*4, 4);
            MVVIGload[i] = var2Float(var);
          }
        }
        else if (Ref.equals("8")) { //joystick ail/elev/rud
          for (int i = 0; i<8; i++) {
            byte[] var = subset(variables, i*4, 4);
            Control[i] = var2Float(var);
          }
        }
        else if (Ref.equals("16")) { //angular velocities
          for (int i = 0; i<8; i++) {
            byte[] var = subset(variables, i*4, 4);
            Gyros[i] = var2Float(var);
          }
          //println(" Gyros : " + Float.toString(Gyros[0]) + ',' + Gyros[1] + ',' + Float.toString(Gyros[2]) );
        }
        else if (Ref.equals("17")) { //pitch, roll, headings
          for (int i = 0; i<8; i++) {
            byte[] var = subset(variables, i*4, 4);
            Attitude[i] = var2Float(var);
          }
          //println(" Attitude: " + Float.toString(Attitude[0]) + ',' + Attitude[1] + ',' + Float.toString(Attitude[2]) + ',' + Attitude[3]);
        }
        else if (Ref.equals("18")) { //joystick ail/elev/rud
          for (int i = 0; i<8; i++) {
            byte[] var = subset(variables, i*4, 4);
            AoA[i] = var2Float(var);
          }
        }
        else if (Ref.equals("20")) { //lat, lon, altitude
          for (int i = 0; i<8; i++) {
            byte[] var = subset(variables, i*4, 4);
            GPS[i] = var2Float(var);
          }
        }
        else if (Ref.equals("25")) { //Throttle command
          for (int i = 0; i<8; i++) {
            byte[] var = subset(variables, i*4, 4);
            Gases[i] = var2Float(var);
          }
        }
      }
    }
  }

  public String extractDataRef(byte[] buffer) {
    int byte0 = buffer[0] & 0xFF;
    int byte1 = buffer[1] & 0xFF;
    int byte2 = buffer[2] & 0xFF;
    int byte3 = buffer[3] & 0xFF;
    String DataRef = new String( "" );
    DataRef += Integer.toString(byte0 + (byte1 << 8) + (byte2 << 16) + (byte3 << 24) );
    return DataRef;
  }

  public float var2Float(byte[] varialbe) {
    int byte0 = varialbe[0] & 0xFF;
    int byte1 = varialbe[1] & 0xFF;
    int byte2 = varialbe[2] & 0xFF;
    int byte3 = varialbe[3] & 0xFF;
    //println(byte0);
    return Float.intBitsToFloat(byte0 + (byte1 << 8) + (byte2 << 16) + (byte3 << 24));
  }
  public byte[] float2byte(float var) {
    byte[] result = new byte[4];
    int varint = Float.floatToRawIntBits(var);
    int byte0 = varint & 0xFF;
    int byte1 = (varint>>8) & 0xFF;
    int byte2 = (varint>>16) & 0xFF;
    int byte3 = (varint>>24) & 0xFF;
    result[0] = (byte)byte0;
    result[1] = (byte)byte1;
    result[2] = (byte)byte2;
    result[3] = (byte)byte3;
    return result;
  }
  public float[] readSpeed() {
    return Velocidad;
  }

  public float[] readAttitude() {
    return Attitude;
  }
  public float[] readControl() {
    return Control;
  }
  public float[] readGyros() {
    return Gyros;
  }
  public float[] readGPS() {
    return GPS;
  }
  public float[] readGases() {
    return Gases;
  }
  //************************************************************
  public float Vind_kias() {
    return Velocidad[0];
  }
  public float Vind_keas() {
    return Velocidad[1];
  }
  public float Vtrue_ktas() {
    return Velocidad[2];
  }
  public float Vtrue_ktgs() {
    return Velocidad[3];
  }
  public float Vind_mph() {
    return Velocidad[5];
  }
  public float Vtrue_mphas() {
    return Velocidad[6];
  }  
  public float Vtrue_mphgs() {
    return Velocidad[7];
  }
  //************************************************************

  public float elev() {
    return Control[0];
  }
  public float ailrn() {
    return Control[1];
  }
  public float ruddr() {
    return Control[2];
  }
  //************************************************************

  public float Q() {
    return Gyros[0];
  }
  public float P() {
    return Gyros[1];
  }
  public float R() {
    return Gyros[2];
  }
  //************************************************************

  public float pitch_deg() {
    return Attitude[0];
  }
  public float roll_deg() {
    return Attitude[1];
  }
  public float hding_true() {
    return Attitude[2];
  }
  public float hding_mag() {
    return Attitude[3];
  }
  //************************************************************

  public float lat_deg() {
    return GPS[0];
  }
  public float long_deg() {
    return GPS[1];
  }
  public float alt_ftmsl() {
    return GPS[2];
  }
  public float alt_ftagl() {
    return GPS[3];
  }
  public float on_runwy() {
    return GPS[4];
  }
  public float alt_ind() {
    return GPS[5];
  }
  public float lat_south() {
    return GPS[6];
  }
  public float long_west() {
    return GPS[7];
  }
  //************************************************************

  public float thro1() {
    return Gases[0];
  }
  public float thro2() {
    return Gases[1];
  }
  public float thro3() {
    return Gases[2];
  }
  public float thro4() {
    return Gases[3];
  }
  public float thro5() {
    return Gases[4];
  }
  public float thro6() {
    return Gases[5];
  }
  public float thro7() {
    return Gases[6];
  }
  public float thro8() {
    return Gases[7];
  }
  //************************************************************
  public byte[] joysticControl(float elev, float airln, float rudder) {
    float[] variables = {elev, airln, rudder,-999,-999,-999,-999,-999};
    byte[] variable;
    byte[] result = new byte[41];
    
    result[0] = 'D';
    result[1] = 'A';
    result[2] = 'T';
    result[3] = 'A';
    result[4] = 0;
    result[5] = 8;
    result[6] = 0;
    result[7] = 0;
    result[8] = 0;
    for (int var = 0; var < 8; var++){
      variable = float2byte(variables[var]);
      for (int i = 0; i < 4; i++){
        result[9 + 4*var + i] = variable[i];
      }
    }
    return result;
  }
  
  public byte[] flightControl(float elev, float airln, float rudder) {
    float[] variables = {elev, airln, rudder,-999,-999,-999,-999,-999};
    byte[] variable;
    byte[] result = new byte[41];
    
    result[0] = 'D';
    result[1] = 'A';
    result[2] = 'T';
    result[3] = 'A';
    result[4] = 0;
    result[5] = 11;
    result[6] = 0;
    result[7] = 0;
    result[8] = 0;
    for (int var = 0; var < 8; var++){
      variable = float2byte(variables[var]);
      for (int i = 0; i < 4; i++){
        result[9 + 4*var + i] = variable[i];
      }
    }
    return result;
  }
}

