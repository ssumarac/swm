function [spikes_init, spikes, index] = GetSpikes(X,window_size_init,threshold)

[peaks, index] = findpeaks(X,'MinPeakHeight',threshold);

for i = 1:length(index)
    spike_window(i,:) = index(1,i) - window_size_init/2 + 1:index(1,i) + window_size_init/2;
    spikes_init(i,:) = X(spike_window(i,:));
end

index = index';
spikes = spikes_init(:,1+window_size_init/4:window_size_init - window_size_init/4);

end