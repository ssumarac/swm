clear all; close all; clc;

for h = 1

%% LOAD DATA
[X, Fs, GT] = GetData(h);

%% SET PARAMETERS
window_size = 2e-3*Fs;
threshold = 4*median(abs(X))/0.6745;
clusters = 3;
delta_t = 1e-3*Fs;

to_plot = 0;
clustering_method = 3;

%% DETECT SPIKES
[spikes, index] = GetSpikes(X,window_size,threshold);

%% DO CLUSTERING
[label features] = DoClustering(spikes,clustering_method);

figure;
gscatter(features(:,1),features(:,2),label)

%% BUILD OVERLAPPING TEMPLATES
[overlapped_template,template] = GetTemplates(window_size,spikes,label,to_plot);

%% CORRELATION TEMPLATE MATCHING
template_combined = [overlapped_template; template];

[label_detected, PsC_score,overlapped_logical] = CorrelationTemplateMatching(spikes,template_combined,label,window_size);

%%  EVALUATE BENCHMARK PERFORMANCE

GT(:,1) = GT(:,1) + 22;

isolated_logical = not(overlapped_logical);

label_detected(isolated_logical) = label(isolated_logical);

output_benchmark = [index label_detected' overlapped_logical'];

fprintf('\nBENCHMARK\n');
[precision, recall, accuracy] = EvaluatePerformance(GT(:,1), GT(:,2), output_benchmark(:,1), output_benchmark(:,2), delta_t);
%[precision, recall, accuracy] = EvaluatePerformance(GT(logical(GT(:,3)),1), GT(logical(GT(:,3)),2), output_benchmark(logical(output_benchmark(:,3)),1), output_benchmark(logical(output_benchmark(:,3)),2), delta_t);

%%  EVALUATE STANDARD PERFORMANCE

output_standard = [index label overlapped_logical'];

fprintf('\nSTANDARD\n');
[precision, recall, accuracy] = EvaluatePerformance(GT(:,1), GT(:,2), output_standard(:,1), output_standard(:,2), delta_t);
%[precision, recall, accuracy] = EvaluatePerformance(GT(logical(GT(:,3)),1), GT(logical(GT(:,3)),2), output_standard(logical(output_standard(:,3)),1), output_standard(logical(output_standard(:,3)),2), delta_t);

fprintf('\nFor SNR = %d\n',ceil(mean(max(spikes'))/(median(abs(X))/0.6745)));

end
