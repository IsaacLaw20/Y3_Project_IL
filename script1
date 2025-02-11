% Code to plot the output voltages across the receiver as a function of
% frequency
% Define system parameters
Rt = 72e-3;   % Resistance of transmitter (Ohms)
Rr = 50;      % Resistance of receiver (including load) (Ohms)
Lt = 24e-6;   % Inductance of transmitter (H)
Lr = 24e-6;   % Inductance of receiver (H)
C = 100e-9;   % Capacitance (F)
k = 0.99;     % Coupling coefficient
Vt = 5;       % Input voltage (V)

% Frequency range
f = linspace(50e3, 150e3, 1000); % Frequency range from 50 kHz to 150 kHz
omega = 2 * pi * f; % Angular frequency (rad/s)

% Initialise output voltage vector
Vout = zeros(size(f));

% Compute mutual inductance
M = k * sqrt(Lt * Lr); % M=k sqrt(LtLr)

% Loop over frequencies
for i = 1:length(f)
    % Compute reactances
    Xt = omega(i) * Lt; % Transmitter reactance
    Xr = omega(i) * Lr; % Receiver reactance
    Xc = -1 / (omega(i) * C); % Capacitive reactance
    
    % Impedance matrix
    Z = [Rt + 1i * (Xt + Xc), 1i * omega(i) * M;
         1i * omega(i) * M, Rr + 1i * Xr];
    
    % Voltage vector
    V = [Vt; 0]; % Input voltage is applied to the transmitter
    
    % Solve for currents
    I = Z \ V; % Solve Z * I = V
    
    % Output voltage across Rr
    Vout(i) = I(2) * Rr;
end

% Plot output voltage vs frequency
figure;
plot(f / 1e3, abs(Vout)); % Plot magnitude of output voltage
xlabel('Frequency (kHz)');
ylabel('Output Voltage (V)');
title('Output Voltage vs Frequency');
grid on;
