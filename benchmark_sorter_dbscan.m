clear all; close all; clc;

%% LOAD BENCHMARK DATA

load('C_Easy1_noise005')

Fs = 1/samplingInterval*1e3;
X = data;

% set parameters
window_size = 2e-3*Fs;
threshold = 4*median(abs(X))/0.6745;
refractory_period = window_size/2; %in ms

%% DETECT SPIKES
[spikes index] = getspikes(X,window_size,threshold,1);

%% DIMENSION REDUCTION
[coeff,score,latent] = pca(spikes);
features = [score(:,1) score(:,2)];

%% CLUSTERING
minPts = size(spikes,2) - 1;
epsilon = clusterDBSCAN.estimateEpsilon(spikes,2,minPts);

label = dbscan(spikes,epsilon,minPts);

%% OVERLAPPING TEMPLATE

%figure
c = 1;
for a = 1:max(label)
    for b = 1:max(label)
        template(b,:) = mean(spikes(label == b,:));
        temp1(b,:) = [zeros(1,window_size/2) template(b,:) zeros(1,window_size/2)];
        
        for i = 1:window_size
            
            temp2 = [zeros(1,i) template(b,:) zeros(1,window_size-i)];
            temp3 = temp1(a,:) + temp2;
            overlapped_template(c,:) = temp3(:,window_size/2 + 1:length(temp1) - window_size/2);
            
            temporary(c) = i;
            
                        %plot(1:window_size,overlapped_template(c,:),'r*-');
            %axis([1 window_size -2 2])
            %drawnow;
            
            c = c + 1;
        end
    end
end

overlapped = spikes(label == -1,:);

[overlapped_label,PsC_score] = templatematching(overlapped,overlapped_template,2);

% for iii = 48
% figure;
% subplot(2,1,1)
% plot(1:24,overlapped(iii,:))
% title('Overlapped')
% subplot(2,1,2)
% plot(1:24, overlapped_template(overlapped_label(iii),:))
% title('Template')
% end

P = perms(1:max(label));
P = [P(:,end-1:end); [1:max(label); 1:max(label)]'];
P = sortrows(P);
P = unique(P,'rows');

for d=0:(max(label))^2 - 1
    for e = 1:length(overlapped_label)
        if (overlapped_label(e) >= 1 + d*window_size) & (overlapped_label(e) <= (d+1)*window_size)
            overlapped_label_shifted(e) = P(d+1,2)';
            overlapped_label_detected(e) = P(d+1,1)';
        end
    end
end

locs_overlapped = index(label == -1);

for j = 1:length(locs_overlapped)
    if temporary(j) > refractory_period
        locs_overlapped_shifted(j) = index(j) + temporary(j);
    else
        locs_overlapped_shifted(j) = index(j) - temporary(j);
    end
end


%% FINAL RESULTS

% for f = 1:(max(label))^2
%     overlapped_count(f) = sum(tidx_cut == f);
%     fprintf('Spike %d and Spike %d: %d\n',P(f,1), P(f,2), overlapped_count(f));
% end
% 
% fprintf('\n')
% 
% for g = 1:max(label)
%     to_add(g) = sum([overlapped_count' overlapped_count'] .* (P == g),'all');
%     spks_tot(g) = sum(idx_spikes == g) + to_add(g);
%     fprintf('Spike %d: %d\n', g, spks_tot(g));
% end
% 
% fprintf('Total Spikes: %d\n',sum(spks_tot));

%%

cutoff = PsC_score > 1;

overlapped_shifted_output = [locs_overlapped_shifted(cutoff); overlapped_label_shifted(cutoff)]';

label(label == -1) = overlapped_label_detected;

combined_output = [index' label];

total = [overlapped_shifted_output; combined_output];
total = sortrows(total);


%% LOAD GROUND TRUTH

spike_times = cell2mat(spike_times);
spike_class_1 = cell2mat(spike_class(1))';
spike_class_2 = cell2mat(spike_class(2))';
spike_class_3 = cell2mat(spike_class(3))';
spikesgt = getspikesgt(X,window_size,spike_times);
for v = 1:length(spikesgt)
    [max_gt loc_gt(v)] = max(spikesgt(7,:));
end
spike_times = spike_times + mean(loc_gt);

%%  EVALUATE PERFORMANCE

[precision recall accuracy] = evaluate(spike_times, spike_class_1, total(:,1), total(:,2), 1e-3*Fs);

fprintf('SNR = %d\n',ceil(mean(max(spikes'))/(median(abs(X))/0.6745)));

% %% PLOTS
% 
% colour = ['r','b','g'];
% 
% figure
% for b = 1:max(label)
%     subplot(max(label),1,b);
%     plot(1:window_size/2, spikes(label == b,:), colour(b)); hold on;
%     title('Sorting of Extracted Spike Waveforms')
%     xlabel('Samples')
%     ylabel('Voltage(uV)')
% end
% 
% fprintf('SNR = %d\n',ceil(mean(max(spikes'))/(median(abs(X))/0.6745)));


