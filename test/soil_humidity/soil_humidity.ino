#define AO A0 //定义AO 引脚 为 IO-A0  
#define DO 7        //定义DO 引脚 为 IO-7  

void setup() {
  // put your setup code here, to run once:
  pinMode(AO, INPUT);
  pinMode(DO, INPUT);
  Serial.begin(9600);
}

void loop() {
  // put your main code here, to run repeatedly:
  Serial.print("Moisture="); 
  Serial.print(analogRead(AO));
  Serial.print(", DO=");    
  Serial.println(digitalRead(DO));  
  delay(500);
}
