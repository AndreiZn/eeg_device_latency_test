
#define ADC_PIN A0
#define PIN_PHOTO_SENSOR A0
int val = 0;
void setup() {
  
  // put your setup code here, to run once:
  Serial.begin(115200); // скорость 115200

}

void loop() {

  val = analogRead(ADC_PIN);
  Serial.print("val = ");
  Serial.println(val);
  delay(10);// delay in ms
  
  // put your main code here, to run repeatedly:

}
