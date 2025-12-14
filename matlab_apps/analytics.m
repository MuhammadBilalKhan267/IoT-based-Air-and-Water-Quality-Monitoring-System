% ===================================================================
% THINGSPEAK ENVIRONMENTAL MONITORING - ANALYSIS CODE
% For MATLAB Analysis App (No Visualization)
% ===================================================================

% Channel details
channelID = 123;
readAPIKey = 'yourApiKey';

% === 1. DATA READING ===
% Read data from ThingSpeak
data = thingSpeakRead(channelID, 'ReadKey', readAPIKey, 'NumPoints', 50);

% Extract fields
Humidity = data(:,1);
Temperature = data(:,2);
AQI = data(:,3);
pH = data(:,4);
Turbidity = data(:,5);
AirQuality = data(:,6); % non-numeric (text)
WaterQuality = data(:,7); % non-numeric (text)

% === 2. DESCRIPTIVE ANALYTICS ===
fprintf('\n=== DESCRIPTIVE ANALYTICS ===\n');

% Humidity Statistics
avgHumidity = mean(Humidity, 'omitnan');
stdHumidity = std(Humidity, 'omitnan');
minHumidity = min(Humidity);
maxHumidity = max(Humidity);
fprintf('Humidity: Avg=%.2f%%, Std=%.2f, Min=%.2f, Max=%.2f\n', ...
    avgHumidity, stdHumidity, minHumidity, maxHumidity);

% Temperature Statistics
avgTemp = mean(Temperature, 'omitnan');
stdTemp = std(Temperature, 'omitnan');
minTemp = min(Temperature);
maxTemp = max(Temperature);
fprintf('Temperature: Avg=%.2f°C, Std=%.2f, Min=%.2f, Max=%.2f\n', ...
    avgTemp, stdTemp, minTemp, maxTemp);

% AQI Statistics
avgAQI = mean(AQI, 'omitnan');
stdAQI = std(AQI, 'omitnan');
minAQI = min(AQI);
maxAQI = max(AQI);
fprintf('AQI: Avg=%.2f, Std=%.2f, Min=%.2f, Max=%.2f\n', ...
    avgAQI, stdAQI, minAQI, maxAQI);

% pH Statistics
avgPH = mean(pH, 'omitnan');
stdPH = std(pH, 'omitnan');
minPH = min(pH);
maxPH = max(pH);
fprintf('pH: Avg=%.2f, Std=%.2f, Min=%.2f, Max=%.2f\n', ...
    avgPH, stdPH, minPH, maxPH);

% Turbidity Statistics
avgTurbidity = mean(Turbidity, 'omitnan');
stdTurbidity = std(Turbidity, 'omitnan');
minTurbidity = min(Turbidity);
maxTurbidity = max(Turbidity);
fprintf('Turbidity: Avg=%.2f NTU, Std=%.2f, Min=%.2f, Max=%.2f\n', ...
    avgTurbidity, stdTurbidity, minTurbidity, maxTurbidity);

% === 3. DIAGNOSTIC ANALYTICS ===
fprintf('\n=== DIAGNOSTIC ANALYTICS ===\n');

% Correlation Matrix
numericData = [Humidity, Temperature, AQI, pH, Turbidity];
corrMatrix = corrcoef(numericData, 'Rows', 'complete');
varNames = {'Humidity', 'Temperature', 'AQI', 'pH', 'Turbidity'};

fprintf('Correlation Matrix:\n');
fprintf('%-12s', '');
for i = 1:length(varNames)
    fprintf('%-12s', varNames{i});
end
fprintf('\n');
for i = 1:length(varNames)
    fprintf('%-12s', varNames{i});
    for j = 1:length(varNames)
        fprintf('%-12.3f', corrMatrix(i,j));
    end
    fprintf('\n');
end

% Identify strong correlations (|r| > 0.7)
fprintf('\nStrong Correlations (|r| > 0.7):\n');
for i = 1:length(varNames)
    for j = i+1:length(varNames)
        if abs(corrMatrix(i,j)) > 0.7
            fprintf('%s <-> %s: r=%.3f\n', varNames{i}, varNames{j}, corrMatrix(i,j));
        end
    end
end

% === 4. PREDICTIVE ANALYTICS ===
fprintf('\n=== PREDICTIVE ANALYTICS ===\n');

