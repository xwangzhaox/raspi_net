//#include <Adafruit_GFX.h>    // Core graphics library
#include "SWTFT.h" // Hardware-specific library

// Assign human-readable names to some common 16-bit color values:
#define	BLACK   0x0000
#define	BLUE    0x001F
#define	RED     0xF800
#define	GREEN   0x07E0
#define CYAN    0x07FF
#define MAGENTA 0xF81F
#define YELLOW  0xFFE0
#define WHITE   0xFFFF

SWTFT tft;

int x,y; //声明坐标
float tArr[31] = {0.39, 23.6, 28.4, 38.5, 10.3, -10.4, 5.3, -13.4, 23.4, 23.6, 28.4, 38.5, 10.3, -10.4, 5.3, -13.4, 23.4, 23.6, 28.4, 38.5, 10.3, -10.4, 5.3, -13.4, 23.4, 23.6, 28.4, 38.5, 10.3, 1.56, 1.56};
float hArr[31] = {0.72, 50.6, 35.4, 80.7, 98.8 ,67.8, 59.4, 62.3, 72.6, 52.6, 68.3, 50.6, 35.4, 80.7, 98.8 ,67.8, 59.4, 62.3, 72.6, 52.6, 68.3, 50.6, 35.4, 80.7, 98.8 ,67.8, 59.4, 62.3, 72.6, 99, 99};
float new_data[3];
//enmu type ["t", "h", "gt", "gh"]

void setup(void) {
  Serial.begin(9600);
  Serial.println(F("TFT LCD test"));

  tft.reset();

  uint16_t identifier = tft.readID();

  
    Serial.print(F("LCD driver chip: "));
    Serial.println(identifier, HEX);
    

  tft.begin(identifier);

  tft.setRotation(1);

  drawBaseChart();
  drawChartLine();

  delay(1000);
  Serial.println(F("Done!"));
}

void loop(void) {

//  Got T and H
  while (Serial.available() > 0) {
    int timeLocation = 0;
    float wx = (tft.width()-40)/31;
    String th_data;
    th_data = Serial.readString();
    sync_th(th_data, "_");

    if(tArr[30]!=0.00){
      // 当数组满长度的情况下,所有元素前移,最后一位改成新的数据
      for(int i=0; i<=sizeof(tArr)/4-1; i++){
        tArr[i] = tArr[i+1];
        hArr[i] = hArr[i+1];
      }
      tArr[30] = new_data[0];
      hArr[30] = new_data[1];
      timeLocation = tft.width() - 27;
    }else{
      // 当数组不满长度,最后一个0.00的位置改为新值
      timeLocation = modifyLastElement(tArr, new_data[0])+ 8 + wx;  
      timeLocation = modifyLastElement(hArr, new_data[1])+ 8 + wx;
    }
    drawBaseChart();
    drawChartLine();

    // X 轴刻度同步
    tft.setCursor(timeLocation-5, tft.height()-15);
    char string[25];  
    tft.print( strcat(itoa(new_data[2], string, 10), ":00") );
    int xPoint = (int)timeLocation-new_data[2]*wx+2;
    tft.setCursor(xPoint-13, tft.height()-15);
    tft.print("00:00");
    tft.drawLine(xPoint, 16, xPoint, tft.height()-16, BLUE);
    int leftXTime = sizeof(tArr)/4 -1 - (int)new_data[2];
    if(leftXTime>=24)
      leftXTime -= 24;
    tft.setCursor(18, tft.height()-15);
    char str[25];
    tft.print( strcat(itoa(leftXTime, str, 10), ":00") );
  }
  
//        tft.setCursor(width-35, height-15);
//        tft.print("24:00");
//        int times = 0;
//        for(int x=29;x<width-20;x+=9)
//        {
//          if(currentHour-24>0)
//            currentHour += 24;
//          times++;
//          if(times==7){
//            tft.drawLine(x, 15, x, height-18, BLUE);
//            tft.setCursor(x-15, height-15);
//            tft.print("%d:00",currentHour-times);
//          }
//          if(times==19){
//            tft.drawLine(x, 15, x, height-18, BLUE);
//            tft.setCursor(x-15, height-15);
//            tft.print("%d:00",currentHour-times);
//          }
//        }
//      }// end else
//    }// end if
//  init type
}

