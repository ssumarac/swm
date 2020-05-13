function [spikes, index, window_size, isolated_logical] = GetSpikes(X,window_size,threshold)

[peaks, index] = findpeaks(X,'MinPeakHeight',threshold);

for i = 1:length(index)
    spike_window(i,:) = index(1,i) - window_size/2 + 1:index(1,i) + window_size/2;
    spikes(i,:) = X(spike_window(i,:));
end

index = index';

end