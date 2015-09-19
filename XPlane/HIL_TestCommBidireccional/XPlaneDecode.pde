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

  public float time_real() {
    return Times[0];
  }
  public float time_totl() {
    return Times[1];
  }
  public float time_missn() {
    return Times[2];
  }
  public float time_timer() {
    return Times[3];
  }
  public float time_zulu() {
    return Times[5];
  }
  public float time_local() {
    return Times[6];
  }
  public float time_hobbs() {
    return Times[7];
  }
  //************************************************************

  public float Mach() {
    return MVVIGload[0];
  }
  public float VVI() {
    return MVVIGload[2];
  }
  public float Gx() {
    return MVVIGload[5];
  }
  public float Gy() {
    return MVVIGload[6];
  }
  public float Gz() {
    return MVVIGload[4];
  }
  //************************************************************

  public float AoA_alpha() {
    return AoA[0];
  }
  public float AoA_beta() {
    return AoA[1];
  }
  public float AoA_hpath() {
    return AoA[2];
  }
  public float AoA_vpath() {
    return AoA[3];
  }
  public float AoA_slip() {
    return AoA[7];
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
  public byte[] SpeedControl(float thro1) {
    float[] variables = {thro1,-999, -999,-999,-999,-999,-999,-999};
    byte[] variable;
    byte[] result = new byte[41];
    
    result[0] = 'D';
    result[1] = 'A';
    result[2] = 'T';
    result[3] = 'A';
    result[4] = 0;
    result[5] = 25;
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
  public byte[] flightSpeedControl(float elev, float airln, float rudder, float thro1) {
    float[] variables = {elev, airln, rudder,-999,-999,-999,-999,-999};
    float[] variables2 = {thro1,-999, -999,-999,-999,-999,-999,-999};
    byte[] variable;
    byte[] result = new byte[77];
    
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
    result[41] = 25;
    result[42] = 0;
    result[43] = 0;
    result[44] = 0;
    for (int var = 0; var < 8; var++){
      variable = float2byte(variables2[var]);
      for (int i = 0; i < 4; i++){
        result[45 + 4*var + i] = variable[i];
      }
    }
    return result;
  }
  public byte[] autopilotmensaje() {
    byte[] mensaje = new byte[64];

    float elevator = elev();
    float alerones = ailrn();
    float ruddr = ruddr();
    float gx = P();
    float gy = Q();
    float gz = R();
    float throttle = thro1();
    float altitud = alt_ftmsl();
    float velocidad = Vind_keas();
    float yaw = AoA_hpath();
    float pitch = pitch_deg();
    float roll = roll_deg();
    float latitud = lat_deg();
    float longitud = long_deg();
    
    mensaje[0] = (byte)0xAA;
    mensaje[1] = (byte)0xAA;
    mensaje[2] = (byte)0xAA;
    mensaje[3] = (byte)0xAA;
    byte[] variable = xplane.float2byte(elevator);
    mensaje[4] = variable[0];
    mensaje[5] = variable[1];
    mensaje[6] = variable[2];
    mensaje[7] = variable[3];
    variable = xplane.float2byte(alerones);
    mensaje[8] = variable[0];
    mensaje[9] = variable[1];
    mensaje[10] = variable[2];
    mensaje[11] = variable[3];
    variable = xplane.float2byte(ruddr);
    mensaje[12] = variable[0];
    mensaje[13] = variable[1];
    mensaje[14] = variable[2];
    mensaje[15] = variable[3];
    variable = xplane.float2byte(gx);
    mensaje[16] = variable[0];
    mensaje[17] = variable[1];
    mensaje[18] = variable[2];
    mensaje[19] = variable[3];
    variable = xplane.float2byte(gy);
    mensaje[20] = variable[0];
    mensaje[21] = variable[1];
    mensaje[22] = variable[2];
    mensaje[23] = variable[3];
    variable = xplane.float2byte(gz);
    mensaje[24] = variable[0];
    mensaje[25] = variable[1];
    mensaje[26] = variable[2];
    mensaje[27] = variable[3];
    variable = xplane.float2byte(throttle);
    mensaje[28] = variable[0];
    mensaje[29] = variable[1];
    mensaje[30] = variable[2];
    mensaje[31] = variable[3];
    variable = xplane.float2byte(altitud);
    mensaje[32] = variable[0];
    mensaje[33] = variable[1];
    mensaje[34] = variable[2];
    mensaje[35] = variable[3];
    variable = xplane.float2byte(velocidad);
    mensaje[36] = variable[0];
    mensaje[37] = variable[1];
    mensaje[38] = variable[2];
    mensaje[39] = variable[3];
    variable = xplane.float2byte(yaw);
    mensaje[40] = variable[0];
    mensaje[41] = variable[1];
    mensaje[42] = variable[2];
    mensaje[43] = variable[3];
    variable = xplane.float2byte(pitch);
    mensaje[44] = variable[0];
    mensaje[45] = variable[1];
    mensaje[46] = variable[2];
    mensaje[47] = variable[3];
    variable = xplane.float2byte(roll);
    mensaje[48] = variable[0];
    mensaje[49] = variable[1];
    mensaje[50] = variable[2];
    mensaje[51] = variable[3];
    variable = xplane.float2byte(latitud);
    mensaje[52] = variable[0];
    mensaje[53] = variable[1];
    mensaje[54] = variable[2];
    mensaje[55] = variable[3];
    variable = xplane.float2byte(longitud);
    mensaje[56] = variable[0];
    mensaje[57] = variable[1];
    mensaje[58] = variable[2];
    mensaje[59] = variable[3];
    mensaje[60] = (byte)0xAA;
    mensaje[61] = (byte)0xAA;
    mensaje[62] = (byte)0xAA;
    mensaje[63] = (byte)0xAA;
    return mensaje;
  }
}