void drawChartLine(){
  int x = 25;
  int width = tft.width();
  float wx = (width-40)/31;
  float thx = (tft.height() - 30) / 80;
  float hhx = (tft.height() - 30) / 100;
  for(int i=0;i<sizeof(tArr)/4-1;i++){
    // T Lins
      // current point y
      float tH = 15 + (50 - tArr[i]) * thx;
      // next point y
      float tHn = 15 + (50 - tArr[i+1]) * thx;
      tft.drawLine(x+i*wx, tH, x+(i+1)*wx, tHn, WHITE);
      tft.drawPixel(x+i*wx, tH,YELLOW);
    // H Lines
      float hH  = 15 + (100 - hArr[i]) * hhx;
      float hHn = 15 + (100 - hArr[i+1]) * hhx;
      tft.drawLine(x+i*wx, hH, x+(i+1)*wx, hHn, CYAN);
      tft.drawPixel(x+i*wx, hH,YELLOW);
    }
  tft.setTextSize(1);
  tft.fillRect(width-60, 1, 15, 10, WHITE);
  tft.setTextColor(WHITE);
  tft.setCursor(width-43, 3);
  tft.print("T");
  tft.fillRect(width-30, 1, 15, 10, CYAN);
  tft.setTextColor(CYAN);
  tft.setCursor(width-12, 3);
  tft.print("H");
}

//显示
void drawBaseChart()  
{ 
  int width = tft.width();
  int height = tft.height();
  tft.fillScreen(BLACK);
  // Title
  tft.setCursor(100, 3);
  tft.setTextColor(YELLOW);  tft.setTextSize(1);
  tft.print("Temp and Hum Display");
  // T 刻度
  tft.setTextColor(WHITE);  tft.setTextSize(1);
  tft.setCursor(1, 15);
  tft.print("50");
  tft.setCursor(1, height/2-4);
  tft.print("0");
  tft.setCursor(1, height-15-8);
  tft.print("-50");
  // H 刻度
  tft.setCursor(width-20, 15);
  tft.print("100");
  tft.setCursor(width-20, height/2-4);
  tft.print("50");
  tft.setCursor(width-20, height-15-8);
  tft.print("0");
  // 中横线
  tft.drawLine(26, height/2, width-30, height/2, BLUE);

  int l = -1;
  for (int i=34; i<width-30; i+=9)//画坐标轴刻度 
  {
    l++;
    if(l%3==0){
      tft.drawLine(i, (height/2-5), i, (height/2+2), BLUE);
      tft.drawLine(i, (height-25), i, (height-18), BLUE);
    }else{
      tft.drawLine(i, (height/2-2), i, (height/2+2), WHITE);
      tft.drawLine(i, (height-22), i, (height-18), WHITE);
    }

  }

  tft.drawRect(25, 14, width-48, height-30, YELLOW);//画边框（矩形函数）
  //画网格
  for(int x=34;x<width-30;x+=9)
  {
    for(int y=18;y<height-20;y+=10)
      tft.drawPixel(x,y,WHITE);
  }
}

void sync_th(String str, const char* spl)
{
    int n = 0;
    char *result = NULL;
    result = strtok(str.c_str(), spl);
    while( result != NULL )
    {
        new_data[n++] = atof(result);
        result = strtok(NULL, spl);
    }
}

int modifyLastElement(float *arr, float data)
{
  int j;
  for(int i=31; i>0; i--){
//    Serial.println(arr[i]);
    if(*(arr+i)==0.00){
      j = i;
    }else{
      *(arr+j) = data;
      break;
    }
  }
  return (31-j);
}
