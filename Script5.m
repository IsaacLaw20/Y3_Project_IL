% Create the data matrix: columns correspond to [Iload (mA), R, f]
data = [ ...
    3.22, 11,   100e3;
    3.00, 30,   100e3;
    2.90, 63,   100e3;
    2.60, 100,  100e3;
    2.15, 220,  100e3;
    1.91, 300,  100e3;
    3.30, 11,    50e3;
    3.00, 30,    50e3;
    2.90, 63,    50e3;
    2.77, 100,   50e3;
    2.22, 220,   50e3;
    1.97, 300,   50e3;
    2.28, 11,   150e3;
    2.21, 30,   150e3;
    1.98, 63,   150e3;
    1.82, 100,  150e3;
    1.61, 220,  150e3;
    1.46, 300,  150e3];

% Separate the data based on frequency
freq100 = data(data(:,3) == 100e3, :);
freq50  = data(data(:,3) == 50e3, :);
freq150 = data(data(:,3) == 150e3, :);

% Create the plot
figure;
plot(freq100(:,2), freq100(:,1), '-o', 'DisplayName', '100 kHz'); hold on;
plot(freq50(:,2),  freq50(:,1),  '-s', 'DisplayName', '50 kHz');
plot(freq150(:,2), freq150(:,1), '-d', 'DisplayName', '150 kHz'); hold off;

% Labeling the axes and adding title
xlabel('Resistance (Ω)');
ylabel('Load Current (mA)');

legend('Location','Best');
grid on;
