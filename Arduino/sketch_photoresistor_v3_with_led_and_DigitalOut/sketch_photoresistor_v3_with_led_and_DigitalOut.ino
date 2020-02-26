
#define ADC_PIN A0
#define PIN_PHOTO_SENSOR A0

#define LED_PIN 8
#define DOUT1_PIN 7

#define Sample_time  1 // in ms
#define Sample_number  50 

// threshold is 600 (from experiment)
// lower means lighter
#define PHOTP_THRESHOLD 600




int val = 0;
int sample_count = 0;

void setup() {
  // put your setup code here, to run once:
  
  Serial.begin(115200); // скорость 115200

  pinMode(LED_PIN, OUTPUT); // установка LED_PIN-го контакта в режим вывода
  pinMode(DOUT1_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW);
  digitalWrite(DOUT1_PIN, LOW);

  Serial.write('1');


}

void loop() {

  
  val = analogRead(ADC_PIN);

  sample_count++; 

  if ( val < PHOTP_THRESHOLD)
  {
    digitalWrite(DOUT1_PIN, HIGH);
    digitalWrite(LED_PIN, HIGH);

    if (sample_count >= Sample_number)
    {
       Serial.write('2');
       sample_count = 0;
    }
    
  }
  else
  {
    digitalWrite(DOUT1_PIN, LOW);
    digitalWrite(LED_PIN, LOW);

        if (sample_count >= Sample_number)
    {
       Serial.write('1');
       sample_count = 0;
    }
  }
  

  delay(Sample_time);// delay in ms
  
  // put your main code here, to run repeatedly:

}
