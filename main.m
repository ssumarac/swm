clear all; close all; clc;

ISI_tot = [];
n_match_b = zeros(1,16);
n_miss_b = zeros(1,16);
n_fp_b = zeros(1,16);

n_match_s = zeros(1,16);
n_miss_s = zeros(1,16);
n_fp_s = zeros(1,16);

for h = 1
    %% LOAD DATA
    [X, Fs, GT] = GetData(h);
    
    %% SET PARAMETERS
    window_size_init = 3e-3*Fs;
    threshold = 4*median(abs(X))/0.6745;
    clusters = 3;
    delta_t = 1e-3*Fs;
    corr_cutoff = 0.9;
    
    to_plot = 0;
    to_record = 0;
    clustering_method = 1;
    overlapped = 0;
    
    %% DETECT SPIKES
    [spikes_init, spikes, index] = GetSpikes(X,window_size_init,threshold);
    
    %% ISOLATION
    [ISI, OL] = IsolateSpikes(index,1,Fs);
    [ISI_GT, OL_GT] = IsolateSpikes(GT(:,1),1,Fs);
    
    ISI_tot = [ISI_tot; ISI'];
    
    %     figure;
    %     plot((1:window_size_init/2)/Fs,spikes(not(OL),:),'k');
    %     title('Extracted Spikes from Filtered Signal')
    %     xlabel('Time (ms)')
    %     ylabel('Voltage (uV)')
    %
    figure
    histfit(ISI_tot,100,'exponential'); hold on;
    histogram(ISI_tot,'Normalization','probability');
    title('Interspike Interval (ISI)')
    xlabel('Time (ms)')
    ylabel('Probability')
    legend('Histogram','Fitted Distribution')
    
    %% DO CLUSTERING
    [label, features] = DoClustering(spikes,clustering_method,clusters,corr_cutoff);
    
    %% BUILD OVERLAPPING TEMPLATES
    [templates, window_size] = GetTemplates(window_size_init,spikes_init,label,to_record);
    
    %% TEMPLATE MATCHING
    [label_template, min_distance,overlapped_label] = TemplateMatching(spikes,templates,label,window_size);
    
    %%  EVALUATE BENCHMARK PERFORMANCE
    if overlapped == 1
        GT = GT(OL_GT,:);
    end
    
    label_benchmark = label_template;
    %label_benchmark(label == -1) = label_template(label == -1);
    
    output_benchmark = [index label_benchmark];
    if overlapped == 1
        output_benchmark = output_benchmark(OL,:);
    end
    
    fprintf('\nBENCHMARK\n');
    [n_match_b(h), n_miss_b(h), n_fp_b(h)] = EvaluatePerformance(GT(:,1), GT(:,2), output_benchmark(:,1), output_benchmark(:,2), delta_t);
    
    
    %%  EVALUATE STANDARD PERFORMANCE
    
    output_standard = [index label];
    if overlapped == 1
        output_standard = output_standard(OL,:);
    end
    
    fprintf('\nSTANDARD\n');
    [n_match_s(h), n_miss_s(h), n_fp_s(h)] = EvaluatePerformance(GT(:,1), GT(:,2), output_standard(:,1), output_standard(:,2), delta_t);
    
    SNR(h) = ceil(mean(max(spikes'))/(median(abs(X))/0.6745));
    
    fprintf('\nFor SNR = %d\n',SNR(h));
    
    %% PLOTS
    
    if to_plot == 1
        
        %% Spike Detection
        t = (1:length(X))/Fs;
        w = (1:window_size)/Fs;
        w2 = (1:window_size_init)/Fs;
        
        figure;
        plot(t,X,'k'); hold on;
        plot(t(index),X(index),'r*'); hold on;
        plot(t,threshold*ones(1,length(X)),'r','LineWidth',2);
        title('Filtered Signal from Single Electrode Channel')
        xlabel('Time (s)')
        ylabel('Voltage (uV)')
        legend('Filtered Data','Detected Peaks','Threshold')
        
        figure;
        plot(w,spikes,'k');
        title('Extracted Spikes from Filtered Signal')
        xlabel('Time (ms)')
        ylabel('Voltage (uV)')
        
        figure;
        plot(w2,spikes_init,'k');
        title('Extracted Spikes from Filtered Signal')
        xlabel('Time (ms)')
        ylabel('Voltage (uV)')
        
        %% Initial Spike Classification
        figure;
        gscatter(features(:,1),features(:,2),label)
        title(sprintf('Feature Space %i',h))
        xlabel('First Principle Component')
        ylabel('Second Principle Component')
        
        
        %% Build Templates
        figure;
        plot(w,median(spikes(label == 1,:)),'r'); hold on;
        plot(w,median(spikes(label == 2,:)),'g'); hold on;
        plot(w,median(spikes(label == 3,:)),'b');
        title('Initial Templates')
        xlabel('Time (s)')
        ylabel('Voltage (uV)')
        legend('Spike Template #1','Spike Template #2','Spike Template #3')
        
        figure;
        plot(w,rmoutliers(spikes(label == 1,:)),'r');
        title('Spike Cluster #1')
        xlabel('Time (s)')
        ylabel('Voltage (uV)')
        
        figure
        plot(w,rmoutliers(spikes(label == 2,:)),'g');
        title('Spike Cluster #2')
        xlabel('Time (s)')
        ylabel('Voltage (uV)')
        
        figure
        plot(w,rmoutliers(spikes(label == 3,:)),'b');
        title('Spike Cluster #3')
        xlabel('Time (s)')
        ylabel('Voltage (uV)')
        
        
        %% Template Matching
        figure
        subplot(1,3,1)
        plot(w,spikes(1024,:),'b'); hold on;
        plot(w,templates(overlapped_label(1024),:),'k');
        title('Spike #1024')
        xlabel('Time (ms)')
        ylabel('Voltage (uV)')
        axis([1/Fs window_size/Fs -1.5 1.5]);
        legend('Detected Spike','Best Match Template')
        
        subplot(1,3,2)
        plot(w,spikes(2466,:),'g'); hold on;
        plot(w,templates(overlapped_label(2466),:),'k');
        title('Spike #2466')
        xlabel('Time (ms)')
        ylabel('Voltage (uV)')
        axis([1/Fs window_size/Fs -1.5 1.5]);
        legend('Detected Spike','Best Match Template')
        
        subplot(1,3,3)
        plot(w,spikes(1585,:),'r'); hold on;
        plot(w,templates(overlapped_label(1585),:),'k');
        title('Spike #1585')
        xlabel('Time (ms)')
        ylabel('Voltage (uV)')
        axis([1/Fs window_size/Fs -1.5 1.5]);
        legend('Detected Spike','Best Match Template')
        
    end
    
    n_GT(h) = length(GT);
    
%     figure
%     subplot(1,2,1)
%     gscatter(features(:,1),features(:,2),label)
%     title('Low-dimensional Space')
%     xlabel('First Principle Component')
%     ylabel('Second Principle Component')
%     
%     subplot(1,2,2)
%     plot(w,median(spikes(label == 1,:)),'r'); hold on;
%     plot(w,median(spikes(label == 2,:)),'g'); hold on;
%     plot(w,median(spikes(label == 3,:)),'b');
%     title('Template waveforms')
%     xlabel('Time (s)')
%     ylabel('Voltage (uV)')
%     legend('1','2','3')
    
end

n_match_b = n_match_b';
n_miss_b = n_miss_b';
n_fp_b = n_fp_b';

n_match_s = n_match_s';
n_miss_s = n_miss_s';
n_fp_s = n_fp_s';

precision_b = n_match_b./(n_match_b + n_fp_b);
recall_b = n_match_b./(n_match_b + n_miss_b);
accuracy_b = n_match_b./(n_match_b + n_miss_b + n_fp_b);

precision_s = n_match_s./(n_match_s + n_fp_s);
recall_s = n_match_s./(n_match_s + n_miss_s);
accuracy_s = n_match_s./(n_match_s + n_miss_s + n_fp_s);

results = [precision_b recall_b accuracy_b precision_s recall_s accuracy_s];

improvement_precision = mean(precision_b - precision_s)*100
improvement_recall = mean(recall_b - recall_s)*100
improvement_accuracy = mean(accuracy_b - accuracy_s)*100

