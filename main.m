clear all; close all; clc;

%% LOAD DATA
[X, Fs, GT] = GetData(1);

%% SET PARAMETERS
window_size = 1.5e-3*Fs;
threshold = 4*median(abs(X))/0.6745;
clusters = 3;
delta_t = 1e-3*Fs;

to_plot = 0;
clustering_method = 2;

%% DETECT SPIKES
[spikes, index] = GetSpikes(X,window_size,threshold);

%% DO CLUSTERING
[label, features] = DoClustering(spikes,clustering_method,clusters);

figure;
gscatter(features(:,1),features(:,2),label)

%% BUILD OVERLAPPING TEMPLATES
templates = GetTemplates(window_size,spikes,label,to_plot);

%% CORRELATION TEMPLATE MATCHING
[label_template, PsC_score,overlapped_logical] = CorrelationTemplateMatching(spikes,templates,label,window_size);

%%  EVALUATE BENCHMARK PERFORMANCE

%label_template(isolated_logical) = label(isolated_logical);

output_benchmark = [index label_template overlapped_logical];

fprintf('\nBENCHMARK\n');
[precision, recall, accuracy] = EvaluatePerformance(GT(:,1), GT(:,2), output_benchmark(:,1), output_benchmark(:,2), delta_t);
%[precision, recall, accuracy] = EvaluatePerformance(GT(logical(GT(:,3)),1), GT(logical(GT(:,3)),2), output_benchmark(logical(output_benchmark(:,3)),1), output_benchmark(logical(output_benchmark(:,3)),2), delta_t);

%%  EVALUATE STANDARD PERFORMANCE

output_standard = [index label overlapped_logical];

fprintf('\nSTANDARD\n');
[precision, recall, accuracy] = EvaluatePerformance(GT(:,1), GT(:,2), output_standard(:,1), output_standard(:,2), delta_t);
%[precision, recall, accuracy] = EvaluatePerformance(GT(logical(GT(:,3)),1), GT(logical(GT(:,3)),2), output_standard(logical(output_standard(:,3)),1), output_standard(logical(output_standard(:,3)),2), delta_t);

fprintf('\nFor SNR = %d\n',ceil(mean(max(spikes'))/(median(abs(X))/0.6745)));

%% PLOTS

close all

t = (1:length(X))/Fs;

figure; 
plot(t,X); hold on;
plot(t(index),X(index),'r*'); hold on;
plot(t,threshold*ones(1,length(X)),'r','LineWidth',2);

spikes_isolated = spikes(not(overlapped_logical),:);
label_isolated = label_template(not(overlapped_logical));

spikes_overlapped = spikes(overlapped_logical,:); 
label_overlapped = label_template(overlapped_logical);

figure;
plot(1:window_size,spikes_isolated(label_isolated == 1,:),'r'); hold on;
plot(1:window_size,spikes_isolated(label_isolated == 2,:),'g'); hold on;
plot(1:window_size,spikes_isolated(label_isolated == 3,:),'b'); hold on;

figure;
plot(1:window_size,spikes_overlapped(label_overlapped == 1,:),'r'); hold on;
plot(1:window_size,spikes_overlapped(label_overlapped == 2,:),'g'); hold on;
plot(1:window_size,spikes_overlapped(label_overlapped == 3,:),'b'); hold on;