function [overlapped_label,val] = CorrelationMatching(spikes,template)

for s = 1:size(spikes,1)
    for j = 1:size(template,1)
        val(j) = PsC(template(j,:),spikes(s,:));
    end
    
    [PsC_score(s),overlapped_label(s)] = max(val);
    
end

end