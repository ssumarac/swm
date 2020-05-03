clear all; close all; clc;
%
%% LOAD BENCHMARK DATA
[X, Fs, GT] = GetData(1);

%% SET PARAMETERS
window_size = 2e-3*Fs;
threshold = 4*median(abs(X))/0.6745;
cut = 1;
to_plot = 0;

%% DETECT SPIKES
[spikes index window_size] = GetSpikes(X,window_size,threshold,cut);

%% INITIAL CLUSTERING
[coeff,score,latent] = pca(spikes);
features = [score(:,1) score(:,2)];

minPts = size(spikes,2) - 1;
epsilon = clusterDBSCAN.estimateEpsilon(spikes,2,minPts);

label = dbscan(spikes,epsilon,minPts);

%% BUILD OVERLAPPING TEMPLATES

[overlapped_template,overlapped_locations] = GetTemplates(window_size,spikes,label,to_plot);

%% TEMPLATE MATCHING

overlapped_spikes = spikes(label == -1,:);

[label_shifted, label_detected, index_shifted, PsC_score] = CorrelationMatching(overlapped_spikes,overlapped_template,label,window_size,index);

%% PRE-EVALUATION
output_shifted = [index_shifted; label_shifted]';

label(label == -1) = label_detected;
output_detected = [index' label];

output = [output_shifted; output_detected];
output = sortrows(output);


%%  EVALUATE PERFORMANCE

[precision recall accuracy] = EvaluatePerformance(GT(:,1), GT(:,2), output(:,1), output(:,2), 1e-3*Fs);
fprintf('SNR = %d\n',ceil(mean(max(spikes'))/(median(abs(X))/0.6745)));