% Moving Average Predictions
windowSize = 5;
predictedAQI = movmean(AQI, windowSize, 'Endpoints', 'shrink');
predictedTemp = movmean(Temperature, windowSize, 'Endpoints', 'shrink');
predictedHumidity = movmean(Humidity, windowSize, 'Endpoints', 'shrink');

% Calculate prediction accuracy (RMSE)
rmseAQI = sqrt(mean((AQI - predictedAQI).^2, 'omitnan'));
rmseTemp = sqrt(mean((Temperature - predictedTemp).^2, 'omitnan'));
rmseHumidity = sqrt(mean((Humidity - predictedHumidity).^2, 'omitnan'));

fprintf('Moving Average Prediction RMSE:\n');
fprintf('  AQI: %.3f\n', rmseAQI);
fprintf('  Temperature: %.3f°C\n', rmseTemp);
fprintf('  Humidity: %.3f%%\n', rmseHumidity);

% === 5. CATEGORICAL DATA ANALYSIS ===
fprintf('\n=== CATEGORICAL DATA ANALYSIS ===\n');

% Convert to categorical if they're cell arrays
if iscell(AirQuality)
    AirQualityCat = categorical(AirQuality);
else
    AirQualityCat = categorical(string(AirQuality));
end

if iscell(WaterQuality)
    WaterQualityCat = categorical(WaterQuality);
else
    WaterQualityCat = categorical(string(WaterQuality));
end

% Air Quality Distribution
airQualCategories = categories(AirQualityCat);
airQualCounts = countcats(AirQualityCat);
fprintf('Air Quality Distribution:\n');
for i = 1:length(airQualCategories)
    percentage = (airQualCounts(i) / sum(airQualCounts)) * 100;
    fprintf('  %s: %d readings (%.1f%%)\n', airQualCategories{i}, airQualCounts(i), percentage);
end

% Water Quality Distribution
waterQualCategories = categories(WaterQualityCat);
waterQualCounts = countcats(WaterQualityCat);
fprintf('\nWater Quality Distribution:\n');
for i = 1:length(waterQualCategories)
    percentage = (waterQualCounts(i) / sum(waterQualCounts)) * 100;
    fprintf('  %s: %d readings (%.1f%%)\n', waterQualCategories{i}, waterQualCounts(i), percentage);
end

% === 6. ANOMALY DETECTION ===
fprintf('\n=== ANOMALY DETECTION ===\n');

% Detect outliers using z-score method
zThreshold = 3;

% AQI outliers
zScoreAQI = abs((AQI - mean(AQI, 'omitnan')) / std(AQI, 'omitnan'));
aqiOutliers = sum(zScoreAQI > zThreshold);
fprintf('AQI Outliers (z>3): %d (%.1f%%)\n', aqiOutliers, (aqiOutliers/length(AQI))*100);

% Temperature outliers
zScoreTemp = abs((Temperature - mean(Temperature, 'omitnan')) / std(Temperature, 'omitnan'));
tempOutliers = sum(zScoreTemp > zThreshold);
fprintf('Temperature Outliers: %d (%.1f%%)\n', tempOutliers, (tempOutliers/length(Temperature))*100);

% Turbidity outliers
zScoreTurb = abs((Turbidity - mean(Turbidity, 'omitnan')) / std(Turbidity, 'omitnan'));
turbOutliers = sum(zScoreTurb > zThreshold);
fprintf('Turbidity Outliers: %d (%.1f%%)\n', turbOutliers, (turbOutliers/length(Turbidity))*100);

% === 7. TREND ANALYSIS ===
fprintf('\n=== TREND ANALYSIS ===\n');

% Calculate trends using linear regression
x = (1:length(AQI))';

% Remove NaN values for regression
validAQI = ~isnan(AQI);
if sum(validAQI) > 1
    pAQI = polyfit(x(validAQI), AQI(validAQI), 1);
    fprintf('AQI Trend: %.4f units/reading', pAQI(1));
    if pAQI(1) > 0
        fprintf(' (Increasing)\n');
    elseif pAQI(1) < 0
        fprintf(' (Decreasing)\n');
    else
        fprintf(' (Stable)\n');
    end
end

validTemp = ~isnan(Temperature);
if sum(validTemp) > 1
    pTemp = polyfit(x(validTemp), Temperature(validTemp), 1);
    fprintf('Temperature Trend: %.4f °C/reading', pTemp(1));
    if pTemp(1) > 0
        fprintf(' (Increasing)\n');
    else
        fprintf(' (Decreasing)\n');
    end
end

fprintf('\n=== ANALYSIS COMPLETE ===\n');