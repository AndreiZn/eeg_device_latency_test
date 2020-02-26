
#define ADC_PIN A0
#define PIN_PHOTO_SENSOR A0

#define LED_PIN 8
#define DOUT1_PIN 7

#define Sample_time  1 // in ms
#define Simulink_sample_time 4
#define Sending_number Simulink_sample_time

// threshold is 600 (from experiment)
// lower means lighter
#define PHOTP_THRESHOLD 600




int val = 0;


int light_mod = 0;

int flag_sending = 0;
int send_count = 0;

char send_char = '1';


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

  int current_light_mod = 0;
  
  val = analogRead(ADC_PIN);

//  sample_count++; 


// switch pins 
  if ( val < PHOTP_THRESHOLD)
  {
    digitalWrite(DOUT1_PIN, HIGH);
    digitalWrite(LED_PIN, HIGH);

    current_light_mod = 1;
   
  }
  else
  {
    digitalWrite(DOUT1_PIN, LOW);
    digitalWrite(LED_PIN, LOW);

    current_light_mod = 0;
  }


  // starting sending  
if (flag_sending == 0)
{
  if (light_mod  != current_light_mod)
  {
     send_count = 0;
     flag_sending = 1;
     
    if (current_light_mod != 0)
    { 
      send_char = '2';
    }
    else 
    {
      send_char = '1';
    }
  } 

}


  if (flag_sending != 0)
  {
    Serial.write(send_char);
    send_count++;
    if (send_count >= Sending_number)
    {
      flag_sending = 0;
      send_char = '0';
      send_count = 0;
    }
  }

  
  light_mod = current_light_mod;
  delay(Sample_time);// delay in ms
  
  // put your main code here, to run repeatedly:

}
