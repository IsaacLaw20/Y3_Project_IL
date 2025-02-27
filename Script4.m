clear; clc; close all;

%% --- Define a Scale Factor to Bring Down the Simulation Results ---
% Adjust this value as needed to align the simulation with measured data.
scaleFactor = 0.1;

%% --- Simulation: Compute the Surface Data ---
% Circuit parameters
R1 = 0.072;           % Resistance in Ohms
L1 = 24e-6;           % Inductance in Henry
C1 = 0.1e-6;          % Capacitance in Farads
L2 = 24e-6;           % Inductance in Henry for branch 2
C2 = 100e-9;          % Capacitance in Farads for branch 2
M  = 1.2e-5;          % Mutual inductance in Henry
V1 = 5;               % Source voltage (amplitude)

% Frequency and resistance ranges
freq = logspace(log10(50e3), log10(250e3), 500);   % Frequency: 50 kHz to 250 kHz
R2_vals = logspace(0, log10(150), 200);           % R2: 1 Ω to 150 Ω (log-spaced)

% Preallocate matrix for power
P_R2 = zeros(length(R2_vals), length(freq));

% Loop over R2 and frequency values to compute power
for i = 1:length(R2_vals)
    R2 = R2_vals(i);
    for j = 1:length(freq)
        w = 2*pi*freq(j);  % Angular frequency
        
        % Build impedance matrix Z
        Z11 = R1 + 1i*w*L1 - 1i/(w*C1);
        Z12 = 1i*w*M;
        Z21 = 1i*w*M;
        Z22 = R2 + 1i*w*L2 - 1i/(w*C2);
        Z = [Z11, Z12; Z21, Z22];
        
        % Solve for currents [I1; I2]
        I = Z \ [V1; 0];
        I2 = I(2);
        
        % Compute power dissipated in R2
        % 1) Original formula: abs(I2)^2 * R2
        % 2) Scale down by 1000 (if desired, as before)
        % 3) Apply your chosen scaleFactor to match measurement
        P_R2(i, j) = scaleFactor * ((abs(I2)^2 * R2) / 1000);
    end
end

% Create meshgrid for surface plot
[FF, RR] = meshgrid(freq, R2_vals);

%% --- Experimental Data ---
% Data format: [Resistance, Frequency, Power]
data = [
   50   1100     0.000010125
   50   5000     0.0001805
   50   10000    0.00040527
   50   20000    0.000338
   50   30000    0.000411845
   50   40000    0.00043808
   50   50000    0.00045
   50   60000    0.0003645
   50   70000    0.0004805
   50   80000    0.0005445
   50   90000    0.0005445
   50   100000   0.00049928
   50   110000   0.0004205
   50   120000   0.0005445
   50   130000   0.0004805
   50   140000   0.000008
   50   150000   0.000002
   50   160000   0.000001125
   50   170000   0.000005445
   50   180000   0.000338
   50   190000   0.000139445
   50   200000   0.001420445
   110  1100     0.000023276
   110  5000     0.000431244
   110  10000    0.000715275
   110  20000    0.000628331
   110  30000    0.000842192
   110  40000    0.000868571
   110  50000    0.000937904
   110  60000    0.0000044
   110  70000    0.000019404
   110  80000    0.0009251
   110  90000    0.0009251
   110  100000   0.000950796
   110  110000   0.0009251
   110  120000   0.001023275
   110  130000   0.0005324
   110  140000   0.0000099
   110  150000   3.25424e-06
   110  160000   2.88684e-06
   110  170000   0.000020339
   110  180000   0.000844019
   110  190000   0.000228096
   110  200000   0.001234475
   150  1100     0.00010584
   150  5000     0.000642735
   150  10000    0.000871215
   150  20000    0.00090774
   150  30000    0.001021815
   150  40000    0.001134375
   150  50000    0.000871215
   150  60000    5.02335e-06
   150  70000    1.86914e-05
   150  80000    0.000960135
   150  90000    0.0010935
   150  100000   0.001233814
   150  110000   0.001176
   150  120000   0.00124416
   150  130000   0.0010935
   150  140000   1.18442e-05
   150  150000   5.02335e-06
   150  160000   4.7526e-06
   150  170000   0.000033135
   150  180000   0.00096774
   150  190000   0.00110976
   150  200000   0.001021815
];

% Extract columns: first column = resistance, second = frequency, third = power
R_data = data(:,1);
F_data = data(:,2);
P_data = data(:,3);

%% --- Plot Both the Surface and the Data Points on the Same Graph ---
figure;

% Plot the simulation surface
surf(FF, RR, P_R2, 'EdgeColor', 'none');
set(gca, 'XScale', 'log', 'YScale', 'log');  % Use log scale on freq (X) and R2 (Y)

% Axis labels
xlabel('log_{10}(Frequency) (Hz)');
ylabel('log_{10}(Output Resistance) (\Omega)');
zlabel('Output Power (W)');

xlim([5e4, 2.5e5]);  % Limit frequency axis to simulation range
colormap(jet);
shading interp;
colorbar;
view(135, 30);

hold on;
% Overlay experimental data as points
scatter3(F_data, R_data, P_data, 50, 'k', 'filled');
hold off;
