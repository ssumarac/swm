clear all; close all; clc;

%% LOAD DATA
[X, Fs, GT] = GetData(1);

%% SET PARAMETERS
window_size = 3e-3*Fs;
threshold = 4*median(abs(X))/0.6745;
clusters = 3;
delta_t = 1e-3*Fs;

to_plot = 0;

%% DETECT SPIKES
[spikes, index] = GetSpikes(X,window_size,threshold);
index = index';

%% DO CLUSTERING
[coeff,score,latent] = pca(spikes);
features = [score(:,1) score(:,2)];

rng('default')
kmeans_label = kmeans(features,clusters);

%% BUILD OVERLAPPING TEMPLATES
[overlapped_template,template,undetected_overlaps, overlapped_locations] = GetTemplates(window_size,spikes,kmeans_label,threshold,to_plot);

%% CORRELATION TEMPLATE MATCHING
template_combined = [overlapped_template; template];

[label_detected,template_label, PsC_score] = CorrelationTemplateMatching(spikes,template_combined,kmeans_label,window_size,undetected_overlaps,overlapped_locations);

%%  EVALUATE BENCHMARK PERFORMANCE

GT(:,1) = GT(:,1) + 22;

fprintf('\nBENCHMARK\n');
[precision, recall, accuracy] = EvaluatePerformance(GT(:,1), GT(:,2), index, label_detected, delta_t);

%%  EVALUATE STANDARD PERFORMANCE
fprintf('\nSTANDARD\n');
[precision, recall, accuracy] = EvaluatePerformance(GT(:,1), GT(:,2), index, kmeans_label, delta_t);

fprintf('\nFor SNR = %d\n',ceil(mean(max(spikes'))/(median(abs(X))/0.6745)));
