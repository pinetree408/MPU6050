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
}

void serialEvent(Serial port) {
  interval = millis();
  
  inString = (port.readStringUntil(13));
  
  if (inString != null) {
      result = inString;
  }

}