% TEMPLATE MATCHING FUNCTION
%
% Inputs:
%   - Spikes Matrix
%   - Spike Templates
%   - Clustering label
%   - Window Size
%
% Outputs:
%   - Synethtic Template
%   - Spike Templates
%   - Clustering label
%   - Window Size

function [label_template, min_distance,overlapped_label, overlapped_logical] = TemplateMatching(spikes,templates,kmeans_label,window_size)

weighting = ones(1,window_size);
weighting(1 + window_size/4:window_size - window_size/4) = 1000;

for k = 1:size(spikes,1)
    for i = 1:size(templates,1)
        for j = 1:window_size
            s(i,j) = spikes(k,j);
            t(i,j) = templates(i,j);
            d(i,j) = weighting(j)*abs(s(i,j)-t(i,j));
        end
    end
    
    tot_d = sum(d');
    
    [min_distance(k), overlapped_label(k)] = min(tot_d);
end

P = perms(1:max(kmeans_label));
P = [P(:,end-1:end); [1:max(kmeans_label); 1:max(kmeans_label)]'];
P = sortrows(P);
P = unique(P,'rows');

b = 1;
for d = 0:(max(kmeans_label))^2 - 1
    for e = 1:length(overlapped_label)
        if (overlapped_label(e) >= 1 + d*window_size) & (overlapped_label(e) <= (d+1)*window_size)
            label_template(e) = P(d+1,1)';         
        end
        
        if overlapped_label(e) == (d+1)*window_size + 1
            label_template(e) = 1;
        end
        
        if overlapped_label(e) == (d+1)*window_size + 2
            label_template(e) = 2;
        end
        
        if overlapped_label(e) == (d+1)*window_size + 3
            label_template(e) = 3;
        end
        
    end
end

label_template = label_template';


end