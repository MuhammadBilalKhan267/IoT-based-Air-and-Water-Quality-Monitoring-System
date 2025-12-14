% ===================================================================
% THINGSPEAK ENVIRONMENTAL MONITORING - VISUALIZATION DASHBOARD
% For MATLAB Visualization App
% ===================================================================

% === 1. DATA READING ===
channelID = 12345678;
readAPIKey = 'yourApiKey';

% Read data from ThingSpeak
data = thingSpeakRead(channelID, 'ReadKey', readAPIKey, 'NumPoints', 100);

% Extract fields
Humidity = data(:,1);
Temperature = data(:,2);
AQI = data(:,3);
pH = data(:,4);
Turbidity = data(:,5);
AirQuality = data(:,6);
WaterQuality = data(:,7);

% Convert to categorical
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

% === 2. CREATE COMPREHENSIVE DASHBOARD (SINGLE FIGURE) ===
figure('Position', [50, 50, 1600, 1000], 'Color', 'white');

% --- ROW 1: Time Series Plots ---
% Humidity
subplot(4, 4, 1);
plot(Humidity, 'b-', 'LineWidth', 2);
title('Humidity Over Time', 'FontSize', 10, 'FontWeight', 'bold');
xlabel('Reading #', 'FontSize', 9);
ylabel('Humidity (%)', 'FontSize', 9);
grid on;
ylim([min(Humidity)-5, max(Humidity)+5]);

% Temperature
subplot(4, 4, 2);
plot(Temperature, 'r-', 'LineWidth', 2);
title('Temperature Over Time', 'FontSize', 10, 'FontWeight', 'bold');
xlabel('Reading #', 'FontSize', 9);
ylabel('Temperature (°C)', 'FontSize', 9);
grid on;

% AQI with Prediction
subplot(4, 4, 3);
plot(AQI, 'g-', 'LineWidth', 1.5);
hold on;
predictedAQI = movmean(AQI, 5, 'Endpoints', 'shrink');
plot(predictedAQI, 'm--', 'LineWidth', 2);
title('AQI: Actual vs Predicted', 'FontSize', 10, 'FontWeight', 'bold');
xlabel('Reading #', 'FontSize', 9);
ylabel('AQI', 'FontSize', 9);
legend('Actual', 'MA Predicted', 'Location', 'best', 'FontSize', 8);
grid on;

% pH
subplot(4, 4, 4);
plot(pH, 'c-', 'LineWidth', 2);
hold on;
yline(7, 'k--', 'Neutral', 'LineWidth', 1.5, 'FontSize', 8);
title('pH Over Time', 'FontSize', 10, 'FontWeight', 'bold');
xlabel('Reading #', 'FontSize', 9);
ylabel('pH Level', 'FontSize', 9);
grid on;

% --- ROW 2: Histograms ---
% Turbidity
subplot(4, 4, 5);
histogram(Turbidity, 15, 'FaceColor', [0.8, 0.4, 0.1], 'EdgeColor', 'black');
title('Turbidity Distribution', 'FontSize', 10, 'FontWeight', 'bold');
xlabel('Turbidity (NTU)', 'FontSize', 9);
ylabel('Frequency', 'FontSize', 9);
grid on;

% Temperature Distribution
subplot(4, 4, 6);
histogram(Temperature, 15, 'FaceColor', [0.8, 0.2, 0.2], 'EdgeColor', 'black');
title('Temperature Distribution', 'FontSize', 10, 'FontWeight', 'bold');
xlabel('Temperature (°C)', 'FontSize', 9);
ylabel('Frequency', 'FontSize', 9);
grid on;

% Humidity Distribution
subplot(4, 4, 7);
histogram(Humidity, 15, 'FaceColor', [0.2, 0.4, 0.8], 'EdgeColor', 'black');
title('Humidity Distribution', 'FontSize', 10, 'FontWeight', 'bold');
xlabel('Humidity (%)', 'FontSize', 9);
ylabel('Frequency', 'FontSize', 9);
grid on;

% AQI Distribution
subplot(4, 4, 8);
histogram(AQI, 15, 'FaceColor', [0.3, 0.7, 0.3], 'EdgeColor', 'black');
title('AQI Distribution', 'FontSize', 10, 'FontWeight', 'bold');
xlabel('AQI', 'FontSize', 9);
ylabel('Frequency', 'FontSize', 9);
grid on;

