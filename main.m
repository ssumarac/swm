clear all; close all; clc;

%% LOAD DATA
[X, Fs, GT] = GetData(3);

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
[overlapped_template,template,undetected_overlaps] = GetTemplates(window_size,spikes,kmeans_label,threshold,to_plot);

%% CORRELATION TEMPLATE MATCHING
template_combined = [overlapped_template; template];

[label_detected,template_label, PsC_score,index_shifted,label_shifted] = CorrelationTemplateMatching(spikes,template_combined,kmeans_label,window_size,undetected_overlaps,index);

%%  EVALUATE BENCHMARK PERFORMANCE

GT(:,1) = GT(:,1) + 22;

temp = [index; index_shifted'];
temp2 = [label_detected'; label_shifted'];

output_benchmark  = sortrows([temp temp2]);

fprintf('\nBENCHMARK\n');
[precision, recall, accuracy] = EvaluatePerformance(GT(:,1), GT(:,2), output_benchmark(:,1), output_benchmark(:,2), delta_t);

%%  EVALUATE STANDARD PERFORMANCE

output_standard = [index kmeans_label];

fprintf('\nSTANDARD\n');
[precision, recall, accuracy] = EvaluatePerformance(GT(:,1), GT(:,2), output_standard(:,1), output_standard(:,2), delta_t);

fprintf('\nFor SNR = %d\n',ceil(mean(max(spikes'))/(median(abs(X))/0.6745)));
