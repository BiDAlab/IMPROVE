% Load the data from a file
filename = '1664964343202_Acc.txt'; % Replace the filename with the appropriate one
data = readtable(filename, 'Delimiter', ' ', 'HeaderLines', 1, 'ReadVariableNames', false);

% Assign meaningful column names for the accelerometer data and timestamps
data.Properties.VariableNames = {'X', 'Y', 'Z', 'Timestamp'};

% Extract columns from the table for easier processing
X = data.X; % X-axis accelerometer data
Y = data.Y; % Y-axis accelerometer data
Z = data.Z; % Z-axis accelerometer data
Timestamp = data.Timestamp; % Timestamps in milliseconds

% Convert timestamps from milliseconds to seconds and adjust to start at zero
Timestamp = (Timestamp - Timestamp(1)) / 1000;

% Calculate the sampling frequency (Fs) based on the differences in timestamps
sample_intervals = diff(Timestamp); % Differences between consecutive timestamps
Fs = 1 / mean(sample_intervals); % Sampling frequency in Hz
disp(['Calculated sampling frequency: ', num2str(Fs), ' Hz']);

% Manually set the sampling frequency (overwrite if necessary)
%Fs = 100; % Sampling frequency in Hz

% Parameters for the Butterworth filter
Fc = 15; % Cutoff frequency in Hz
[b, a] = butter(4, Fc / (Fs / 2), 'low'); % Fourth-order low-pass Butterworth filter

% Apply the Butterworth filter to the accelerometer signals
FilteredX_Butterworth = filtfilt(b, a, X); % Filtered X-axis signal
FilteredY_Butterworth = filtfilt(b, a, Y); % Filtered Y-axis signal
FilteredZ_Butterworth = filtfilt(b, a, Z); % Filtered Z-axis signal


