clear all; close all; clc;

%% LOAD BENCHMARK DATA
[X, Fs, GT] = importdata(1);

%% SET PARAMETERS
window_size = 3e-3*Fs;
threshold = 4*median(abs(X))/0.6745;
refractory_period = window_size/2; %in ms

%% DETECT SPIKES
[spikes index] = getspikes(X,window_size,threshold,1);

%% INITIAL CLUSTERING
[coeff,score,latent] = pca(spikes);
features = [score(:,1) score(:,2)];

minPts = size(spikes,2) - 1;
epsilon = clusterDBSCAN.estimateEpsilon(spikes,2,minPts);

label = dbscan(spikes,epsilon,minPts);

%% BUILD OVERLAPPING TEMPLATES

[overlapped_template,overlapped_locations] = templates(window_size,spikes,label,0);



%% TEMPLATE MATCHING

overlapped = spikes(label == -1,:);

[overlapped_label,PsC_score] = matching(overlapped,overlapped_template);

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
    if overlapped_locations(j) > refractory_period
        locs_overlapped_shifted(j) = index(j) + overlapped_locations(j);
    else
        locs_overlapped_shifted(j) = index(j) - overlapped_locations(j);
    end
end

%%

cutoff = PsC_score > 1;

overlapped_shifted_output = [locs_overlapped_shifted(cutoff); overlapped_label_shifted(cutoff)]';

label(label == -1) = overlapped_label_detected;

combined_output = [index' label];

total = [overlapped_shifted_output; combined_output];
total = sortrows(total);


%%  EVALUATE PERFORMANCE

[precision recall accuracy] = evaluate(GT(:,1), GT(:,2), total(:,1), total(:,2), 1e-3*Fs);

fprintf('SNR = %d\n',ceil(mean(max(spikes'))/(median(abs(X))/0.6745)));


