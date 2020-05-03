function [spikes index window_size isolated_logical] = GetSpikes(X,window_size,threshold,cut, isolated)

[peaks, index] = findpeaks(X,'MinPeakHeight',threshold,'MinPeakDistance',window_size);

for i = 1:length(index)
    spike_window(i,:) = index(1,i) - window_size/2 + 1:index(1,i) + window_size/2;
    spikes(i,:) = X(spike_window(i,:));
end


if cut == 1
    spikes = spikes(:,1 + window_size/3:window_size - window_size/3);
    window_size = window_size/3;
end

if isolated == 1
    for a = 1:length(spikes)
        [peaks_pos,index_pos] = findpeaks(spikes(a,:),'MinPeakHeight',threshold);
        [peaks_neg,index_neg] = findpeaks(-spikes(a,:),'MinPeakHeight',threshold);
        warning('off')
        count_pos(a) = length(peaks_pos);
        count_neg(a) = length(peaks_neg);
    end
    
    isolated_logical = and(count_pos == 1,count_neg == 1);
    
    
end


end