clear all; close all; clc;

for h = 1:16
    
    %% LOAD DATA
    [X, Fs, GT] = GetData(h);
    
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
    
    [label_detected,template_label, PsC_score,index_shifted,label_shifted,overlapped_index,overlapped_logical] = CorrelationTemplateMatching(spikes,template_combined,kmeans_label,window_size,undetected_overlaps,index);
    
    %%  EVALUATE BENCHMARK PERFORMANCE
    
    GT(:,1) = GT(:,1) + 22;
    
    temp = [index; index_shifted'];
    temp2 = [label_detected'; label_shifted'];
    temp3 = [overlapped_logical'; ones(length(index_shifted),1)];
    
    output_benchmark = sortrows([temp temp2 temp3]);
    
    fprintf('\nBENCHMARK\n');
    %[precision, recall, accuracy] = EvaluatePerformance(GT(:,1), GT(:,2), output_benchmark(:,1), output_benchmark(:,2), delta_t);
    [precision, recall, accuracy] = EvaluatePerformance(GT(logical(GT(:,3)),1), GT(logical(GT(:,3)),2), output_benchmark(logical(output_benchmark(:,3)),1), output_benchmark(logical(output_benchmark(:,3)),2), delta_t);
    
    %%  EVALUATE STANDARD PERFORMANCE
    
    output_standard = [index kmeans_label overlapped_logical'];
    
    fprintf('\nSTANDARD\n');
    %[precision, recall, accuracy] = EvaluatePerformance(GT(:,1), GT(:,2), output_standard(:,1), output_standard(:,2), delta_t);
    [precision, recall, accuracy] = EvaluatePerformance(GT(logical(GT(:,3)),1), GT(logical(GT(:,3)),2), output_standard(logical(output_standard(:,3)),1), output_standard(logical(output_standard(:,3)),2), delta_t);
    
    fprintf('\nFor SNR = %d\n',ceil(mean(max(spikes'))/(median(abs(X))/0.6745)));
    
end