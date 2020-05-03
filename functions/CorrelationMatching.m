function [label_shifted, label_detected, index_shifted, PsC_score] = CorrelationMatching(spikes,template,label,window_size,index)

for s = 1:size(spikes,1)
    
    for j = 1:size(template,1)
        
        m = length(template);
        n = length(spikes);
        
        p4 = zeros(1,m);
        normaliz = zeros(1,m);
        PsC_score = zeros(1,n);
        
        for i = 1:m
            p1 = (template(i)*spikes(i));
            p2 = abs(template(i) - spikes(i));
            p3 = max(abs(template(i)),abs(spikes(i)));
            p4(i) = (p1 - p2*p3);
            normaliz(i) = p3^2;
        end
        
        PsC_score(j) = max(sum(p4)/sum(normaliz),0);    
    end
    
    [PsC_score(s),overlapped_label(s)] = max(PsC_score);

end

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
    end
end

overlapped_index = index(label == -1);

for j = 1:length(overlapped_index)
    if overlapped_index(j) > window_size/2
        index_shifted(j) = index(j) + overlapped_index(j);
    else
        index_shifted(j) = index(j) - overlapped_index(j);
    end
end


end