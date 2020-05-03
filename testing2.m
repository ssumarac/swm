clear all; close all; clc;

%% LOAD BENCHMARK DATA

load('C_Easy1_noise005')

%testchanges

Fs = 1/samplingInterval*1e3;
X = data;
t = 1:length(X);

% set parameters
window_size = 3e-3*Fs;
threshold = 4*median(abs(X))/0.6745;
refractory_period = window_size/2; %in ms

%% DETECT SPIKES
[peaks,location] = findpeaks(X,'MinPeakHeight',threshold,'MinPeakDistance',refractory_period);

%% LOAD GROUND TRUTH
spike_times = cell2mat(spike_times);
spike_class_1 = cell2mat(spike_class(1))';
spike_class_2 = cell2mat(spike_class(2))';
spike_class_3 = cell2mat(spike_class(3))';
spike_times = spike_times + 22;

spike_times = spike_times(logical(spike_class_2));
spike_class_1 = spike_class_1(logical(spike_class_2));

%% PLOT
figure
plot(t,X); hold on;
plot(t(location), X(location),'r*'); hold on;
plot(t(spike_times), X(spike_times),'bs'); hold on;
plot(t,threshold*ones(1,length(X)));
