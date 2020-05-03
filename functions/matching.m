function [tidx,val] = matching(spikes,template)

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
    
    [val(s),tidx(s)] = max(PsC_score);

end

end