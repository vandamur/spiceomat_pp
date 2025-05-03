#include <ArduinoBLE.h>
#include <HX711_ADC.h>

// TODO:
// 1. Add a function that decreases the motor speed slowly to 30%, when 80% of the target weight is reached.
// 2. Add calibration process to the code.

// HX711 (scale) related
const int HX711_dout = 4; // mcu > HX711 dout pin
const int HX711_sck = 5;  // mcu > HX711 sck pin
HX711_ADC LoadCell(HX711_dout, HX711_sck);
float CURRENT_WEIGHT = 0.0;
float calibrationValue = 0.0;

// FrontEnd Related:
float TARGET_WEIGHT = -10.0;
int TARGET_MOTOR_SPEED = 255; // currently hard coded to max speed
bool spiceomat_is_running = false;

// MOTOR related:
int CURRENT_MOTOR_SPEED = 0;
int pwmPin = 3;

int mode = 0;
// mode 0 = stop motor
// mode 1 = normal operation
// mode 2 = tare scale (takes 2-3 seconds)
// mode 3 = calibrate scale

// --- Define BLE Service and Characteristics ---
// Use the same UUIDs as in your Flutter app  (Nordic UART Service - NUS)
BLEService uartService("6E400001-B5A3-F393-E0A9-E50E24DCCA9E");

// Create TX Characteristic (Transmit from Flutter app to Arduino)
BLECharacteristic txCharacteristic("6E400002-B5A3-F393-E0A9-E50E24DCCA9E",
                                   BLEWriteWithoutResponse | BLEWrite, // Allow write properties
                                   20);                                // Maximum data length (adjust if needed)

// Create RX Characteristic (Flutter app receives data from Arduino)
BLECharacteristic rxCharacteristic("6E400003-B5A3-F393-E0A9-E50E24DCCA9E",
                                   BLERead | BLENotify, // Allow read and notify properties
                                   20);                 // Maximum data length (adjust if needed)

void setup()
{
  // Initialize Serial communication for debugging messages
  Serial.begin(9600);
  delay(100);

  setupScale();
  setupBluetooth();
}

// --- Loop Function ---
void loop()
{
  delay(50); // optional?

  // Continuously poll for BLE events (connections, disconnections, data)
  // This is CRUCIAL for the BLE stack to function.
  BLE.poll();

  // ################################ MOTOR RELATED START
  // If the current weight is above 0.4*TARGET_WEIGHT, slow down the motor to 50% of TARGET_MOTOR_SPEED
  if (CURRENT_WEIGHT >= 0.4 * TARGET_WEIGHT && spiceomat_is_running == true)
  {
    // Slow down the motor to 50% of TARGET_MOTOR_SPEED
    int newSpeed = TARGET_MOTOR_SPEED * 0.5;
    startMotor(newSpeed);
  }

  if (CURRENT_WEIGHT >= 0.9*TARGET_WEIGHT)
  {
    stopMotor();
  }
  if (CURRENT_WEIGHT < TARGET_WEIGHT && CURRENT_MOTOR_SPEED == 0 && spiceomat_is_running == true)
  {
    startMotor(TARGET_MOTOR_SPEED);
  
  }
  // ################################ MOTOR RELATED END

  // ################################ Scale Related START
  static boolean scaleDataReady = false;
  if (LoadCell.update())
    scaleDataReady = true;
  // get smoothed value from the dataset:
  if (scaleDataReady)
  {
    CURRENT_WEIGHT = LoadCell.getData();
    scaleDataReady = false;

    // Send CURRENT_WEIGHT, which is already a String, to the RX characteristic
    String weightString = String(CURRENT_WEIGHT);
    rxCharacteristic.writeValue(weightString.c_str(), weightString.length());

    // Print the weight to Serial Monitor for debugging
    Serial.print("Weight: ");
    Serial.print(CURRENT_WEIGHT);
    Serial.println(" g");
  }
  // ################################ Scale Related END
}

