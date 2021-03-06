#include <avr/wdt.h>

#define RESET_PIN 5

// --------------------------------------------------------------------
void setup()
{
  Serial.begin(57600);
  
  pinMode(RESET_PIN, OUTPUT);
  
  Serial.println("ready");
}

int count = 0;

// --------------------------------------------------------------------
void loop()
{
  Choice(ReadSerialInput());
  
  Serial.println(count);

  count++;

  delay(500);
}

// --------------------------------------------------------------------
void Choice(int input)
{
  switch (input) {
      case 'r':
	reset(1);
        break;
    }
}

// --------------------------------------------------------------------
int ReadSerialInput()
{
  int incomingByte = 0;
  
  incomingByte = Serial.read();
  
  return incomingByte;
}

// --------------------------------------------------------------------
void reset(int reset_delay) 
{
  Serial.println("Device will reset in " + 
                 String(1) +
                 " seconds ...");
  wdt_disable();
  wdt_enable(WDTO_1S);
  while (1) {}
}

