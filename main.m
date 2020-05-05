clear all; close all; clc;

%% LOAD DATA
[X, Fs, GT] = GetData(1);

%% SET PARAMETERS
initial_window_size = 6e-3*Fs;
threshold = 4*median(abs(X))/0.6745;
clusters = 3;
error_parameter = 2;
delta_t = 1e-3*Fs;

cut = 1;
isolated = 1;
to_plot = 0;

%% DETECT SPIKES
[spikes, index, window_size,isolated_logical] = GetSpikes(X,initial_window_size,threshold,cut,isolated);
index = index';

isolated_spikes = spikes(isolated_logical,:);
isolated_index = index(isolated_logical);

overlapped_spikes = spikes(not(isolated_logical),:);
overlapped_index = index(not(isolated_logical));

%% DO CLUSTERING
[coeff,score,latent] = pca(spikes);
features = [score(:,1) score(:,2)];

rng('default')
label = kmeans(features,clusters);

%% BUILD OVERLAPPING TEMPLATES
[overlapped_template,template,overlapped_locations] = GetTemplates(window_size,spikes,label,to_plot);

%% CORRELATION TEMPLATE MATCHING
template_combined = [overlapped_template; template];

[label_shifted_index, label_shifted, index_shifted, label_detected, PsC_score] = CorrelationTemplateMatching(overlapped_spikes,overlapped_template,label,window_size,overlapped_index,overlapped_locations,index,error_parameter);

index = index - delta_t;

%%  EVALUATE STANDARD PERFORMANCE
fprintf('\nSTANDARD\n');
[precision, recall, accuracy] = EvaluatePerformance(GT(:,1), GT(:,2), index, label, delta_t);
%[precision, recall, accuracy] = EvaluatePerformance(GT(logical(GT(:,3)),1), GT(logical(GT(:,3)),2), index, label, delta_t);

%%  EVALUATE BENCHMARK PERFORMANCE

label(not(isolated_logical)) = label_detected';
label(label_shifted_index) = label_shifted(label_shifted_index);

fprintf('\nBENCHMARK\n');
[precision, recall, accuracy] = EvaluatePerformance(GT(:,1), GT(:,2), index, output(:,2), delta_t);
%[precision, recall, accuracy] = EvaluatePerformance(GT(logical(GT(:,3)),1), GT(logical(GT(:,3)),2), output(:,1), output(:,2), delta_t);

fprintf('\nFor SNR = %d\n',ceil(mean(max(spikes'))/(median(abs(X))/0.6745)));

