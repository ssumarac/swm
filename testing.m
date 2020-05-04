clear all; close all; clc;
%
%% LOAD BENCHMARK DATA
[X, Fs, GT] = GetData(1);

%% SET PARAMETERS
window_size = 6e-3*Fs;
threshold = 4*median(abs(X))/0.6745;
cut = 0;
isolated = 1;
to_plot = 0;

%% DETECT SPIKES
[spikes, index, window_size, isolated_logical] = GetSpikes(X,window_size,threshold,cut,isolated);

isolated_spikes = spikes(isolated_logical,:);
isolated_index = index(isolated_logical);

overlapped_spikes = spikes(not(isolated_logical),:);
overlapped_index = index(not(isolated_logical));

%% ISOLATED CLUSTERING
[coeff,score,latent] = pca(isolated_spikes);
features = [score(:,1) score(:,2)];

rng('default')
isolated_label = kmeans(features,3);

%% BUILD OVERLAPPING TEMPLATES

[overlapped_template,template,overlapped_locations] = GetTemplates(window_size,isolated_spikes,isolated_label,to_plot);

%% TEMPLATE MATCHING

[overlapped_label,PsC_score] = CorrelationMatching(overlapped_spikes,overlapped_template);

P = perms(1:max(isolated_label));
P = [P(:,end-1:end); [1:max(isolated_label); 1:max(isolated_label)]'];
P = sortrows(P);
P = unique(P,'rows');

for d=0:(max(isolated_label))^2 - 1
    for e = 1:length(overlapped_label)
        if (overlapped_label(e) >= 1 + d*window_size) & (overlapped_label(e) <= (d+1)*window_size)
            label_shifted(e) = P(d+1,2)';
            label_detected(e) = P(d+1,1)';
        end
    end
end

for j = 1:length(overlapped_index)
    
    if overlapped_locations(overlapped_label(j)) > window_size/2
        
        index_shifted(j) = overlapped_index(j) + overlapped_locations(overlapped_label(j)) - window_size/2;
    else
        index_shifted(j) = overlapped_index(j) + overlapped_locations(overlapped_label(j));
    end
end


%%  EVALUATE PERFORMANCE
index_detected = overlapped_index;

isolated_output = [isolated_index' isolated_label];
overlapped_output = sortrows([[index_detected' label_detected']; [index_shifted' label_shifted']]);
output = sortrows([isolated_output; overlapped_output]);

[precision, recall, accuracy] = EvaluatePerformance(GT(logical(GT(:,3)),1), GT(logical(GT(:,3)),2), overlapped_output(:,1), overlapped_output(:,2), 1e-3*Fs);
fprintf('SNR = %d\n',ceil(mean(max(spikes'))/(median(abs(X))/0.6745)));

%Ground_Truth = [GT(logical(GT(:,3)),1) GT(logical(GT(:,3)),2)];

for i = 1:50
    figure
    subplot(2,1,1)
    plot(overlapped_spikes(i,:))
    subplot(2,1,2)
    plot(overlapped_template(overlapped_label(i),:))
end



