
#define ADC_PIN A0
#define PIN_PHOTO_SENSOR A0

#define LED_PIN 8

#define Sample_time  20 // in ms

// threshold is 600 (from experiment)
// lower means lighter
#define PHOTP_THRESHOLD 600




int val = 0;
void setup() {
  // put your setup code here, to run once:
  
  Serial.begin(115200); // скорость 115200

  pinMode(LED_PIN, OUTPUT); // установка LED_PIN-го контакта в режим вывода } 

}

void loop() {

  
  val = analogRead(ADC_PIN);


  if ( val < PHOTP_THRESHOLD)
  {
    digitalWrite(LED_PIN, HIGH);
    Serial.write('2');
    
  }
  else
  {
    digitalWrite(LED_PIN, LOW);
    Serial.write('1');
  }
  

  delay(Sample_time);// delay in ms
  
  // put your main code here, to run repeatedly:

}
