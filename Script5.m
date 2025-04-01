% Create the data matrix: columns correspond to [Iload (mA), R, f]
data = [ ...
    10,    300,   50e3;
    11.8,  220,   50e3;
    20,    110,   50e3;
    28,    62,    50e3;
    64,    10,    50e3;
    12,    300,  100e3;
    17.3,  220,  100e3;
    30,    110,  100e3;
    40,    62,   100e3;
    100,   10,   100e3;
    17,    300,  150e3;
    23.8,  220,  150e3;
    40,    110,  150e3;
    60,    62,   150e3;
    160,   10,   150e3 ];

% Separate the data based on frequency
freq100 = data(data(:,3) == 100e3, :);
freq50  = data(data(:,3) == 50e3, :);
freq150 = data(data(:,3) == 150e3, :);

% Create the plot
figure;
plot(freq150(:,2), freq150(:,1), '-d', 'DisplayName', '150 kHz'); hold on;
plot(freq100(:,2), freq100(:,1), '-o', 'DisplayName', '100 kHz');
plot(freq50(:,2),  freq50(:,1),  '-s', 'DisplayName', '50 kHz'); hold off;

% Labeling the axes and adding title
xlabel('Resistance (Ω)');
ylabel('Load Current (mA)');

legend({'150 kHz', '100 kHz', '50 kHz'}, 'Location', 'Best');
grid on;
