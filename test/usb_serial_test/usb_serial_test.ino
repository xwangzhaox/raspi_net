#include "SWTFT.h" // Hardware-specific library
#define  BLACK   0x0000
#define BLUE    0x001F
#define RED     0xF800
#define GREEN   0x07E0
#define CYAN    0x07FF
#define MAGENTA 0xF81F
#define YELLOW  0xFFE0
#define WHITE   0xFFFF

SWTFT tft;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  Serial.println(F("TFT LCD test"));

  tft.reset();

  uint16_t identifier = tft.readID();

  
    Serial.print(F("LCD driver chip: "));
    Serial.println(identifier, HEX);
    

  tft.begin(identifier);

  tft.setRotation(1);

  tft.fillScreen(BLACK);
  // Title
  tft.setCursor(100, 3);
  tft.setTextColor(YELLOW);  tft.setTextSize(1);
  tft.print("Temp and Hum Display");
  
  delay(1000);
  Serial.println(F("Done!"));
}

void loop() {
  // put your main code here, to run repeatedly:
  String rx_buffer;
  rx_buffer=Serial.readString();
  Serial.print(rx_buffer);
  tft.print(rx_buffer);
}
