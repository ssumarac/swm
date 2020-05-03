clear all; close all; clc;

%% LOAD BENCHMARK DATA

load('C_Easy1_noise005.mat')

Fs = 1/samplingInterval*1e3;
X = data;

%X = bandpass(X,[300 3000],Fs);

% set parameters
window_size = 64;
threshold = 4*median(abs(X))/0.6745;
refractory_period = window_size/2; %in ms

%% DETECT SPIKES
[spikes locs peaks] = getspikes(X,window_size,threshold,Fs,refractory_period);

%% DIMENSION REDUCTION
[coeff,score,latent] = pca(spikes);
features = [score(:,1) score(:,2)];

%% CLUSTERING

rng('default')
idx = kmeans(features,3);

for a = 1:max(idx)
    spks_tot(a) = sum(idx == a);
    fprintf('Spike %d: %d\n', a, spks_tot(a));
end

fprintf('Total Spikes: %d\n',sum(spks_tot));

%% EVALUATE PERFORMANCE

spike_times = cell2mat(spike_times) + refractory_period;
spike_class_1 = cell2mat(spike_class(1))';
spike_class_2 = cell2mat(spike_class(2))';
spike_class_3 = cell2mat(spike_class(3))';

s = spike_times;

P = perms(1:max(idx));
 
s_1 = spike_times(spike_class_1 == 1);
s_2 = spike_times(spike_class_1 == 2);
s_3 = spike_times(spike_class_1 == 3);

for i = 1:length(P)

t_1 = locs(idx == P(i,1));
t_2 = locs(idx == P(i,2));
t_3 = locs(idx == P(i,3));

n_GT = [length(s_1) length(s_2) length(s_3)];
n_k = [length(t_1) length(t_2) length(t_3)];

delta_t = refractory_period/2;

%%

for i_1 = 1:n_GT(1)
    for j_1 = 1:n_k(1)
        n_match_1_mat(i_1,j_1) = abs(t_1(j_1) - s_1(i_1)) < delta_t;
    end
end

%%

for i_2 = 1:n_GT(2)
    for j_2 = 1:n_k(2)
        n_match_2_mat(i_2,j_2) = abs(t_2(j_2) - s_2(i_2)) < delta_t;
    end
end

%%

for i_3 = 1:n_GT(3)
    for j_3 = 1:n_k(3)
        n_match_3_mat(i_3,j_3) = abs(t_3(j_3) - s_3(i_3)) < delta_t;
    end
end

%%
n_match_1(i) = sum(sum(n_match_1_mat) > 0,'all');
n_match_2(i) = sum(sum(n_match_2_mat) > 0,'all');
n_match_3(i) = sum(sum(n_match_3_mat) > 0,'all');

n_miss_1(i) = n_GT(1) - n_match_1(i);
n_miss_2(i) = n_GT(2) - n_match_2(i);
n_miss_3(i) = n_GT(3) - n_match_3(i);

n_fp_1(i) = n_k(1) - n_match_1(i);
n_fp_2(i) = n_k(2) - n_match_2(i);
n_fp_3(i) = n_k(3) - n_match_3(i);

n_1(i) = n_miss_1(i) + n_miss_2(i) + n_miss_3(i);
n_2(i) = n_match_1(i) + n_match_2(i) + n_match_3(i);
n_3(i) = n_fp_1(i) + n_fp_2(i) + n_fp_3(i);

precision(i) = n_2(i)/(n_2(i) + n_3(i));
recall(i) = n_2(i)/(n_1(i) + n_2(i));
accuracy(i) = n_2(i)/(n_1(i) + n_2(i) + n_3(i));

clear n_match_1_mat
clear n_match_2_mat
clear n_match_3_mat
end

[max_accuracy i_max] = max(accuracy);

n_match_1 = n_match_1(i_max);
n_match_2 = n_match_2(i_max);
n_match_3 = n_match_3(i_max); 

n_miss_1 = n_miss_1(i_max); 
n_miss_2 = n_miss_2(i_max); 
n_miss_3 = n_miss_3(i_max);

n_fp_1 = n_fp_1(i_max);
n_fp_2 = n_fp_2(i_max);
n_fp_3 = n_fp_3(i_max);

n_1 = n_1(i_max); 
n_2 = n_2(i_max); 
n_3 = n_3(i_max); 

precision = precision(i_max); 
recall = recall(i_max); 
accuracy = accuracy(i_max);

% fprintf('n_match_1 = %d\n',n_match_1)
% fprintf('n_match_2 = %d\n',n_match_2)
% fprintf('n_match_3 = %d\n',n_match_3)
% 
% fprintf('n_miss_1 = %d\n',n_miss_1)
% fprintf('n_miss_2 = %d\n',n_miss_2)
% fprintf('n_miss_3 = %d\n',n_miss_3)
% 
% fprintf('n_fp_1 = %d\n',n_fp_1)
% fprintf('n_fp_2 = %d\n',n_fp_2)
% fprintf('n_fp_3 = %d\n',n_fp_3)

fprintf('Precision = %0.2f%%\n',precision*100)
fprintf('Recall = %0.2f%%\n',recall*100)
fprintf('Accuracy = %0.2f%%\n',accuracy*100)

