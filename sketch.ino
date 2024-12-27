#include "WiFi.h"
#include "ThingSpeak.h"
#include "DHTesp.h"
#include <Wire.h>
#include <LiquidCrystal.h>

#define PIN_SEN0161 0 // pH sensor
#define PIN_MQ135 1 // Gas Sensor
#define PIN_DHT22 2 // Temperature and Humidity Sensor
#define PIN_SEN0189 3 // Turbidity Sensor

#define WIFI_NETWORK "Wokwi-GUEST"
#define WIFI_PASSWORD ""

#define CHANNEL_ID 2794853
#define CHANNEL_API_KEY "QVPH0B1OX2U5H78L"

// Define LCD pins
LiquidCrystal lcd(4, 5, 6, 7, 8, 9);

WiFiClient client;
DHTesp dhtSensor;

void connectToWiFi() {
    Serial.println("Connecting to WiFi");
    WiFi.mode(WIFI_STA);
    WiFi.begin(WIFI_NETWORK, WIFI_PASSWORD);
    for (char i = 0; WiFi.status() != WL_CONNECTED && i <= 50; i++) {
        delay(500);
    }
    if (WiFi.status() != WL_CONNECTED) {
        Serial.println("Failed to connect to WiFi!");
        Serial.println("Shutting Down");
        exit(1);
    }
    Serial.println("Connected");
    Serial.println(WiFi.localIP());
}

String categorizeAirQuality(float air_quality) {
    if (air_quality < 50)
        return "Excellent";
    else if (air_quality < 100)
        return "Good";
    else if (air_quality < 150)
        return "Moderate";
    else if (air_quality < 200)
        return "Poor";
    else if (air_quality < 300)
        return "Very Bad";
    else
        return "Hazardous";
}

String categorizeWaterQuality(float pH, float ntu) {
    if ((pH >= 6.5 && pH <= 7.5) && (ntu <= 1)) {
        return "Excellent";
    } else if ((pH >= 6.0 && pH <= 8.0) && (ntu <= 5)) {
        return "Good";
    } else if ((pH >= 5.5 && pH <= 8.5) && (ntu <= 10)) {
        return "Moderate";
    } else if ((pH >= 5.0 && pH <= 9.0) && (ntu <= 50)) {
        return "Poor";
    } else {
        return "Very Bad";
    }
}

void setup() {
    Serial.begin(115200);
    Serial.println("Hello, ESP32-C3!");

    dhtSensor.setup(PIN_DHT22, DHTesp::DHT22);

    lcd.begin(16, 2); // Initialize the LCD (16 columns, 2 rows)
    lcd.print("Hello, ESP32!");
    delay(2000);
    lcd.clear();

    connectToWiFi();
    ThingSpeak.begin(client);
}

void loop() {
    float temperature = dhtSensor.getTemperature();
    float humidity = dhtSensor.getHumidity();

    float pH = map(analogRead(PIN_SEN0161), 0, 4095, 0.0, 14.0); // Map analog reading to pH range 0-14
    float turbidity_sensor_voltage = analogRead(PIN_SEN0189) * (5.0 / 4095.0);
    float air_quality = map(analogRead(PIN_MQ135), 0, 4095, 0, 500);
    float ntu = -1000.0 * turbidity_sensor_voltage + 4500.0;
    ntu = ntu > 0 ? ntu : 0;

    String air_quality_category = categorizeAirQuality(air_quality);
    String water_quality_category = categorizeWaterQuality(pH, ntu);

    // Serial output
    Serial.print("Air Temperature: ");
    Serial.print(temperature);
    Serial.println(" C");
    Serial.print("Humidity: ");
    Serial.print(humidity);
    Serial.println(" %");
    Serial.print("AQI: ");
    Serial.println(air_quality);
    Serial.print("Air Quality: ");
    Serial.println(air_quality_category);
    Serial.print("pH: ");
    Serial.println(pH);
    Serial.print("Turbidity: ");
    Serial.print(ntu);
    Serial.println(" NTU");
    Serial.print("Water Quality: ");
    Serial.println(water_quality_category);

    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Temp: ");
    lcd.print(temperature);
    lcd.print(" C");

    lcd.setCursor(0, 1);
    lcd.print("Humidity: ");
    lcd.print(humidity);
    lcd.print("%");


    delay(5000);


    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("pH: ");
    lcd.print(pH);
    lcd.print("");

    lcd.setCursor(0, 1);
    lcd.print("Turb: ");
    lcd.print(ntu);
    lcd.print(" NTU");
    

    delay(5000);
  

    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("AirQ: ");
    lcd.print(air_quality_category);

    lcd.setCursor(0, 1);
    lcd.print("WaterQ: ");
    lcd.print(water_quality_category);


    delay(5000);
    
    // ThingSpeak data upload
    ThingSpeak.setField(1, temperature);
    ThingSpeak.setField(2, humidity);
    ThingSpeak.setField(3, air_quality);
    ThingSpeak.setField(4, pH);
    ThingSpeak.setField(5, ntu);
    ThingSpeak.setField(6, air_quality_category);
    ThingSpeak.setField(7, water_quality_category);
    ThingSpeak.writeFields(CHANNEL_ID, CHANNEL_API_KEY);
}
