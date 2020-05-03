function [overlapped, non_overlapped] = overlapped(spikes,window_size,threshold)

o = 1;
no = 1;

for i = 1:size(spikes,1) - 1
    peaks_max = findpeaks(spikes(i,:),'MinPeakHeight',threshold);
    
    if length(peaks_max) > 1
        overlapped(o,:) = spikes(i,:);
        o = o + 1;
    else
        [peaks_min, index_min] = findpeaks(-spikes(i,:),'MinPeakHeight',threshold);
        
        if length(peaks_min) > 1
            overlapped(o,:) = spikes(i,:);
            o = o + 1;
        elseif (index_min > window_size*3/4) & (index_min < window_size/4)
            overlapped(o,:) = spikes(i,:);
            o = o + 1;
        else
            non_overlapped(no,:) = spikes(i,:);
            no = no + 1;
        end
    end
    
end

non_overlapped = non_overlapped;
overlapped = overlapped;

end