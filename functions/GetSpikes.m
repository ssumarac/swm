function [spikes index] = GetSpikes(X,window_size,threshold,cut)

[peaks, index] = findpeaks(X,'MinPeakHeight',threshold,'MinPeakDistance',window_size);

for i = 1:length(index)
    spike_window(i,:) = index(1,i) - window_size/2 + 1:index(1,i) + window_size/2;
    spikes(i,:) = X(spike_window(i,:));
end


if cut == 1
    spikes = spikes(:,1 + window_size/3:window_size - window_size/3);
else
    spikes = spikes;
end

end