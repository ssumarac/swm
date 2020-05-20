function [ISI, OL] = IsolateSpikes(index,cutoff,Fs)

    ISI = zeros(1,length(index));
    OL = zeros(1,length(index));
    
    for i = 2:length(index)
        ISI(i) = 1000*(index(i) - index(i-1))/Fs;
        
        if ISI(i) < cutoff
            OL(i) = 1;
            OL(i-1) = 1;
        end
    end
    
    OL = logical(OL);
    
end