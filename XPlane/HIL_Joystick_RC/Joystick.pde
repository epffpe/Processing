import procontroll.*;
import java.io.*;


class Joystick {
//  ControllIO controll;
  ControllDevice device;
//  ControllStick stick;
  ControllButton button;
  private final ControllSlider throtelslider;
  private final ControllSlider xSlider;
  private final ControllSlider ySlider;
  private final ControllSlider zSlider;

  public Joystick(ControllIO controll) {
//    controll = ControllIO.getInstance(this);
    controll.printDevices();
    device = controll.getDevice("Saitek X52 Flight Control System");
//    device.printSliders();
    device.printButtons();
    device.printSticks();
    device.setTolerance(0.05f);

    xSlider = device.getSlider(1);
    ySlider = device.getSlider(0);
    throtelslider = device.getSlider(6);
    zSlider = device.getSlider(2);
//    stick = new ControllStick(sliderX, sliderY);

    button = device.getButton(0);
  }
  
  public float getX(){
    return xSlider.getValue();
  }
  
  public float getY(){
    return ySlider.getValue();
  }
  public float getZ(){
    return zSlider.getValue();
  }
  public float getThrl(){
    return (0.5 - throtelslider.getValue()/2 );
  }
  public void reset(){
    xSlider.reset();
    ySlider.reset();
    zSlider.reset();
    throtelslider.reset();
  }
  public boolean btn1pressed(){
    return button.pressed();
  }
  public float getTolerance(){
    return xSlider.getTolerance();
  }
  
  public void setTolerance(final float i_tolerance){
    xSlider.setTolerance(i_tolerance);
    ySlider.setTolerance(i_tolerance);
  }
  
  public float getMultiplier(){
    return xSlider.getMultiplier();
  }
  
  public void setMultiplier(final float i_multiplier){
    xSlider.setMultiplier(i_multiplier);
    ySlider.setMultiplier(i_multiplier);
  }
}

