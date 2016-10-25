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
float result;
String inString;

float   x_fil;  //Filtered data
float   y_fil;
float   z_fil;

// unit : m
// ex) 1m, 5m
float seasow_height = 1.00;
float seasow_width = 5.00;
float impluse_point;
float delta;
boolean impluse_flag;
String impluse_tag;

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
    impluse_flag = false;

}

void draw() {
  
    if (millis() - interval > 1000) {
        // resend single character to trigger DMP init/start
        // in case the MPU is halted/reset while applet is running
        port.write('r');
        interval = millis();
    }
    
    background(0);
    text("recived: " + result, 10, 70);
    text("impluse: " + delta, 10, 50);
    text("impluse_tag: " + impluse_tag, 10, 30);
}

void serialEvent(Serial port) {
  
  inString = port.readStringUntil(13);
  
  if (inString != null) {
    
    String[] inList = inString.split("#");
    
    if (inList.length == 2) {
    
      float time = float((inList[0].split(":"))[1]); 
      float angle = float((inList[1].split(":"))[1]);
      
      if ((abs(angle) - impluse_point) > 0){
        if (impluse_flag == false) {
          delta = (angle - result) / time;
          int tag = int(abs(delta));
          if (tag < 50) {
            impluse_tag = "1";
          } else if ((50 <= tag) && (tag < 100)) {
            impluse_tag = "2";
          } else if ((100 <= tag) && (tag < 150)) {
            impluse_tag = "3";
          } else if ((150 <= tag) && (tag < 200)) {
            impluse_tag = "4";
          } else if ((200 <= tag) && (tag < 250)) {
            impluse_tag = "5";
          } else if ((250 <= tag) && (tag < 300)) {
            impluse_tag = "6";
          }
          
          impluse_flag = true;
        }
      } else {
        delta = 0;
        impluse_tag = "0";
        impluse_flag = false;
      }
    
      result = angle;
    
    }
  }

}