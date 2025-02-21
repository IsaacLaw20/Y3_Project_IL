%% Define circuit parameters
R1 = 0.072;           % Resistance in Ohms
L1 = 24e-6;           % Inductance in Henry
C1 = 0.1e-6;          % Capacitance in Farads
L2 = 24e-6;           % Inductance in Henry for branch 2
C2 = 100e-9;          % Capacitance in Farads for branch 2
M  = 1.2e-5;          % Mutual inductance in Henry
V1 = 5;               % Source voltage (amplitude)

%% Define frequency and R2 ranges on a logarithmic scale
% Frequency from 50 kHz to 250 kHz:
freq = logspace(log10(50e3), log10(250e3), 500);   
% Output resistance (R2) values from 1 Ohm to 100 Ohm:
R2_vals = logspace(0, log10(100), 200);  

%% Preallocate matrix for power computed at each (R2, freq)
P_R2 = zeros(length(R2_vals), length(freq));

%% Loop over R2 and frequency values
for i = 1:length(R2_vals)
    R2 = R2_vals(i);
    for j = 1:length(freq)
        w = 2*pi*freq(j);  % Angular frequency
        
        % Build the impedance matrix Z
        Z11 = R1 + 1i*w*L1 - 1i/(w*C1);
        Z12 = 1i*w*M;
        Z21 = 1i*w*M;
        Z22 = R2 + 1i*w*L2 - 1i/(w*C2);
        Z = [Z11, Z12; Z21, Z22];
        
        % Solve for the currents [I1; I2]
        I = Z \ [V1; 0];
        I2 = I(2);
        
        % Compute the power dissipated in R2 (assuming RMS values)
        P_R2(i, j) = abs(I2)^2 * R2;
    end
end

%% Create a 3D surface plot with linear power and logarithmic frequency and resistance axes
figure;
surf(freq, R2_vals, P_R2, 'EdgeColor', 'none');
set(gca, 'XScale', 'log', 'YScale', 'log');  % Set frequency and resistance axes to log scale

% Adjust axis labels
xlabel('Frequency (log10(Hz))');
ylabel('Output Resistance (log10(Ω))');
zlabel('Output Power (W)');

% Limit frequency axis to 50 kHz - 250 kHz
xlim([50e3, 250e3]);

colorbar;
view(135,30);  % Adjust the view angle for better visualization
