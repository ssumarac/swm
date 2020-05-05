function [shifted_output, label_detected, PsC_score] = CorrelationTemplateMatching(spikes,template,label,window_size,overlapped_index,overlapped_locations,index,error_parameter)

for s = 1:size(spikes,1)
    for j = 1:size(template,1)
        val(j) = PsC(template(j,:),spikes(s,:));
    end
    
    [PsC_score(s),overlapped_label(s)] = max(val);
    
end

P = perms(1:max(label));
P = [P(:,end-1:end); [1:max(label); 1:max(label)]'];
P = sortrows(P);
P = unique(P,'rows');

for d = 0:(max(label))^2 - 1
    for e = 1:length(overlapped_label)
        if (overlapped_label(e) >= 1 + d*window_size) & (overlapped_label(e) <= (d+1)*window_size)
            label_shifted(e) = P(d+1,2)';
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

for j = 1:length(overlapped_index)
    
    if overlapped_label(j) <= length(overlapped_locations)
        
        if overlapped_locations(overlapped_label(j)) > window_size/2
            index_shifted(j) = overlapped_index(j) + overlapped_locations(overlapped_label(j)) - window_size/2;
        else
            index_shifted(j) = overlapped_index(j) + overlapped_locations(overlapped_label(j));
        end
    end
end

index_detected = overlapped_index';
index_shifted = index_shifted(index_shifted>0)';
label_shifted = label_shifted(label_shifted>0)';

h = 1;
for i = 1:length(index_shifted)
    temp = find(index > index_shifted(i) - error_parameter & index < index_shifted(i) + error_parameter);
    
    count(i) = length(temp);
    
    if count(i) == 0
        to_add(h) = i;
        h = h + 1;
    end
    
end

index_shifted = index_shifted - window_size/4;

shifted_output = [index_shifted(to_add) label_shifted(to_add)];

count = count';
sum(count == 0);
sum(count == 1);
sum(count == 2);
sum(count == 3);

end