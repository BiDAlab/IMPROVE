% Load the file and treat each line as a single string
filename = 'file_ATT.csv'; % Replace with your file name
data = readtable(filename, 'Delimiter', '\n', 'ReadVariableNames', false); % Load each line as one string

% Split each line into columns (Date, Time, AttentionLevel)
splitData = split(data.Var1, ' ');

% Assign meaningful column names
data = table(splitData(:, 1), splitData(:, 2), splitData(:, 3), ...
             'VariableNames', {'Date', 'Timestamp', 'AttentionLevel'});

% Convert the table to arrays for easier processing
% Convert AttentionLevel to numeric
AttentionLevel = str2double(data.AttentionLevel);
AttentionLevel=AttentionLevel(2:end);
Timestamp = string(data.Timestamp);
Timestamp=Timestamp(2:end);
Timestamp = regexprep(Timestamp, ':(\d+)$', '.$1');
Timestamp= duration(Timestamp, 'InputFormat', 'hh:mm:ss.SSS');
% Convertir el duration a milisegundos
Timestamp= milliseconds(Timestamp);

% Convert Timestamp from milliseconds to seconds and adjust to start at zero
Timestamp = (Timestamp - Timestamp(1)) / 1000;

% Identify gaps where the difference between consecutive timestamps is greater than 2 seconds
gap_threshold = 2; % 2 seconds
gaps = find(diff(Timestamp) > gap_threshold);

% Create new arrays to store data with NaNs and corresponding timestamps
new_AttentionLevel = [];
new_Timestamp = [];

% Iterate through the original data and add NaNs and new timestamps in the gaps
for i = 1:length(Timestamp)-1
    % Append the current AttentionLevel and Timestamp to the new arrays
    new_AttentionLevel = [new_AttentionLevel; AttentionLevel(i)];
    new_Timestamp = [new_Timestamp; Timestamp(i)];
    
    % If a gap is found, add NaNs and new timestamps for the missing intervals
    if ismember(i, gaps)
        num_missing_points = floor((Timestamp(i+1) - Timestamp(i)) / 1) - 1; % Number of missing seconds minus 1
        for j = 1:num_missing_points
            new_Timestamp = [new_Timestamp; Timestamp(i) + j * 1];
            new_AttentionLevel = [new_AttentionLevel; NaN];
        end
    end
end

% Add the last AttentionLevel and Timestamp values
new_AttentionLevel = [new_AttentionLevel; AttentionLevel(end)];
new_Timestamp = [new_Timestamp; Timestamp(end)];

% Interpolate NaNs if there are up to 5 consecutive missing values
for i = 2:length(new_AttentionLevel)-1
    % Count how many consecutive NaNs there are
    if isnan(new_AttentionLevel(i))
        count_nan = 0;
        while (i + count_nan <= length(new_AttentionLevel)) && isnan(new_AttentionLevel(i + count_nan))
            count_nan = count_nan + 1;
        end
        
        % If there are 5 or fewer NaNs, perform interpolation
        if count_nan <= 5
            if (i > 1) && (i + count_nan <= length(new_AttentionLevel))
                start_val = new_AttentionLevel(i-1);  % Value before the first NaN
                end_val = new_AttentionLevel(i + count_nan);  % Value after the last NaN
                step = (end_val - start_val) / (count_nan + 1);  % Interpolation step
                
                % Perform progressive linear interpolation for the missing values
                for j = 1:count_nan
                    new_AttentionLevel(i + j - 1) = start_val + j * step;
                end
            end
        end
        
        % Skip to the end of consecutive NaNs to avoid double processing
        i = i + count_nan - 1;
    end
end

% Apply a median filter with a window size of 5 for additional smoothing
window_size = 5;

% Apply the median filter to smooth the signal while ignoring NaNs
FilteredAttentionLevel = medfilt1(new_AttentionLevel, window_size, 'omitnan');


% After filtering, re-identify long segments of NaNs
for i = 1:length(new_AttentionLevel)-1
    if isnan(new_AttentionLevel(i))
        count_nan = 0;
        while (i + count_nan <= length(new_AttentionLevel)) && isnan(new_AttentionLevel(i + count_nan))
            count_nan = count_nan + 1;
        end
        
        % If there are more than 5 consecutive NaNs, mark the entire region as NaN in the filtered signal
        if count_nan > 5
            FilteredAttentionLevel(i:i+count_nan-1) = NaN;
        end
        
        % Skip to the end of the NaNs
        i = i + count_nan - 1;
    end
end