// --- Callback Function ---
// This function is called when the flutter app sends data over Bluetooth
void onFrontEndSentData(BLEDevice central, BLECharacteristic characteristic)
{

  // Get the data from flutter app via Bluetooth
  int len = characteristic.valueLength();       // Get the length of the data received
  const uint8_t *data = characteristic.value(); // Get a pointer to the data buffer

  // The incoming data is a String in the format "<mode;target_weight>" including the <> brackets
  String incomingData = "";
  for (int i = 0; i < len; i++)
  {
    incomingData += (char)data[i]; // Convert the data to a String
  }
  Serial.print("Received data: ");
  Serial.println(incomingData);
  // Parse the incoming data
  int separatorIndex = incomingData.indexOf(';');
  float recievedWeightParameter = 0.0; // Initialize the received weight parameter
  if (separatorIndex != -1)
  {
    String modeString = incomingData.substring(1, separatorIndex); // Extract the mode
    String targetWeightString = incomingData.substring(separatorIndex + 1, incomingData.length() - 1); // Extract the target weight

    // Convert the strings to integers
    mode = modeString.toInt();
    recievedWeightParameter = targetWeightString.toFloat();
    Serial.print("Recieved Mode: ");
    Serial.println(mode);
    Serial.print("Recieved Target Weight: ");
    Serial.println(recievedWeightParameter);


  }
  else
  {
    Serial.println("Invalid data format received");
  }
  // Handle the mode
  switch (mode)
  {
  case 0: // Stop motor
    stopMotor();
    break;
  case 1: // Normal operation

    TARGET_WEIGHT = recievedWeightParameter;
    spiceomat_is_running = true;
    break;
  case 2: // Tare scale
    Serial.println("Taring scale...");
    LoadCell.tare(); // Tare the scale
    Serial.println("Tare complete");
    break;
  case 3: // Calibrate scale
    calibrateScale(recievedWeightParameter); // Call the calibration function
    break;
  default:
    Serial.println("Invalid mode selected");
    break;
  }
}

void startMotor(int speed)
{
  // set work duty for the motor
  analogWrite(pwmPin, speed);
  CURRENT_MOTOR_SPEED = speed;
}

void stopMotor()
{
  // set work duty for the motor to 0 (off)
  analogWrite(pwmPin, 0);
  CURRENT_MOTOR_SPEED = 0;
  spiceomat_is_running = false; // Reset the flag to prevent immediate restart
}

void setupScale()
{
  LoadCell.begin();

  calibrationValue = -17618.00; // should not be hard coded, but calibrated every startup

  unsigned long stabilizingtime = 2000; // precision right after power-up can be improved by adding a few seconds of stabilizing time
  boolean _tare = true;                 // set this to false if you don't want tare to be performed in the next step
  LoadCell.start(stabilizingtime, _tare);
  if (LoadCell.getTareTimeoutFlag())
  {
    Serial.println("Timeout, check MCU>HX711 wiring and pin designations");
    while (1)
      ;
  }
  else
  {
    LoadCell.setCalFactor(calibrationValue); // set calibration value (float)
    Serial.println("Scale Startup complete");
  }
}

void calibrateScale(float known_mass)
{
  Serial.println(" Calibration not implemented yet");
  Serial.print("known_mass: ");
  Serial.println(known_mass);
  // Serial.println("Starting calibration...");

  // delay(2000);
  // float known_mass = 10.0; // known calibration mass in grams
  // LoadCell.tare();
  //   //place known mass
  // LoadCell.refreshDataSet(); //refresh the dataset to be sure that the known mass is measured correct
  // float newCalibrationValue = LoadCell.getNewCalibration(known_mass); //get the new calibration value

  // Serial.print("New calibration value: ");
  // Serial.println(newCalibrationValue);
  // calibrationValue = newCalibrationValue; // Store the calibration value for later use
}

void setupBluetooth()
{
  // Initialize the BLE library
  if (!BLE.begin())
  {
    Serial.println("Starting BLE failed!");
    // Don't continue execution if BLE initialization fails
    while (1)
      ;
  }

  Serial.println("BLE Initialized");

  // Set the advertised local name and service UUID
  BLE.setLocalName("Spiceomat"); // Name that appears during scanning
  BLE.setAdvertisedService(uartService);

  // Add the characteristics to the service
  uartService.addCharacteristic(txCharacteristic);
  uartService.addCharacteristic(rxCharacteristic);

  // Add the service to the BLE stack
  BLE.addService(uartService);

  // Assign a callback function when data is written to the TX characteristic
  txCharacteristic.setEventHandler(BLEWritten, onFrontEndSentData);

  // Start advertising
  BLE.advertise();
  Serial.println("Bluetooth device active, waiting for connections...");
}
