%====================================================================
% MATLAB Script: Plot Data from "Y3 Project total.txt", "plot2.txt", and "Plot3.txt"
%====================================================================

% Clear the workspace and command window (optional, but good practice)
clear; clc; close all;

%% Define custom darker yellow color as an RGB triplet
darkerYellow = [0.86, 0.86, 0];

%% Part 1: Plot Data from "Y3 Project total.txt" for First 35 Microseconds

%--------------------------------------------------------------------
% 1. Read Data from "Y3 Project total.txt"
%--------------------------------------------------------------------
filename1 = 'Y3 Project total.txt';  % Replace with the correct path if needed
data1 = readmatrix(filename1, 'Delimiter','\t');

%--------------------------------------------------------------------
% 2. Parse Columns
%--------------------------------------------------------------------
time1 = data1(:, 1);          % Time in the first column (seconds)
voltage1 = data1(:, 2);       % Voltage in the second column

%--------------------------------------------------------------------
% 3. Filter Data to First 35 Microseconds
%--------------------------------------------------------------------
idx1 = time1 <= 35e-6;        % 35 microseconds = 35e-6 seconds
time1_filtered = time1(idx1);
voltage1_filtered = voltage1(idx1);

% Convert time from seconds to microseconds for plotting
time1_us = time1_filtered * 1e6;

%--------------------------------------------------------------------
% 4. Plot Data from "Y3 Project total.txt" on a Black Background
%--------------------------------------------------------------------
figure;                         % Create a new figure for the first plot
set(gcf, 'Color', 'k');         % Set figure background to black

plot(time1_us, voltage1_filtered, 'Color', darkerYellow, 'LineWidth', 2);
xlabel('Time (\mus)', 'Color', 'w');  % X-axis label in white
ylabel('Voltage (V)', 'Color', 'w');   % Y-axis label in white
ylim([-1 10]);                % Set y-axis limits from -1 V to 10 V
grid on;                      % Turn on grid

% Set axes properties for contrast on a black background
ax = gca;
ax.Color = 'k';               % Axes background black
ax.XColor = 'w';              % X-axis tick and label color white
ax.YColor = 'w';              % Y-axis tick and label color white
ax.GridColor = 'w';           % Grid color white

%% Part 2: Plot Data from "plot2.txt" between 5000 µs and 5035 µs

%--------------------------------------------------------------------
% 1. Read Data from "plot2.txt"
%--------------------------------------------------------------------
filename2 = 'plot2.txt';  % Replace with the correct path if needed
data2 = readmatrix(filename2, 'Delimiter','\t');

%--------------------------------------------------------------------
% 2. Parse Columns
%--------------------------------------------------------------------
time2 = data2(:, 1);        % Time in seconds
voltage2 = data2(:, 2);     % Voltage data

%--------------------------------------------------------------------
% 3. Filter Data between 5000 µs and 5035 µs
%--------------------------------------------------------------------
lowerLimit = 5000e-6;       % 5000 µs = 5e-3 seconds
upperLimit = 5035e-6;       % 5035 µs = 5.035e-3 seconds
idx2 = (time2 >= lowerLimit) & (time2 <= upperLimit);
time2_filtered = time2(idx2);
voltage2_filtered = voltage2(idx2);

% Convert time from seconds to microseconds for plotting
time2_us = time2_filtered * 1e6;

%--------------------------------------------------------------------
% 4. Plot Data from "plot2.txt" on a Black Background
%--------------------------------------------------------------------
figure;                         % Create a new figure for the second plot
set(gcf, 'Color', 'k');         % Set figure background to black

plot(time2_us, voltage2_filtered, 'Color', darkerYellow, 'LineWidth', 2);
xlabel('Time (\mus)', 'Color', 'w');  % X-axis label in white
ylabel('Voltage (V)', 'Color', 'w');   % Y-axis label in white
grid on;                      % Turn on grid

% Set axes properties for contrast on a black background
ax = gca;
ax.Color = 'k';
ax.XColor = 'w';
ax.YColor = 'w';
ax.GridColor = 'w';

%% Part 3: Plot Data from "Plot3.txt" between 0 and 30 ms

%--------------------------------------------------------------------
% 1. Read Data from "Plot3.txt"
%--------------------------------------------------------------------
filename3 = 'Plot3.txt';  % Replace with the correct path if needed
data3 = readmatrix(filename3, 'Delimiter','\t');

%--------------------------------------------------------------------
% 2. Parse Columns
%--------------------------------------------------------------------
time3 = data3(:, 1);         % Time in the first column (seconds)
voltage3 = data3(:, 2);      % Voltage in the second column

%--------------------------------------------------------------------
% 3. Filter Data between 0 and 30 ms
%--------------------------------------------------------------------
idx3 = (time3 >= 0) & (time3 <= 30e-3);  % 30 ms = 30e-3 seconds
time3_filtered = time3(idx3);
voltage3_filtered = voltage3(idx3);

% Convert time from seconds to milliseconds for plotting
time3_ms = time3_filtered * 1e3;

%--------------------------------------------------------------------
% 4. Plot Data from "Plot3.txt" on a Black Background (No Title)
%--------------------------------------------------------------------
figure;                         % Create a new figure for the third plot
set(gcf, 'Color', 'k');         % Set figure background to black

plot(time3_ms, voltage3_filtered, 'Color', darkerYellow, 'LineWidth', 2);
xlabel('Time (ms)', 'Color', 'w');   % X-axis label in white
ylabel('Voltage (V)', 'Color', 'w');  % Y-axis label in white
grid on;                      % Turn on grid

% Set axes properties for contrast on a black background
ax = gca;
ax.Color = 'k';
ax.XColor = 'w';
ax.YColor = 'w';
ax.GridColor = 'w';
