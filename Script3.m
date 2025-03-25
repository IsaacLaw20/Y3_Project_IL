%====================================================================
% MATLAB Script: Plot Data from "Y3 Project total.txt"
%====================================================================

% Clear the workspace and command window (optional, but good practice)
clear; clc; close all;

%--------------------------------------------------------------------
% 1. Read Data from Text File
%--------------------------------------------------------------------
% Adjust the delimiter as needed:
%   - For tab-delimited, use 'Delimiter','\t'
%   - For comma-delimited, use 'Delimiter',','
filename = 'Y3 Project total.txt';  % Replace with the correct path if needed

% Read the file using readmatrix (R2019b or later)
data = readmatrix(filename, 'Delimiter','\t');

%--------------------------------------------------------------------
% 2. Parse Columns
%--------------------------------------------------------------------
% We assume:
%   - The first column is time (in seconds)
%   - The second column is a measurement (voltage)
time = data(:, 1);          % Time in the first column (seconds)
measurement = data(:, 2);   % Measurement in the second column

%--------------------------------------------------------------------
% 3. Filter Data to First 35 Microseconds
%--------------------------------------------------------------------
% 35 microseconds = 35e-6 seconds
idx = time <= 35e-6;
time_filtered = time(idx);
measurement_filtered = measurement(idx);

% Convert time from seconds to microseconds for plotting
time_us = time_filtered * 1e6;

%--------------------------------------------------------------------
% 4. Plot Data
%--------------------------------------------------------------------
figure;  % Create a new figure

% Define a custom darker yellow color as an RGB triplet
darkerYellow = [0.86, 0.86, 0];

% Plot the filtered data with the custom darker yellow trace and thicker line
plot(time_us, measurement_filtered, 'Color', darkerYellow, 'LineWidth', 2);
xlabel('Time (\mus)');      % X-axis label in microseconds
ylabel('Voltage (V)');       % Y-axis label
ylim([-1 10]);               % Set y-axis limits from -1 V to 10 V
grid on;                   % Turn on grid
