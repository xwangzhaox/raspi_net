#include "SWTFT.h" // Hardware-specific library
#include "time.h"
#define  BLACK   0x0000
#define BLUE    0x001F
#define RED     0xF800
#define GREEN   0x07E0
#define CYAN    0x07FF
#define MAGENTA 0xF81F
#define YELLOW  0xFFE0
#define WHITE   0xFFFF

SWTFT tft;

String xxx = "xxx";
float new_data[3];
float bbb[3] = {23.53, 34.14};

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
  tft.setTextColor(YELLOW);  tft.setTextSize(2);
  tft.print("Temp and Hum Display");
  tft.print(sizeof(bbb));
  delay(1000);
}

void loop() {
  // put your main code here, to run repeatedly:
  while (Serial.available() > 0) {
    String rx_buffer;
    rx_buffer=Serial.readString();
    int n = sync_th(rx_buffer, "_");
    Serial.print(new_data[1]);
    tft.print(new_data[2]); 
  }
}

int sync_th(String str, const char* spl)
{
    int n = 0;
    char *result = NULL;
    result = strtok(str.c_str(), spl);
    while( result != NULL )
    {
        new_data[n++] = atof(result);
        result = strtok(NULL, spl);
    }
    return n;
}
