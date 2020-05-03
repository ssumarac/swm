clear all; close all; clc;

%% LOAD BENCHMARK DATA

load('C_Easy1_noise005')

Fs = 1/samplingInterval*1e3;
X = data;

% set parameters
window_size = 2e-3*Fs;
threshold = 4*median(abs(X))/0.6745;
refractory_period = window_size/2; %in ms

%% DETECT SPIKES
[spikes locs] = getspikes(X,window_size,threshold,Fs,refractory_period);

spikes = spikes(:,1+refractory_period/2:window_size-refractory_period/2);

%% DIMENSION REDUCTION
[coeff,score,latent] = pca(spikes);
features = [score(:,1) score(:,2)];

figure
scatter(score(:,1),score(:,2),'.');
title('Dimentional Reduction In Feature Space')
xlabel('1st Principal Component')
ylabel('2nd Principal Component')

%% CLUSTERING

% minPts = size(spikes,2) - 1;
% epsilon = clusterDBSCAN.estimateEpsilon(spikes,2,minPts);
% 
% idx = dbscan(spikes,epsilon,minPts);

rng(1)
idx = kmeans(features,3);
% 
figure
gscatter(score(:,1),score(:,2),idx);
% 
% for a = 1:max(idx)
%     spks_tot(a) = sum(idx == a);
%     fprintf('Spike %d: %d\n', a, spks_tot(a));
% end
% 
% fprintf('Total Spikes: %d\n',sum(spks_tot));

%% PLOTS

colour = ['r','b','g'];

figure
for b = 1:max(idx)
    subplot(max(idx),1,b);
    plot(1:window_size/2, spikes(idx == b,:), colour(b)); hold on;
    title('Sorting of Extracted Spike Waveforms')
    xlabel('Samples')
    ylabel('Voltage(uV)')
end

%% LOAD GROUND TRUTH

spike_times = cell2mat(spike_times);
spike_class_1 = cell2mat(spike_class(1))';
spike_class_2 = cell2mat(spike_class(2))';
spike_class_3 = cell2mat(spike_class(3))';
spikesgt = getspikesgt(X,window_size,spike_times);
for v = 1:length(spikesgt)
    [max_gt loc_gt(v)] = max(spikesgt(7,:));
end
spike_times = spike_times + mean(loc_gt);

%% EVALUATE PERFORMANCE

[precision recall accuracy] = evaluate(spike_times, spike_class_1, locs, idx, 1e-3*Fs);

fprintf('SNR = %d\n',ceil(mean(max(spikes'))/(median(abs(X))/0.6745)));
