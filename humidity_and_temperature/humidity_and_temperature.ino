#include "DHT.h"
DHT dht(2, DHT22);

void setup()
{
  Serial.begin(9600);
  dht.begin();
}

void loop()
{
  delay(2000);
  float humidity = dht.readHumidity();
  float temperature = dht.readTemperature();
  Serial.print("Humidity: ");
  Serial.print(humidity);
  Serial.print("%");
  Serial.print(" ");
  Serial.print("Temperature: ");
  Serial.print(temperature);
  Serial.print("*C");
  Serial.println();
}
