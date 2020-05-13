function [label_detected, PsC_score,overlapped_logical] = CorrelationTemplateMatching(spikes,template,kmeans_label,window_size)

for s = 1:size(spikes,1)
    for j = 1:size(template,1)
        val(j) = PsC(template(j,:),spikes(s,:));
    end
    [PsC_score(s),overlapped_label(s)] = max(val);
    
    overlapped_logical(s) = overlapped_label(s) <= 648;
    
end

P = perms(1:max(kmeans_label));
P = [P(:,end-1:end); [1:max(kmeans_label); 1:max(kmeans_label)]'];
P = sortrows(P);
P = unique(P,'rows');

b = 1;
for d = 0:(max(kmeans_label))^2 - 1
    for e = 1:length(overlapped_label)
        if (overlapped_label(e) >= 1 + d*window_size) & (overlapped_label(e) <= (d+1)*window_size)
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

end