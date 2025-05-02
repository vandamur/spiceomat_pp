#include <HX711_ADC.h>

int directionPin = 12;
int pwmPin = 3;
int brakePin = 9;

//HX711 related:
const int HX711_dout = 4; //mcu > HX711 dout pin
const int HX711_sck = 5; //mcu > HX711 sck pin
HX711_ADC LoadCell(HX711_dout, HX711_sck);
const int calVal_eepromAdress = 0;
unsigned long t = 0;
float CURRENT_WEIGHT = 0.0;

//FrontEnd Related:
int MOTOR_NR = 0;
long MOTOR_SPEED = 100;
float TARGET_WEIGHT = 0.0;
int UNDEFINED_b = 0; 

// boolean to switch direction
bool directionRight = true;

// Serial Data  Variables
// SERIAL DATA STRING FORMAT <A,100,1,128> = <MOTOR_NR,MOTOR_SPEED,TARGET_WEIGHT,UNDEFINED_b>
const byte numChars = 32;
char receivedChars[numChars];
char tempChars[numChars]; // temporary array for use when parsing


// boolean to check if new data (from serial / frontend) is available
bool newDataFromFrontEnd = false;

void setup()
{
    Serial.begin(9600); delay(50);

    // ################################ Scale Startup
    LoadCell.begin();
    float calibrationValue; // 
    calibrationValue = -17618.00; //With the container weight // Calibration Value must be generated via Calibration.ino
    // calibrationValue = -17616.20; // Without container weight
    unsigned long stabilizingtime = 2000; // preciscion right after power-up can be improved by adding a few seconds of stabilizing time
    boolean _tare = true; //set this to false if you don't want tare to be performed in the next step
    LoadCell.start(stabilizingtime, _tare);
    if (LoadCell.getTareTimeoutFlag()) {
        Serial.println("Timeout, check MCU>HX711 wiring and pin designations");
        while (1);
    }
    else {
        LoadCell.setCalFactor(calibrationValue); // set calibration value (float)
        Serial.println("Scale Startup complete");
  }
  // ################################## Scale Startup END

}

void loop()
{
    delay(100);

    // ################################ Scale Related START
    static boolean scaleDataReady = false;
    if (LoadCell.update()) scaleDataReady = true;
    // get smoothed value from the dataset:
    if (scaleDataReady) {
        CURRENT_WEIGHT = LoadCell.getData();
        Serial.print("Aktuelles Gewicht: ");
        Serial.print(CURRENT_WEIGHT);
        Serial.print(" g ");

        Serial.print("Ziel-Gewicht: ");
        Serial.print(TARGET_WEIGHT);
        Serial.println(" g");

        scaleDataReady = false;
    }
    // ################################ Scale Related END

    // ################################ FRONTEND RELATED START
    readDataFromSerial();
    if (newDataFromFrontEnd == true)
    {
        strcpy(tempChars, receivedChars);
        // this temporary copy is necessary to protect the original data
        //   because strtok() used in parseData() replaces the commas with \0
        parseData();
        showParsedData();
        newDataFromFrontEnd = false;

        if (MOTOR_SPEED == 0)
        {
            stopMotor();
        }
        else
        {
            startMotor(MOTOR_SPEED);
        }

        
        // Optional?
        // serialEmpty();
        memset(receivedChars, 0, sizeof(receivedChars));
        //memset(MOTOR_NR, 0, sizeof(MOTOR_NR));
    }

    if (CURRENT_WEIGHT >= TARGET_WEIGHT){
        stopMotor();
    }
    // ################################ FRONTEND RELATED END
}

void setMotorDirection()
{
    if (MOTOR_SPEED <0){
        directionRight = false;
    } else {
        directionRight = true;
    }

    // write a low state to the direction pin (13)
    if (directionRight == false)
    {
        Serial.println("Direction = Left");
        digitalWrite(directionPin, LOW);
    }

    // write a high state to the direction pin (13)
    else
    {
        Serial.println("Direction = Right");
        digitalWrite(directionPin, HIGH);
    }
}

void startMotor(int speed)
{

    // If speed is negative, make it positive
    if (speed < 0)
    {
        speed = speed * -1;
    }
    
    Serial.println("Starting motor with speed: " + String(speed));
    // release breaks
    digitalWrite(brakePin, LOW);

    // set work duty for the motor
    analogWrite(pwmPin, speed);
}

void stopMotor()
{
    Serial.println("Stopping motor");
    // activate breaks
    digitalWrite(brakePin, HIGH);

    // set work duty for the motor to 0 (off)
    analogWrite(pwmPin, 0);
}

void readDataFromSerial()
{ // Recieves Serial Data from Matlab or similar
    static bool recvInProgress = false;
    static byte ndx = 0;
    char startMarker = '<';
    char endMarker = '>';
    char rc;

    while (Serial.available() > 0 && newDataFromFrontEnd == false)
    {
        rc = Serial.read();

        if (recvInProgress == true)
        {
            if (rc != endMarker)
            {
                receivedChars[ndx] = rc;
                ndx++;
                if (ndx >= numChars)
                {
                    ndx = numChars - 1;
                }
            }
            else
            {
                receivedChars[ndx] = '\0'; // terminate the string
                recvInProgress = false;
                ndx = 0;
                newDataFromFrontEnd = true;
            }
        }

        else if (rc == startMarker)
        {
            recvInProgress = true;
        }
    }
}

void parseData()
{ // split the data into its parts

    char *strtokIndx; // this is used by strtok() as an index

    // 1st part of the Data, a STRING, a MOTOR_NR chooser (switch case)
    strtokIndx = strtok(tempChars, ","); // get the first part - the string
    MOTOR_NR = atoi(strtokIndx);             // copy it to MOTOR_NR

    // 2nd part of the Data, datatype LONG for the LED_duration
    strtokIndx = strtok(NULL, ",");  // this continues where the previous call left off
    MOTOR_SPEED = atol(strtokIndx); // convert this part to an integer

    // 3rd part of the Data, datatype FLOAT for the TARGET_WEIGHT
    strtokIndx = strtok(NULL, ",");  // this continues where the previous call left off
    TARGET_WEIGHT = atof(strtokIndx); // convert this part to float

    // 4th part of the Data, datatype INTEGER for the UNDEFINED_b
    strtokIndx = strtok(NULL, ","); // this continues where the previous call left off
    int tmp = atoi(strtokIndx);     // convert this part to an integer
    if (tmp == UNDEFINED_b)
    {
    }
    else
    {
        UNDEFINED_b = tmp;
    }
}

void showParsedData()
{ // Shows the recieved Data
    Serial.print("MOTOR_NR: ");
    Serial.println(MOTOR_NR);
    Serial.print("MOTOR_SPEED: ");
    Serial.println(MOTOR_SPEED);
    Serial.print("TARGET_WEIGHT: ");
    Serial.println(TARGET_WEIGHT);
    // Serial.print("UNDEFINED_b: ");
    // Serial.println(UNDEFINED_b);
}
