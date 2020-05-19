clear all; close all; clc;

ISI_tot = [];

for h = 1:16
    %% LOAD DATA
    [X, Fs, GT] = GetData(h);
    
    %% SET PARAMETERS
    window_size_init = 3e-3*Fs;
    threshold = 4*median(abs(X))/0.6745;
    clusters = 3;
    delta_t = 1e-3*Fs;
    
    to_plot = 0;
    to_record = 0;
    clustering_method = 1;
    
    %% DETECT SPIKES
    [spikes_init, spikes, index] = GetSpikes(X,window_size_init,threshold);
    
    %% ISOLATION
    %ISI = zeros(1,length(index));
    for i = 2:length(index)
        ISI(i) = 1000*(index(i) - index(i-1))/Fs;
    end
    
    Prob_Overlapped(h) = sum(ISI < 1)/length(ISI);
    Prob_Overlapped = Prob_Overlapped';
    
    ISI_tot = [ISI_tot ISI];
    
    %% DO CLUSTERING
    [label, features] = DoClustering(spikes,clustering_method,clusters);
    
    %% BUILD OVERLAPPING TEMPLATES
    [templates, window_size, spikes] = GetTemplates(window_size_init,spikes_init,label,to_record);
    
    %% CORRELATION TEMPLATE MATCHING
    [label_template, min_distance,overlapped_label] = TemplateMatching(spikes,templates,label,window_size);
    
    %%  EVALUATE BENCHMARK PERFORMANCE
    
    output_benchmark = [index label_template];
    
    fprintf('\nBENCHMARK\n');
    [n_match_b(h), n_miss_b(h), n_fp_b(h)] = EvaluatePerformance(GT(:,1), GT(:,2), output_benchmark(:,1), output_benchmark(:,2), delta_t);
    
    
    %%  EVALUATE STANDARD PERFORMANCE
    
    output_standard = [index label];
    
    fprintf('\nSTANDARD\n');
    [n_match_s(h), n_miss_s(h), n_fp_s(h)] = EvaluatePerformance(GT(:,1), GT(:,2), output_standard(:,1), output_standard(:,2), delta_t);
    
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
        plot(w,spikes,'k');
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
    
end

n_match_b = n_match_b';
n_miss_b = n_miss_b';
n_fp_b = n_fp_b';

n_match_s = n_match_s';
n_miss_s = n_miss_s';
n_fp_s = n_fp_s';

figure
histogram(ISI_tot,'Normalization','probability')
title('Interspike Interval (ISI) of Combined Datasets')
xlabel('Time (ms)')
ylabel('Probability')
axis([-5 100 0 0.1])

Pr = sum(ISI_tot < 1)/length(ISI_tot)

%%
% X1 = GetData(1);
% X2 = GetData(2);
% X3 = GetData(3);
% X4 = GetData(4);
% X5 = GetData(5);
% X6 = GetData(6);
% X7 = GetData(7);
% X8 = GetData(8);
% X9 = GetData(9);
% X10 = GetData(10);
% X11 = GetData(11);
% X12 = GetData(12);
% X13 = GetData(13);
% X14 = GetData(14);
% X15 = GetData(15);
% X16 = GetData(16);
%
% figure;
% plot(X1(1:Fs)); hold on;
% plot(X2(1:Fs) + 3); hold on;
% plot(X3(1:Fs) + 6); hold on;
% plot(X4(1:Fs) + 9); hold on;
% plot(X5(1:Fs) + 12); hold on;
% plot(X6(1:Fs) + 15); hold on;
% plot(X7(1:Fs) + 18); hold on;
% plot(X8(1:Fs) + 21); hold on;
% plot(X9(1:Fs) + 24); hold on;
% plot(X10(1:Fs) + 27); hold on;
% plot(X11(1:Fs) + 30); hold on;
% plot(X12(1:Fs) + 33); hold on;
% plot(X13(1:Fs) + 36); hold on;
% plot(X14(1:Fs) + 39); hold on;
% plot(X15(1:Fs) + 42); hold on;
% plot(X16(1:Fs) + 45); hold on;







