clear all; close all; clc;
%
%% LOAD BENCHMARK DATA
[X, Fs, GT] = GetData(1);

%% SET PARAMETERS
window_size = 6e-3*Fs;
threshold = 4*median(abs(X))/0.6745;

%% DETECT SPIKES
[spikes index] = GetSpikes(X,window_size,threshold,0);

b = 1;
for a = 1:length(spikes)
    [peaks_pos,index_pos] = findpeaks(spikes(a,:),'MinPeakHeight',threshold);
    [peaks_neg,index_neg] = findpeaks(-spikes(a,:),'MinPeakHeight',threshold);
    warning('off')
    count_pos(a) = length(peaks_pos);
    count_neg(a) = length(peaks_neg);
end

isolated_spikes = spikes(and(count_pos == 1,count_neg == 1),:);
isolated_index = index(and(count_pos == 1,count_neg == 1));

figure; plot(1:window_size,isolated_spikes); hold on;
plot(1:window_size,threshold*ones(1,window_size),'r*'); hold on;
plot(1:window_size,-threshold*ones(1,window_size),'r*');

%% CLUSTERING

[coeff,score,latent] = pca(isolated_spikes);
features = [score(:,1) score(:,2)];

figure
scatter(score(:,1),score(:,2),'.');
title('Dimentional Reduction In Feature Space')
xlabel('1st Principal Component')
ylabel('2nd Principal Component')

rng(1)
label = kmeans(features,3);

figure
gscatter(score(:,1),score(:,2),label);
title('Dimentional Reduction In Feature Space')
xlabel('1st Principal Component')
ylabel('2nd Principal Component')

%% LOAD GROUND TRUTH

spike_times = cell2mat(spike_times);
spike_class_1 = cell2mat(spike_class(1))';
spike_class_2 = cell2mat(spike_class(2))';
spike_class_3 = cell2mat(spike_class(3))';
spike_times = spike_times + 22;

figure
plot(t,X); hold on;
plot(t(index), X(index),'r*'); hold on;
plot(t(spike_times), X(spike_times),'bs'); hold on;
plot(t,threshold*ones(1,length(X)));

%%  EVALUATE PERFORMANCE

total = [isolated_index' label];

[precision recall accuracy] = EvaluatePerformance(GT(:,1), GT(:,2), total(:,1), total(:,2), 1e-3*Fs);

fprintf('SNR = %d\n',ceil(mean(max(spikes'))/(median(abs(X))/0.6745)));




