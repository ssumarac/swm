clear all; close all; clc;
%
%% LOAD BENCHMARK DATA
[X, Fs, GT] = GetData(1);

%% SET PARAMETERS
window_size = 2e-3*Fs;
threshold = 4*median(abs(X))/0.6745;
cut = 1;
method = 1;

%% DETECT SPIKES
[spikes index window_size] = GetSpikes(X,window_size,threshold,cut);

%% CLUSTERING
[coeff,score,latent] = pca(spikes);
features = [score(:,1) score(:,2)];

if method == 1
    minPts = size(spikes,2) - 1;
    epsilon = clusterDBSCAN.estimateEpsilon(spikes,2,minPts);
    idx = dbscan(features,epsilon,minPts);
elseif method == 2
    rng('default')
    idx = kmeans(features,3);
end

%% EVALUATE PERFORMANCE

[precision recall accuracy] = EvaluatePerformance(GT(:,1), GT(:,2), index, idx, 1e-3*Fs);
fprintf('SNR = %d\n',ceil(mean(max(spikes'))/(median(abs(X))/0.6745)));

%% PLOTS
%
% figure
% scatter(score(:,1),score(:,2),'.');
% title('Dimentional Reduction In Feature Space')
% xlabel('1st Principal Component')
% ylabel('2nd Principal Component')

% figure
% gscatter(score(:,1),score(:,2),idx);

% for a = 1:max(idx)
%     spks_tot(a) = sum(idx == a);
%     fprintf('Spike %d: %d\n', a, spks_tot(a));
% end
%
% fprintf('Total Spikes: %d\n',sum(spks_tot));

% colour = ['r','b','g'];
%
% figure
% for b = 1:max(idx)
%     subplot(max(idx),1,b);
%     plot(1:window_size, spikes(idx == b,:), colour(b)); hold on;
%     title('Sorting of Extracted Spike Waveforms')
%     xlabel('Samples')
%     ylabel('Voltage(uV)')
% end
