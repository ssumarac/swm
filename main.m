clear all; close all; clc;

for h = 1
    %% LOAD DATA
    [X, Fs, GT] = GetData(h);
    
    %% SET PARAMETERS
    window_size_init = 3e-3*Fs;
    threshold = 4*median(abs(X))/0.6745;
    clusters = 3;
    delta_t = 1e-3*Fs;
    
    to_plot = 1;
    to_record = 0;
    clustering_method = 1;
    
    %% DETECT SPIKES
    [spikes_init, spikes, index] = GetSpikes(X,window_size_init,threshold);
    
    %% DO CLUSTERING
    [label, features] = DoClustering(spikes,clustering_method,clusters);
    
    %% BUILD OVERLAPPING TEMPLATES
    [templates, window_size, spikes] = GetTemplates(window_size_init,spikes_init,label,to_record);
    
    %% CORRELATION TEMPLATE MATCHING
    [label_template, min_distance,overlapped_label] = TemplateMatching(spikes,templates,label,window_size);
    
    %%  EVALUATE BENCHMARK PERFORMANCE
    
    output_benchmark = [index label_template];
    
    fprintf('\nBENCHMARK\n');
    [precision_benchmark(h), recall_benchmark(h), accuracy_benchmark(h)] = EvaluatePerformance(GT(:,1), GT(:,2), output_benchmark(:,1), output_benchmark(:,2), delta_t);
    
    
    %%  EVALUATE STANDARD PERFORMANCE
    
    output_standard = [index label];
    
    fprintf('\nSTANDARD\n');
    [precision_standard(h), recall_standard(h), accuracy_standard(h)] = EvaluatePerformance(GT(:,1), GT(:,2), output_standard(:,1), output_standard(:,2), delta_t);
    
    SNR(h) = ceil(mean(max(spikes'))/(median(abs(X))/0.6745));
    
    fprintf('\nFor SNR = %d\n',SNR(h));
    
    %% PLOTS
    
    if to_plot == 1
        
        %% Spike Detection
        t = (1:length(X))/Fs;
        w = (1:window_size)/Fs;
        
        figure;
        plot(t,X,'k'); hold on;
        plot(t(index),X(index),'r*'); hold on;
        plot(t,threshold*ones(1,length(X)),'r','LineWidth',2);
        title('Filtered Signal from Single Electrode Channel')
        xlabel('Time (s)')
        ylabel('Voltage (uV)')
        
        figure;
        plot(1:window_size,spikes);
        title('Extracted Spikes from Filtered Signal')
        xlabel('Time (s)')
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
        
        
        %% Template Construction
        
    end
    
end


%%

results_precision = [precision_standard' precision_standard'];
results_recall = [recall_standard' recall_benchmark']; 
results_accuracy = [accuracy_standard' accuracy_benchmark'];

figure;
bar(results_precision);
legend('With Module','Without Module')

figure
bar(results_recall); hold on;
legend('With Module','Without Module')

figure
bar(results_accuracy); hold on;
legend('With Module','Without Module')
