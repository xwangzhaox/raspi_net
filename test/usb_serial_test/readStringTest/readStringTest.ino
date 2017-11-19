

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
}

void loop() {
  // put your main code here, to run repeatedly:
  while(Serial.available()>0) {
  String a;
  a= Serial.readString();// read the incoming data as string
  
  Serial.println(a);
  
  }
}
