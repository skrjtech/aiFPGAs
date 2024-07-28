unsigned char input_char;
unsigned char pre_inp;
bool highlow;
void setup() {
  Serial.begin(115200);
  Serial.println("Init");
  for (int i = 2; i <= 9; i++) pinMode(i, OUTPUT);
}

void loop() {
  if(Serial.available() > 0){
    input_char = Serial.read();
    Serial.println((unsigned int)input_char);
    pre_inp = input_char;
    for (int i = 2; i <= 9; i++) {
      highlow = pre_inp & 1;
      pre_inp = pre_inp >> 1;
      digitalWrite(i, highlow);
    }
  }
}