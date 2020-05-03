clear all; close all; clc;

%% LOAD BENCHMARK DATA
[X, Fs, GT] = importdata(1);

%% SET PARAMETERS
window_size = 2e-3*Fs;
threshold = 4*median(abs(X))/0.6745;
refractory_period = window_size/2; %in ms

%% DETECT SPIKES
[spikes_combined index] = getspikes(X,window_size,threshold,0);

spikes_combined_count = 1:length(spikes_combined);

x = 1;
for i = 1:size(spikes_combined,1)
    
    [temp_pos temp_locs] = findpeaks(spikes_combined(i,:),'MinPeakHeight',threshold);
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

overlapped = spikes_combined(overlapped_idx,:);
spikes = spikes_combined(spikes_idx,:);


%% DIMENSION REDUCTION
[coeff,score,latent] = pca(spikes_combined);
features = [score(:,1) score(:,2)];

figure
scatter(score(:,1),score(:,2),'.');
title('Dimentional Reduction In Feature Space')
xlabel('1st Principal Component')
ylabel('2nd Principal Component')

%% CLUSTERING

rng(1)
idx_combined = kmeans(features,3);

idx_spikes = idx_combined(spikes_idx);

figure
gscatter(score(:,1),score(:,2),idx_combined);

for a = 1:max(idx_spikes)
    spks_tot(a) = sum(idx_spikes == a);
    fprintf('Spike %d: %d\n', a, spks_tot(a));
end

fprintf('Total Spikes: %d\n',sum(spks_tot));


%% OVERLAPPING TEMPLATE

%figure
c = 1;
for a = 1:max(idx_combined)
    for b = 1:max(idx_combined)
        template(b,:) = mean(spikes_combined(idx_combined == b,:));
        temp1(b,:) = [zeros(1,window_size/2) template(b,:) zeros(1,window_size/2)];
        
        for i = 1:window_size
            
            temp2 = [zeros(1,i) template(b,:) zeros(1,window_size-i)];
            temp3 = temp1(a,:) + temp2;
            overlapped_template(c,:) = temp3(:,window_size/2 + 1:length(temp1) - window_size/2);
            
            %plot(1:window_size,overlapped_template(c,:),'r*-');
            %axis([1 window_size -2 2])
            %drawnow;
            
            c = c + 1;
        end
    end
end

[tidx,val] = templatematching(overlapped,overlapped_template,1);

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
    spks_tot(g) = sum(idx_spikes == g) + to_add(g);
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

[precision recall accuracy] = evaluate(GT(:,1), GT(:,2), total(:,1), total(:,2), 1e-3*Fs);

fprintf('SNR = %d\n',ceil(mean(max(spikes'))/(median(abs(X))/0.6745)));




