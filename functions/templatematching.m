function [tidx,val] = templatematching(spikes,template,type)

for s = 1:size(spikes,1)
    
    switch(type)
        
        case 1
            for j = 1:size(template,1)
                PsC_score(j) = PsC(template(j,:),spikes(s,:));
            end
            
            [val(s),tidx(s)] = max(PsC_score);
            
        case 2
            for i = 1:size(template,1)
                [istart(i,1),istop(i,1),dist(i,1)] = findsignal(spikes(s,:),template(i,:));
            end
            
            [val,tidx(s)] = min(dist);
            
            %figure
            %findsignal(spikes(s,:),template(idx(s),:));
            
    end
end

end