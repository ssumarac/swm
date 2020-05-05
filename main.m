clear all; close all; clc;

%% LOAD BENCHMARK DATA
[X, Fs, GT] = GetData(1);

%% SET PARAMETERS
window_size = 2e-3*Fs;
threshold = 4*median(abs(X))/0.6745;

cut = 0;
isolated = 1;
to_plot = 0;

%% DETECT SPIKES
[spikes, index, window_size,isolated_logical] = GetSpikes(X,window_size,threshold,cut,isolated);

isolated_spikes = spikes(isolated_logical,:);
isolated_index = index(isolated_logical);

overlapped_spikes = spikes(not(isolated_logical),:);
overlapped_index = index(not(isolated_logical));

%% CLUSTERING
[coeff,score,latent] = pca(spikes);
features = [score(:,1) score(:,2)];

rng('default')
label = kmeans(features,3);

%% BUILD OVERLAPPING TEMPLATES

[overlapped_template,template,overlapped_locations] = GetTemplates(window_size,spikes,label,to_plot);

%% TEMPLATE MATCHING

template_combined = [overlapped_template; template];

[overlapped_label,PsC_score] = CorrelationMatching(overlapped_spikes,template_combined);

% figure;
% histogram(PsC_score)

P = perms(1:max(label));
P = [P(:,end-1:end); [1:max(label); 1:max(label)]'];
P = sortrows(P);
P = unique(P,'rows');

for d=0:(max(label))^2 - 1
    for e = 1:length(overlapped_label)
        if (overlapped_label(e) >= 1 + d*window_size) & (overlapped_label(e) <= (d+1)*window_size)
            label_shifted(e) = P(d+1,2)';
            label_detected(e) = P(d+1,1)';
        end
        
        if overlapped_label(e) == (d+1)*window_size + 1
            label_detected(e) = 1;
        end
        
        if overlapped_label(e) == (d+1)*window_size + 2
            label_detected(e) = 2;
        end
        
        if overlapped_label(e) == (d+1)*window_size + 3
            label_detected(e) = 3;
        end
        
    end
end

for j = 1:length(overlapped_index)
    
    if overlapped_label(j) <= length(overlapped_locations)
        
        if overlapped_locations(overlapped_label(j)) > window_size/2
            
            index_shifted(j) = overlapped_index(j) + overlapped_locations(overlapped_label(j)) - window_size/2;
        else
            index_shifted(j) = overlapped_index(j) + overlapped_locations(overlapped_label(j));
        end
    end
end

index_detected = overlapped_index';

index_shifted = index_shifted(index_shifted>0)';

label_shifted = label_shifted(label_shifted>0)';
index = index';

%index_detected_shifted = [index_shifted; index_detected];


% for i = 1:50
%     figure
%     subplot(2,1,1)
%     plot(overlapped_spikes(i,:))
%     subplot(2,1,2)
%     plot(template_combined(overlapped_label(i),:))
% end



%%  EVALUATE BENCHMARK PERFORMANCE

error_parameter = 20;

h = 1;
for i = 1:length(index_shifted)
    temp = find(index > index_shifted(i) - error_parameter & index < index_shifted(i) + error_parameter);
    
    count(i) = length(temp);
   
    if count(i) == 0
       to_add(h) = i;
       h = h + 1;
    end
    
end

index_shifted = index_shifted - window_size/2;

count = count';
sum(count == 0)
sum(count == 1)
sum(count == 2)
sum(count == 3)

%%  EVALUATE STANDARD PERFORMANCE

fprintf('For SNR = %d\n\n',ceil(mean(max(spikes'))/(median(abs(X))/0.6745)));

fprintf('\nSTANDARD\n');
[precision, recall, accuracy] = EvaluatePerformance(GT(:,1), GT(:,2), index, label, 1e-3*Fs);

label(not(isolated_logical)) = label_detected';
detected_output = [index label];

shifted_output = [index_shifted(to_add) label_shifted(to_add)];

output = sortrows([shifted_output; detected_output]);

fprintf('\nBENCHMARK\n');
[precision, recall, accuracy] = EvaluatePerformance(GT(:,1), GT(:,2), output(:,1), output(:,2), 1e-3*Fs);

Ground_Truth = [GT(logical(GT(:,3)),1) GT(logical(GT(:,3)),2)];



