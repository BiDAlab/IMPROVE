% Adjust the format to display full numerical precision
format long g;

% Load the data from a file
filename = '1664964343202_Heart'; % File selection
data = readtable(filename, 'Delimiter', ' ', 'HeaderLines', 1, 'ReadVariableNames', false);
data.Properties.VariableNames = {'HeartRate', 'Timestamp'};

% Convert the table into arrays for easier processing
HeartRate = data.HeartRate;
Timestamp = data.Timestamp;

% Convert timestamps from milliseconds to seconds and reset to start at zero
Timestamp = (Timestamp - Timestamp(1)) / 1000;

% Uncomment to calculate sampling rate
% sample_intervals = diff(Timestamp);
% Fs = 1 / mean(sample_intervals);
% disp(['Calculated sampling frequency: ', num2str(Fs), ' Hz']);

% Identify gaps where the difference between consecutive timestamps is greater than 2 seconds
gap_threshold = 2; % 2 seconds
gaps = find(diff(Timestamp) > gap_threshold);

% Create new arrays to store data with NaNs and corresponding timestamps
new_HeartRate = [];
new_Timestamp = [];

% Iterate over the original data and insert NaNs and timestamps in detected gaps
for i = 1:length(Timestamp)-1
    new_HeartRate = [new_HeartRate; HeartRate(i)];
    new_Timestamp = [new_Timestamp; Timestamp(i)];
    
    % If a gap is found, insert NaNs and corresponding timestamps
    if ismember(i, gaps)
        num_missing_points = floor((Timestamp(i+1) - Timestamp(i)) / 1) - 1; % Number of missing seconds minus 1
        for j = 1:num_missing_points
            new_Timestamp = [new_Timestamp; Timestamp(i) + j * 1];
            new_HeartRate = [new_HeartRate; NaN];
        end
    end
end

% Append the last HeartRate and Timestamp values
new_HeartRate = [new_HeartRate; HeartRate(end)];
new_Timestamp = [new_Timestamp; Timestamp(end)];

% Interpolate NaNs if there are up to 5 consecutive missing values
for i = 2:length(new_HeartRate)-1
    % Count how many consecutive NaNs there are
    if isnan(new_HeartRate(i))
        count_nan = 0;
        while (i + count_nan <= length(new_HeartRate)) && isnan(new_HeartRate(i + count_nan))
            count_nan = count_nan + 1;
        end
        
        % If there are 5 or fewer NaNs, perform linear interpolation
        if count_nan <= 5
            if (i > 1) && (i + count_nan <= length(new_HeartRate))
                start_val = new_HeartRate(i-1);  % Value before the first NaN
                end_val = new_HeartRate(i + count_nan);  % Value after the last NaN
                step = (end_val - start_val) / (count_nan + 1);  % Interpolation step
                
                % Progressive linear interpolation
                for j = 1:count_nan
                    new_HeartRate(i + j - 1) = start_val + j * step;
                end
            end
        end
        
        % Skip to the end of the consecutive NaNs to avoid reprocessing
        i = i + count_nan - 1;
    end
end

% Apply a moving average filter with a window size of 15 for smoothing
window_size = 15;
% FilteredHeartRate = medfilt1(new_HeartRate, window_size, 'omitnan'); % Uncomment for median filter
FilteredHeartRate = movmean(new_HeartRate, window_size, 'omitnan');
FilteredHeartRate = round(FilteredHeartRate);

% After filtering, re-identify long gaps and mark them as NaNs in the filtered signal
for i = 1:length(new_HeartRate)-1
    if isnan(new_HeartRate(i))
        count_nan = 0;
        while (i + count_nan <= length(new_HeartRate)) && isnan(new_HeartRate(i + count_nan))
            count_nan = count_nan + 1;
        end
        
        % If there are more than 5 consecutive NaNs, mark the entire region as NaN in the filtered signal
        if count_nan > 5
            FilteredHeartRate(i:i+count_nan-1) = NaN;
        end
        
        % Skip to the end of the NaN region
        i = i + count_nan - 1;
    end
end

