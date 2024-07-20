#include <SoftwareSerial.h>
#include <DHT11.h>
DHT11 dht11(2);

SoftwareSerial mySerial(7, 8); // RX, TX  
// Connect HM10      Arduino Uno
//     Pin 1/TXD          Pin 7
//     Pin 2/RXD          Pin 8

void setup() {  
  Serial.begin(9600);
  // If the baudrate of the HM-10 module has been updated,
  // you may need to change 9600 by another value
  // Once you have found the correct baudrate,
  // you can update it using AT+BAUDx command 
  // e.g. AT+BAUD0 for 9600 bauds
  mySerial.begin(9600);
}

void loop() {  

  int temperature = dht11.readTemperature();

  delay(2000);

  Serial.print("Temperature: ");
  Serial.print(temperature);
  Serial.println(" ºC ");
  mySerial.write(temperature);
}



