import processing.serial.Serial;

Serial port;                         // The serial port
char[] packet = new char[14];  // packet
int serialCount = 0;                 // current packet byte position
int aligned = 0;
int interval = 0;

float[] q = new float[4];

float[] gravity = new float[3];
float[] euler = new float[3];
float[] ypr = new float[3];

PFont myFont;
String result;
String  inString;

float   x_fil;  //Filtered data
float   y_fil;
float   z_fil;

// unit : m
// ex) 1m, 5m
float seasow_height = 1.00;
float seasow_width = 5.00;
float impluse_point;
float delta;
int delta_interval = 0;

void setup() {

    size(700, 300);
    
    myFont = createFont("Lucida Sans", 12);
    textFont(myFont, 12);
  
    // get a specific serial port
    // for mac : String portName = "/dev/ttyUSB1";
    String portName = "COM3";
    
    // open the serial port
    port = new Serial(this, portName, 19200);
    
    // send single character to trigger DMP init/start
    port.write('r');
    impluse_point = acos(seasow_height/seasow_width)*180/3.14159;

}

void draw() {
  
    if (millis() - interval > 1000) {
        // resend single character to trigger DMP init/start
        // in case the MPU is halted/reset while applet is running
        port.write('r');
        interval = millis();
    }
    
    background(0);
    text("recived: " + result, 10, 50);
    text("impluse: " + delta, 10, 30);
}

void serialEvent(Serial port) {
  interval = millis();
  
  inString = (port.readStringUntil(13));
  
  if (inString != null) {
      if (abs(abs(float(inString)) - impluse_point) < 2){
          int caculate = millis();
          println(caculate, delta_interval);
          delta = (float(inString) - float(result)) / (caculate - delta_interval);
          delta_interval = caculate;
      }  
      result = inString;
  }

}