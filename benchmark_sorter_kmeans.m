clear all; close all; clc;
%
%% LOAD BENCHMARK DATA
[X, Fs, GT] = GetData(1);

%% SET PARAMETERS
window_size = 2e-3*Fs;
threshold = 4*median(abs(X))/0.6745;
refractory_period = window_size/2; %in ms

cut = 0;
to_plot = 0;
isolated = 0;

%% DETECT SPIKES
[spikes, index, window_size] = GetSpikes(X,window_size,threshold,cut,isolated);

spikes_combined_count = 1:length(spikes);

x = 1;
for i = 1:size(spikes,1)
    
    [temp_pos, temp_locs] = findpeaks(spikes(i,:),'MinPeakHeight',threshold);
    warning('off')
    
    if length(temp_pos) == 2
        temp_locs_matrix(x,:) = temp_locs;
        x = x + 1;
    end
    
    count_pos(i) = length(temp_pos);
end

temp_locs_matrix(temp_locs_matrix == refractory_period) = [];

temp_locs_array = temp_locs_matrix';

overlapped_logical = (count_pos == 2);

overlapped_idx = spikes_combined_count(overlapped_logical);

locs_overlapped_detected = index(overlapped_logical);

for ii = 1:length(temp_locs_array)
    if temp_locs_array(ii) > refractory_period
        locs_overlapped_shifted(ii) = locs_overlapped_detected(ii) + temp_locs_array(ii);
    else
        locs_overlapped_shifted(ii) = locs_overlapped_detected(ii) - temp_locs_array(ii);
    end
end

spikes_idx = spikes_combined_count(not(overlapped_logical));

overlapped = spikes(overlapped_idx,:);
spikes = spikes(spikes_idx,:);


%% DIMENSION REDUCTION
[coeff,score,latent] = pca(spikes);
features = [score(:,1) score(:,2)];

figure
scatter(score(:,1),score(:,2),'.');
title('Dimentional Reduction In Feature Space')
xlabel('1st Principal Component')
ylabel('2nd Principal Component')

%% CLUSTERING

rng(1)
idx_combined = kmeans(features,3);

label = idx_combined(spikes_idx);

figure
gscatter(score(:,1),score(:,2),idx_combined);

for a = 1:max(label)
    spks_tot(a) = sum(label == a);
    fprintf('Spike %d: %d\n', a, spks_tot(a));
end

fprintf('Total Spikes: %d\n',sum(spks_tot));


%% OVERLAPPING TEMPLATE

[overlapped_template,overlapped_locations] = GetTemplates(window_size,spikes,label,to_plot);

[tidx,val] = CorrelationMatching(overlapped,overlapped_template);

% iii = 60
% figure;
% subplot(2,1,1)
% plot(1:48,overlapped(iii,:))
% title('Overlapped')
% subplot(2,1,2)
% plot(1:48, overlapped_template(tidx(iii),:))
% title('Template')

for d=0:(max(idx_combined))^2 - 1
    for e = 1:length(tidx)
        if (tidx(e) >= 1 + d*window_size) & (tidx(e) <= (d+1)*window_size)
            tidx_cut(e) = d+1;
        end
    end
end


%% FINAL RESULTS

P = perms(1:max(idx_combined));
P = [P(:,end-1:end); [1:max(idx_combined); 1:max(idx_combined)]'];
P = sortrows(P);
P = unique(P,'rows');

%locs_overlapped_shifted
%locs_overlapped_detected

for m = 1:max(tidx_cut)
    for h = 1:length(tidx_cut)
        if tidx_cut(h) == m
            tidx_overlapped_shifted(h) = P(m,2)';
            tidx_overlapped_detected(h) = P(m,1)';
        end
    end
end

for f = 1:(max(idx_combined))^2
    overlapped_count(f) = sum(tidx_cut == f);
    fprintf('Spike %d and Spike %d: %d\n',P(f,1), P(f,2), overlapped_count(f));
end

fprintf('\n')

for g = 1:max(idx_combined)
    to_add(g) = sum([overlapped_count' overlapped_count'] .* (P == g),'all');
    spks_tot(g) = sum(label == g) + to_add(g);
    fprintf('Spike %d: %d\n', g, spks_tot(g));
end

fprintf('Total Spikes: %d\n',sum(spks_tot));

%%

overlapped_shifted_output = [locs_overlapped_shifted; tidx_overlapped_shifted]';

idx_combined(overlapped_logical) = tidx_overlapped_detected;

combined_output = [index' idx_combined];

%total = [overlapped_shifted_output; combined_output];

total = combined_output;

total = sortrows(total);

%%  EVALUATE PERFORMANCE

[precision, recall, accuracy] = EvaluatePerformance(GT(:,1), GT(:,2), total(:,1), total(:,2), 1e-3*Fs);

fprintf('SNR = %d\n',ceil(mean(max(spikes'))/(median(abs(X))/0.6745)));




