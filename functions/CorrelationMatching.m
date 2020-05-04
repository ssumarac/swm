function [overlapped_label,PsC_score] = CorrelationMatching(spikes,template)

for s = 1:size(spikes,1)
    for j = 1:size(template,1)
        PsC_score(j) = PsC(template(j,:),spikes(s,:));
    end
    
    [PsC_score(s),overlapped_label(s)] = max(PsC_score);
    
end

end