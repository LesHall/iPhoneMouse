// by Les Hall
// started Sun Nov 9 2014
// from oscP5 examples
// 


import oscP5.*;
import netP5.*;
import java.awt.*;
import java.awt.event.InputEvent;

OscP5 oscP5;
NetAddress myRemoteLocation;

float mouseRate = 10.0;
PVector gyro = new PVector(0, 0, 0);
float pitch = 0;
float yaw = 0;
float roll = 0;
PVector accel = new PVector(0, 0, 0);
PVector vel = new PVector(0, 0, 0);
PVector dist = new PVector(0, 0, 0);
int numButtons = 9;
boolean[] button = new boolean[9];
PVector mousePos = new PVector(0, 0, 0);
java.awt.Robot robo;

void setup()
{
  size(300, 125, P3D);
  frameRate(25);

  /* start oscP5, listening for incoming messages */
  oscP5 = new OscP5(this, 11000);
  myRemoteLocation = new NetAddress("127.0.0.1",11000);

  // Robot class
  try
  { 
    robo = new java.awt.Robot();
  } 
  catch (AWTException e)
  {
    e.printStackTrace();
  }
}


void draw()
{
  background(0); 
 
  lights();
  camera(0, 0, -(height/2.0) / tan(PI*30.0 / 180.0), 0, 0, 0, 0, -1, 0); 

  // copy the gyro inputs to stabilize them for this draw cycle    
  pitch = gyro.x;
  yaw = gyro.y;
  roll = gyro.z;
  
  // adjust mouse position
  vel.x += accel.x / frameRate;
  vel.y += accel.y / frameRate;
  vel.z += accel.z / frameRate;
  dist.x += vel.x / frameRate;
  dist.y += vel.y / frameRate;
  dist.z += vel.z / frameRate;
  mousePos.x -= mouseRate * yaw;
  mousePos.y -= mouseRate * pitch;
  if (mousePos.x < 0) mousePos.x += displayWidth;
  if (mousePos.x >= displayWidth) mousePos.x -= displayWidth;
  if (mousePos.y < 0) mousePos.y += displayHeight;
  if (mousePos.y >= displayHeight) mousePos.y -= displayHeight;
  
  // send Robot class command to move the mouse!
  robo.mouseMove( int(mousePos.x), int(mousePos.y) );

  // mouse buttons
  if (button[0] == true)
  {
    button[0] = false;
    robo.mousePress(InputEvent.BUTTON1_MASK);
    robo.mouseRelease(InputEvent.BUTTON1_MASK);
  }
  if (button[6] == true)
  {
    button[6] = false;
    robo.mousePress(InputEvent.BUTTON2_MASK);
    robo.mouseRelease(InputEvent.BUTTON2_MASK);
  }
  if (button[3] == true)
  {
    button[3] = false;
    robo.mousePress(InputEvent.BUTTON3_MASK);
    robo.mouseRelease(InputEvent.BUTTON3_MASK);
  }
  
  
  // indicate position
  textSize(24);
  pushMatrix();
    rotateX(PI);
    textAlign(LEFT, CENTER);
    text(str(pitch), 0, -25);
    text(str(yaw), 0, 0);
    text(str(roll), 0, 25);
  popMatrix();
}




/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage)
{
  // grab the gyro data
  String g = "/gyrosc/gyro";
  String a = "/gyrosc/accel";
  String b = "/gyrosc/button";
  if(g.equals(theOscMessage.addrPattern() ) )
  {
    gyro.x = theOscMessage.get(0).floatValue();  // pitch
    gyro.z = theOscMessage.get(1).floatValue();  // roll
    gyro.y = theOscMessage.get(2).floatValue();  // yaw
  }
  else if(a.equals(theOscMessage.addrPattern() ) )
  {
    accel.x = theOscMessage.get(0).floatValue();  // x axis
    accel.y = theOscMessage.get(1).floatValue();  // y axis
    accel.z = theOscMessage.get(2).floatValue();  // z axis
  }
  else if(b.equals(theOscMessage.addrPattern() ) )
  {
    button[theOscMessage.get(0).intValue()-1] = true;
  }
}