% --- ROW 3: Correlation & Scatter Plots ---
% Correlation Heatmap
subplot(4, 4, 9);
numericData = [Humidity, Temperature, AQI, pH, Turbidity];
corrMatrix = corrcoef(numericData, 'Rows', 'complete');
imagesc(corrMatrix);
colorbar;
colormap(jet);
caxis([-1 1]);
varNames = {'Humid', 'Temp', 'AQI', 'pH', 'Turb'};
set(gca, 'XTick', 1:5, 'XTickLabel', varNames, 'XTickLabelRotation', 45, 'FontSize', 8);
set(gca, 'YTick', 1:5, 'YTickLabel', varNames, 'FontSize', 8);
title('Correlation Matrix', 'FontSize', 10, 'FontWeight', 'bold');

% Add correlation values
for i = 1:5
    for j = 1:5
        text(j, i, sprintf('%.2f', corrMatrix(i,j)), ...
            'HorizontalAlignment', 'center', 'Color', 'white', 'FontWeight', 'bold', 'FontSize', 8);
    end
end

% Scatter: Temperature vs Humidity (colored by AQI)
subplot(4, 4, 10);
scatter(Temperature, Humidity, 50, AQI, 'filled');
colorbar;
title('Temp vs Humidity (by AQI)', 'FontSize', 10, 'FontWeight', 'bold');
xlabel('Temperature (°C)', 'FontSize', 9);
ylabel('Humidity (%)', 'FontSize', 9);
grid on;

% Scatter: pH vs Turbidity
subplot(4, 4, 11);
scatter(pH, Turbidity, 60, 'filled', 'MarkerFaceAlpha', 0.6);
title('pH vs Turbidity', 'FontSize', 10, 'FontWeight', 'bold');
xlabel('pH Level', 'FontSize', 9);
ylabel('Turbidity (NTU)', 'FontSize', 9);
grid on;

% Scatter: Temperature vs AQI
subplot(4, 4, 12);
scatter(Temperature, AQI, 60, 'filled', 'MarkerFaceAlpha', 0.6);
title('Temperature vs AQI', 'FontSize', 10, 'FontWeight', 'bold');
xlabel('Temperature (°C)', 'FontSize', 9);
ylabel('AQI', 'FontSize', 9);
grid on;

% --- ROW 4: Categorical Data & Trends ---
% Air Quality Distribution
subplot(4, 4, 13);
airCounts = countcats(AirQualityCat);
airCategories = categories(AirQualityCat);
bar(airCounts, 'FaceColor', [0.4, 0.6, 0.8]);
set(gca, 'XTickLabel', airCategories, 'XTickLabelRotation', 45, 'FontSize', 8);
title('Air Quality Distribution', 'FontSize', 10, 'FontWeight', 'bold');
ylabel('Count', 'FontSize', 9);
grid on;

% Water Quality Distribution
subplot(4, 4, 14);
waterCounts = countcats(WaterQualityCat);
waterCategories = categories(WaterQualityCat);
bar(waterCounts, 'FaceColor', [0.2, 0.8, 0.6]);
set(gca, 'XTickLabel', waterCategories, 'XTickLabelRotation', 45, 'FontSize', 8);
title('Water Quality Distribution', 'FontSize', 10, 'FontWeight', 'bold');
ylabel('Count', 'FontSize', 9);
grid on;

% Temperature Trend with Linear Fit
subplot(4, 4, 15);
x = (1:length(Temperature))';
validTemp = ~isnan(Temperature);
if sum(validTemp) > 1
    pTemp = polyfit(x(validTemp), Temperature(validTemp), 1);
    trendTemp = polyval(pTemp, x);
    plot(Temperature, 'bo-', 'LineWidth', 1);
    hold on;
    plot(trendTemp, 'r--', 'LineWidth', 2);
    title('Temperature Trend', 'FontSize', 10, 'FontWeight', 'bold');
    xlabel('Reading #', 'FontSize', 9);
    ylabel('Temperature (°C)', 'FontSize', 9);
    legend('Actual', 'Trend', 'Location', 'best', 'FontSize', 8);
    grid on;
end

% AQI Trend with Linear Fit
subplot(4, 4, 16);
validAQI = ~isnan(AQI);
if sum(validAQI) > 1
    pAQI = polyfit(x(validAQI), AQI(validAQI), 1);
    trendAQI = polyval(pAQI, x);
    plot(AQI, 'go-', 'LineWidth', 1);
    hold on;
    plot(trendAQI, 'r--', 'LineWidth', 2);
    title('AQI Trend', 'FontSize', 10, 'FontWeight', 'bold');
    xlabel('Reading #', 'FontSize', 9);
    ylabel('AQI', 'FontSize', 9);
    legend('Actual', 'Trend', 'Location', 'best', 'FontSize', 8);
    grid on;
end

% Overall title
sgtitle('Environmental Monitoring Dashboard - ThingSpeak Data Analysis', ...
    'FontSize', 14, 'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.6]);