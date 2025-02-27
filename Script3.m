clear; clc; close all;

%% --- First Dataset (Original Data) ---
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

% Extract columns: Resistance, Frequency, Power
R = data(:,1);
F = data(:,2);
P = data(:,3);

%% --- Define Logarithmic Frequency and Resistance Ranges ---
% Frequency from 50 kHz to 250 kHz:
freq = logspace(log10(50e3), log10(250e3), 500);   
% Output resistance (R2) values from 1 Ohm to 100 Ohm:
R2_vals = logspace(0, log10(100), 200);  

%% --- Interpolate First Dataset onto Logarithmic Grid ---
% Create a meshgrid for the logarithmic frequency and resistance ranges
[FF, RR] = meshgrid(freq, R2_vals);

% Interpolate the power values onto the new grid
PP = griddata(F, R, P, FF, RR);

%% --- Plot the First Dataset on Logarithmic Axes ---
figure;
surf(FF, RR, PP, 'EdgeColor', 'none');
set(gca, 'XScale', 'log', 'YScale', 'log');  % Set frequency and resistance axes to log scale

% Adjust axis labels
xlabel('Frequency (log10(Hz))');
ylabel('Output Resistance (log10(Ω))');
zlabel('Output Power (W)');

% Limit frequency axis to 50 kHz - 250 kHz
xlim([50e3, 250e3]);

% Optional appearance tweaks
shading interp;      % Smooth color transitions
colormap(jet);       % Colormap
colorbar;            % Show color scale
view(135, 30);       % Adjust viewing angle
