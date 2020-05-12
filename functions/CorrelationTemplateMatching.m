function [label_detected, overlapped_label, PsC_score,index_shifted,label_shifted,overlapped_index,overlapped_logical] = CorrelationTemplateMatching(spikes,template,kmeans_label,window_size,undetected_overlaps,index)

for s = 1:size(spikes,1)
    for j = 1:size(template,1)
        val(j) = PsC(template(j,:),spikes(s,:));
    end
    [PsC_score(s),overlapped_label(s)] = max(val);
    
    overlapped_logical(s) = overlapped_label(s) <= 648;
    
end

overlapped_index = index(overlapped_logical);


P = perms(1:max(kmeans_label));
P = [P(:,end-1:end); [1:max(kmeans_label); 1:max(kmeans_label)]'];
P = sortrows(P);
P = unique(P,'rows');

b = 1;
for d = 0:(max(kmeans_label))^2 - 1
    for e = 1:length(overlapped_label)
        if (overlapped_label(e) >= 1 + d*window_size) & (overlapped_label(e) <= (d+1)*window_size)
            
            if ismember(overlapped_label(e),undetected_overlaps)
                label_shifted(b) = P(d+1,2)';
                
                temp(b) = overlapped_label(e) - d*window_size;
                temp2(b) = e;
                
                b=b+1;
                
            end
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

if b <= 2
    temp = 0;
    temp2 = 0;
    label_shifted = 0;
    index_shifted = 0;
    
else
    temp3 = (temp == window_size/2) | (temp == window_size/2 - 1) | (temp == window_size/2 + 1);
    
    label_shifted = label_shifted(temp3);
    temp2 = temp2(temp3);
    
    for i = 1:length(label_shifted)
        if temp2(i) > window_size/2
            index_shifted(i) = index(temp2(i)) + 1;
        elseif temp2(i) < window_size/2
            index_shifted(i) = index(temp2(i)) - 1;
        else
            index_shifted(i) = index(temp2(i));
        end
        
        
    end
    
    
    
    
end


end