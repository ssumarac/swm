function [label features] = DoClustering(spikes,clustering_method,clusters)

[coeff,score,latent] = pca(spikes);
features = [score(:,1) score(:,2)];

rng(26931257)

if clustering_method == 1
    label = kmeans(features,clusters);
    
elseif clustering_method == 2
    [C U] = fcm(spikes,clusters,[2,100,1e-5,0]);
    [val label] = max(U);
    label = label';
    
elseif clustering_method == 3
    minPts = size(spikes,2) - 1;
    epsilon = clusterDBSCAN.estimateEpsilon(spikes,2,minPts);
    label = dbscan(spikes,epsilon,minPts);
    
end

end