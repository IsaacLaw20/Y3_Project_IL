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
/*
 * Function name: send_spi_word_manual
 * Function brief: Sends a 16-bit word manually via SPI by bit-banging.
 * Function parameters: 
 *   - uint16_t word: The 16-bit word to be sent over SPI.
 * Function returns: void.
 */
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
/*
 * Function name: create_oct
 * Function brief: Calculates the octave value for a given frequency using a logarithmic formula.
 * Function parameters:
 *   - double freq: The input frequency.
 * Function returns: uint16_t representing the octave value.
 */
uint16_t create_oct(double freq) {
    // Prevent log(0):
    if (freq <= 0) {
        return 0;
    }
    // Octave formula (from datasheet):
    uint16_t octave = (uint16_t)floor(3.322 * (log(freq / 1039.0) / log(10.0)));
    return octave;
}

/*
 * Function name: create_daq
 * Function brief: Calculates the DAC value based on the frequency and octave.
 * Function parameters:
 *   - double freq: The input frequency.
 *   - uint8_t oct: The octave value.
 * Function returns: uint16_t representing the DAC value.
 */
uint16_t create_daq(double freq, uint8_t oct) {
    if (freq <= 0) {
        return 0;
    }
    // DAC formula (from datasheet):
    uint16_t daq = (uint16_t)(2048 - (2078 * pow(2, (10.0 + (double)oct)) / (double)freq));
    return daq;
}

/*
 * Function name: create_spi_word
 * Function brief: Combines the octave, DAC, and configuration bits into a single 16-bit word.
 * Function parameters:
 *   - uint8_t oct: The 4-bit octave value.
 *   - uint16_t dac: The 10-bit DAC value.
 *   - uint8_t cnf: The 2-bit configuration value.
 * Function returns: uint16_t representing the combined 16-bit word.
 */
uint16_t create_spi_word(uint8_t oct, uint16_t dac, uint8_t cnf) {
    // Pack bits: [OCT:4 | DAC:10 | CNF:2]
    oct &= 0x0F;    // 4 bits
    dac &= 0x03FF;  // 10 bits
    cnf &= 0x03;    // 2 bits
    uint16_t whole_word = (oct << 12) | (dac << 2) | cnf;
    return whole_word;
}
/*
 * Function name: send_spi_word
 * Function brief: Computes the necessary parameters from a frequency and sends the corresponding SPI word.
 * Function parameters:
 *   - double aFreq: The frequency to be sent to the LTC oscillator.
 * Function returns: void.
 */
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

// This class is based on the EEEN20011 example program 3. Author: Dr P N Green.

/*
 * Class name: Potentiometer
 * Class brief: Represents a potentiometer interface that reads analog input values, allowing conversion to voltage and normalised values.
 */
class Potentiometer {
private:
    AnalogIn inputSignal;                                                 // Analog input pin for reading the potentiometer signal.
    float    VDD;                                                         // Supply voltage (VDD) for scaling the analog reading.
    float    currentSampleNorm;                                           // Holds the most recent normalised sample (range: 0.0 to 1.0)
    float    currentSampleVolts;                                          // Holds the most recent sample converted to voltage.

public:
    Potentiometer(PinName pin, float v) : inputSignal(pin), VDD(v) {}    // Constructor to initialise the potentiometer with the given analog pin and supply voltage.
    /*
     * Function name: amplitudeVolts
     * Function brief: Reads the current amplitude in volts from the potentiometer.
     * Function parameters: None.
     * Function returns: float representing the amplitude in volts.
     */
    float amplitudeVolts(void) {
        return (inputSignal.read() * VDD);
    }
    /*
     * Function name: amplitudeNorm
     * Function brief: Reads the normalized amplitude (0.0 to 1.0) from the potentiometer.
     * Function parameters: None.
     * Function returns: float representing the normalized amplitude.
     */
    float amplitudeNorm(void) {
        return inputSignal.read();
    }
    /*
     * Function name: sample
     * Function brief: Samples the current analog input and stores both normalized and voltage values.
     * Function parameters: None.
     * Function returns: void.
     */
    void sample(void) {
        currentSampleNorm  = inputSignal.read();
        currentSampleVolts = currentSampleNorm * VDD;
    }
    /*
     * Function name: getCurrentSampleVolts
     * Function brief: Retrieves the last sampled voltage value.
     * Function parameters: None.
     * Function returns: float representing the voltage value of the last sample.
     */
    float getCurrentSampleVolts(void) {
        return currentSampleVolts;
    }
    /*
     * Function name: getCurrentSampleNorm
     * Function brief: Retrieves the last sampled normalized value.
     * Function parameters: None.
     * Function returns: float representing the normalized value of the last sample.
     */
    float getCurrentSampleNorm(void) {
        return currentSampleNorm;
    }
};

/*
 * Class name: SamplingPotentiometer
 * Class brief: Extends the Potentiometer class to add periodic sampling using a Ticker.
 * Class parameters: None.
 * Class returns: Not applicable.
 */
class SamplingPotentiometer : public Potentiometer {
private:
    float  samplingFrequency;    // Sampling frequency in Hertz.
    float  samplingPeriod;       // Sampling period in seconds, calculated as the inverse of the sampling frequency.
    Ticker sampler;              // Ticker object used to schedule periodic sampling.

public:
    SamplingPotentiometer(PinName pin2, float voltage2, float freqsamp)    // Constructor to inititalise the sampling potentiometer, inheriting from the potentiometer class.
        : Potentiometer(pin2, voltage2),
          samplingFrequency(freqsamp) 
    {
        samplingPeriod = 1.0f / samplingFrequency;                                // calculate the sampling period
        
        sampler.attach(callback(this, &Potentiometer::sample), samplingPeriod);    // Attach a ticker to periodically call the sample function
    }
};


SamplingPotentiometer L_Wheel(A0, 3.3f, 200.0f);  // create left potentiometer object to sample at 200 Hz        


int main() {
    // Initialise LCD
    lcd.cls();

    // Enable LTC oscillator hardware
    enableMosDriver.write(1); // 1 = disable driver outputs (active LOW pin)
    oe.write(0);             // LTC oscillator output off initially
    
    // Send an initial frequency
    send_spi_word(1000);     // 1kHz startup
    oe.write(1);             // Turn LTC output on
    enableMosDriver.write(0); // 0 = enable MOSFET driver outputs

    while(1) {                                                // cyclic executive
        
        float potValue = L_Wheel.getCurrentSampleNorm();      // Read the left potentiometer's normalised value (0.0 to 1.0)
      
        float freq = FREQ_MIN + potValue * (FREQ_MAX - FREQ_MIN); // Map potValue to the frequency range [1 kHz, 500 kHz]

        
        send_spi_word(freq);                                      // Send that frequency to the LTC

        
        lcd.locate(0,9);                                          // Display potentiometer's readings
        lcd.printf("Pot Norm: %.2f  ", potValue);

        wait(0.01); // small delay to avoid spamming
    }
}
