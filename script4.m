% Combined MATLAB script to plot:
% 1. Distance vs Voltage with trendline (from distanceData.csv)
% 2. Current vs Frequency with connected points (from currentFrequency.csv)
% 3. Voltage vs Time with connecting line only (from batteryData.csv)
% All plots are in black and white.

% Clear previous figures and variables
clf;
clear;
close all;

%% Plot 1: Distance vs Voltage
% Assumes CSV file 'distanceData.csv' has two columns: [voltage, distance(mm)] with no headers
data1 = readmatrix('distanceData.csv');

% Extract voltage (column 1) and distance (column 2)
voltage = data1(:, 1);
distance = data1(:, 2);

% Create scatter plot with swapped axes: distance on x-axis, voltage on y-axis
figure;
scatter(distance, voltage, 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
grid on;
xlabel('Distance (mm)');
ylabel('Voltage (V)');


% Calculate and plot linear trendline (using distance as independent variable)
coeffs1 = polyfit(distance, voltage, 1);
x_fit1 = linspace(min(distance), max(distance), 100);
y_fit1 = polyval(coeffs1, x_fit1);

hold on;
plot(x_fit1, y_fit1, 'k-', 'LineWidth', 2);


% Optional: Save the figure
% saveas(gcf, 'distance_vs_voltage_plot_bw.png');

%% Plot 2: Current vs Frequency (with connected points)
% Assumes CSV file 'currentFrequency.csv' has two columns: [frequency, current(mA)] with no headers
data2 = readmatrix('currentFrequency.csv');

% Extract frequency (column 1) and current (column 2)
frequency = data2(:, 1);
current = data2(:, 2);

% Sort the data by frequency to ensure proper line connection
[frequency_sorted, sort_idx] = sort(frequency);
current_sorted = current(sort_idx);

% Create plot with connected points
figure;
plot(frequency_sorted, current_sorted, 'k-o', ...
    'MarkerFaceColor', 'k', ...
    'MarkerSize', 5, ...
    'LineWidth', 1.5);
grid on;
xlabel('Frequency (kHz)');
ylabel('Current (mA)');


% Add data point markers
hold on;
scatter(frequency_sorted, current_sorted, 'filled', ...
    'MarkerEdgeColor', 'k', ...
    'MarkerFaceColor', 'k');



% Optional: Save the figure
% saveas(gcf, 'current_vs_frequency_connected_plot_bw.png');

%% Plot 3: Voltage vs Time (line only)
% Assumes CSV file 'batteryData.csv' has two columns: [voltage, hour] with no headers
data3 = readmatrix('batteryData.csv');

% Extract voltage (column 1) and time (hour, column 2)
voltage2 = data3(:, 1);
time = data3(:, 2);

% Sort the data by time to ensure proper line connection
[time_sorted, idx3] = sort(time);
voltage_sorted = voltage2(idx3);

% Create plot with connecting line only (no markers)
figure;
plot(time_sorted, voltage_sorted, 'k-', 'LineWidth', 1.5);
grid on;
xlabel('Time (hours)');
ylabel('Voltage (V)');



% Optional: Save the figure
% saveas(gcf, 'voltage_vs_time_line_plot_bw.png');
