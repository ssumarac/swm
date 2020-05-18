clear all; close all; clc;

%% LOAD DATA
[X, Fs, GT] = GetData(13);

%% SET PARAMETERS
window_size_init = 3e-3*Fs;
threshold = 4*median(abs(X))/0.6745;
clusters = 3;
delta_t = 1e-3*Fs;

to_plot = 0;
to_record = 0;
clustering_method = 2;

%% DETECT SPIKES
[spikes_init, index] = GetSpikes(X,window_size_init,threshold);

%% DO CLUSTERING
[label, features] = DoClustering(spikes_init,clustering_method,clusters);

%% BUILD OVERLAPPING TEMPLATES
[templates, window_size, spikes] = GetTemplates(window_size_init,spikes_init,label,to_record);

%% CORRELATION TEMPLATE MATCHING
[label_template, PsC_score,overlapped_label, overlapped_logical] = CorrelationTemplateMatching(spikes,templates,label,window_size);

%%  EVALUATE BENCHMARK PERFORMANCE

label_template(not(overlapped_logical)) = label(not(overlapped_logical));

output_benchmark = [index label_template overlapped_logical];

fprintf('\nBENCHMARK\n');
[precision, recall, accuracy] = EvaluatePerformance(GT(:,1), GT(:,2), output_benchmark(:,1), output_benchmark(:,2), delta_t);


%%  EVALUATE STANDARD PERFORMANCE

spikes_standard = GetSpikes(X,window_size,threshold);
label_standard = DoClustering(spikes_init,clustering_method,clusters);

output_standard = [index label_standard];

fprintf('\nSTANDARD\n');
[precision, recall, accuracy] = EvaluatePerformance(GT(:,1), GT(:,2), output_standard(:,1), output_standard(:,2), delta_t);

fprintf('\nFor SNR = %d\n',ceil(mean(max(spikes'))/(median(abs(X))/0.6745)));

%% PLOTS

if to_plot == 1
    %% Spike Detection
    t = (1:length(X))/Fs;
    w = (1:window_size)/Fs;
    
    figure;
    plot(t,X); hold on;
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
    title('Feature Space')
    xlabel('First Principle Component')
    ylabel('Second Principle Component')
    
    %% Build Templates
    figure;
    subplot(1,3,1)
    plot(w,spikes(label == 1,:),'r'); hold on;
    plot(w,median(spikes(label == 1,:)),'k','linewidth',2);
    title('Spike Class 1')
    xlabel('Time (s)')
    ylabel('Voltage (uV)')
    
    subplot(1,3,2)
    plot(w,spikes(label == 2,:),'g'); hold on;
    plot(w,median(spikes(label == 2,:)),'k','linewidth',2);
    title('Spike Class 1')
    xlabel('Time (s)')
    ylabel('Voltage (uV)')
    
    subplot(1,3,3)
    plot(w,spikes(label == 3,:),'b'); hold on;
    plot(w,median(spikes(label == 3,:)),'k','linewidth',2);
    title('Spike Class 1')
    xlabel('Time (s)')
    ylabel('Voltage (uV)')
    
    %% Template Matching
    figure;
    histogram(PsC_score)
    
    figure
    subplot(2,2,1);
    plot(w,spikes(2892,:),'k','linewidth',2)
    title('Detected Spike #2892')
    xlabel('Time (ms)')
    ylabel('Voltage (uV)')
    axis([1/Fs window_size/Fs -1.5 1.5]);
    
    subplot(2,2,3);
    plot(w,templates(overlapped_label(2892),:),'r','linewidth',2)
    title('Matched Template #101 Corresponding To Spike Class 1','linewidth',2)
    xlabel('Time (ms)')
    ylabel('Voltage (uV)')
    axis([1/Fs window_size/Fs -1.5 1.5]);
    
    subplot(2,2,2);
    plot(w,spikes(2466,:),'k','linewidth',2)
    title('Detected Spike #2466')
    xlabel('Time (ms)')
    ylabel('Voltage (uV)')
    axis([1/Fs window_size/Fs -1.5 1.5]);
    
    subplot(2,2,4);
    plot(w,templates(overlapped_label(2466),:),'g','linewidth',2)
    title('Matched Template #98 Corresponding To Spike Class 1','linewidth',2)
    xlabel('Time (ms)')
    ylabel('Voltage (uV)')
    axis([1/Fs window_size/Fs -1.5 1.5]);
    
    % test
    figure
    plot(w,spikes(2466,:),'k','linewidth',2)
    title('Detected Spike #2466')
    xlabel('Time (ms)')
    ylabel('Voltage (uV)')
    axis([1/Fs window_size/Fs -1.5 1.5]);
    
    rng('default')
    random_templates = randi(length(templates),5,5);
    
    figure
    for i = 1:25
            subplot(5,5,i);
            plot(w,templates(random_templates(i),:),'r','linewidth',2)
            axis([1/Fs window_size/Fs -2 2]);
    end
    
    
    %%
    
    spikes_isolated = spikes(not(overlapped_logical),:);
    label_isolated = label_template(not(overlapped_logical));
    
    spikes_overlapped = spikes(overlapped_logical,:);
    label_overlapped = label_template(overlapped_logical);
    
    figure;
    subplot(1,2,1)
    plot(w,spikes_isolated(label_isolated == 1,:),'r'); hold on;
    plot(w,spikes_isolated(label_isolated == 2,:),'g'); hold on;
    plot(w,spikes_isolated(label_isolated == 3,:),'b'); hold on;
    title('Isolated Spike Waveforms')
    xlabel('Time (s)')
    ylabel('Voltage (uV)')
    
    subplot(1,2,2)
    plot(w,spikes_overlapped(label_overlapped == 1,:),'r'); hold on;
    plot(w,spikes_overlapped(label_overlapped == 2,:),'g'); hold on;
    plot(w,spikes_overlapped(label_overlapped == 3,:),'b'); hold on;
    title('Non-Isolated (Overlapped) Spike Waveforms')
    xlabel('Time (s)')
    ylabel('Voltage (uV)')
    
end
