#include "mbed.h"
#include <cmath>
#include "C12832.h"

// -------------------- LCD --------------------
C12832 lcd(D11, D13, D12, D7, D10);

// -------------------- LTC Oscillator Definitions --------------------
#define UCC_DIS   PA_14   // MOSFET driver disable
#define LTC_SDI   PC_12   // LTC serial data
#define LTC_OE    PC_3    // LTC output enable
#define LTC_SCK   PC_10   // LTC SPI clock
#define LTC_SEN   PC_8   // LTC serial enable (active LOW)
#define FREQ_MIN 1000.0f     // min freq
#define FREQ_MAX 200000.0f   // max freq

DigitalOut oe(LTC_OE);               // Enables oscillator output
DigitalOut enableMosDriver(UCC_DIS); // Enable MOSFET driver pin
DigitalOut sdi(LTC_SDI);  // Serial Data Input
DigitalOut sck(LTC_SCK);  // Serial Clock
DigitalOut sen(LTC_SEN);  // Serial Enable

// -------------------- Manual SPI Send --------------------
void send_spi_word_manual(uint16_t word) {
    sen.write(0);  // Pull SEN low to start the transaction
    wait_us(1);
    sck.write(0);  // Ensure clock starts low
    
    for (int i = 15; i >= 0; i--) {
        sdi.write((word >> i) & 0x01); // Write current bit
        sck.write(1);                 // Clock high (data latched on rising)
        wait_us(1);
        sck.write(0);                 // Clock low
        wait_us(1);
    }
    sen.write(1);       // Transaction end
    wait_us(10);        // Allow data to latch
}

// -------------------- LTC Word-Building Functions --------------------
uint16_t create_oct(double freq) {
    // Prevent log(0):
    if (freq <= 0) {
        return 0;
    }
    // Octave formula (from datasheet):
    uint16_t octave = (uint16_t)floor(3.322 * (log(freq / 1039.0) / log(10.0)));
    return octave;
}

uint16_t create_daq(double freq, uint8_t oct) {
    if (freq <= 0) {
        return 0;
    }
    // DAC formula (from datasheet):
    uint16_t daq = (uint16_t)(2048 - (2078 * pow(2, (10.0 + (double)oct)) / (double)freq));
    return daq;
}

uint16_t create_spi_word(uint8_t oct, uint16_t dac, uint8_t cnf) {
    // Pack bits: [OCT:4 | DAC:10 | CNF:2]
    oct &= 0x0F;    // 4 bits
    dac &= 0x03FF;  // 10 bits
    cnf &= 0x03;    // 2 bits
    uint16_t whole_word = (oct << 12) | (dac << 2) | cnf;
    return whole_word;
}

void send_spi_word(double aFreq) {
    uint8_t  anOct     = create_oct(aFreq);
    uint16_t aDac      = create_daq(aFreq, anOct);
    uint8_t  aCnf      = 0; // Config bits
    uint16_t word_send = create_spi_word(anOct, aDac, aCnf);

    // Send the 16-bit word via manual SPI
    send_spi_word_manual(word_send); 

    // LCD printing:
    lcd.locate(0, 0);
    lcd.printf("Word: %04X   ", word_send);
    lcd.locate(0, 20);
    lcd.printf("Freq: %.1f Hz   ", aFreq);
}

// -------------------- Potentiometer Classes --------------------
class Potentiometer {
private:
    AnalogIn inputSignal;
    float    VDD;
    float    currentSampleNorm;
    float    currentSampleVolts;

public:
    Potentiometer(PinName pin, float v) : inputSignal(pin), VDD(v) {}

    float amplitudeVolts(void) {
        return (inputSignal.read() * VDD);
    }

    float amplitudeNorm(void) {
        return inputSignal.read();
    }

    void sample(void) {
        currentSampleNorm  = inputSignal.read();
        currentSampleVolts = currentSampleNorm * VDD;
    }

    float getCurrentSampleVolts(void) {
        return currentSampleVolts;
    }

    float getCurrentSampleNorm(void) {
        return currentSampleNorm;
    }
};

class SamplingPotentiometer : public Potentiometer {
private:
    float  samplingFrequency;
    float  samplingPeriod;
    Ticker sampler;

public:
    SamplingPotentiometer(PinName pin2, float voltage2, float freqsamp)
        : Potentiometer(pin2, voltage2),
          samplingFrequency(freqsamp) 
    {
        samplingPeriod = 1.0f / samplingFrequency;
        // Attach the base-class sample() method to the Ticker
        sampler.attach(callback(this, &Potentiometer::sample), samplingPeriod);
    }
};

// -------------------- Create Our Pot Object (Left Wheel) --------------------
SamplingPotentiometer L_Wheel(A0, 3.3f, 200.0f);  // samples at 200 Hz

// -------------------- MAIN --------------------
int main() {
    // Initial LCD
    lcd.cls();

    // Enable LTC oscillator hardware
    enableMosDriver.write(1); // 1 = disable driver outputs (active LOW pin)
    oe.write(0);             // LTC oscillator output off initially
    
    // Send an initial frequency
    send_spi_word(1000);     // 1kHz startup
    oe.write(1);             // Turn LTC output on
    enableMosDriver.write(0); // 0 = enable MOSFET driver outputs

    while(1) {
        // Read the left pot's normalized value (0.0 to 1.0)
        float potValue = L_Wheel.getCurrentSampleNorm();

        // Map potValue to the frequency range [1 kHz, 500 kHz]
        // freq = 1000 + potValue * (500000 - 1000)
        float freq = FREQ_MIN + potValue * (FREQ_MAX - FREQ_MIN);

        // Send that frequency to the LTC
        send_spi_word(freq);

        // Display pot readings
        lcd.locate(0,9);
        lcd.printf("Pot Norm: %.2f  ", potValue);

        wait(0.01); // small delay to avoid spamming
    }
}
