function [spikes starting_locs peaks] = getspikes(X,window_size,threshold,Fs,refractory_period)

[peaks,location] = findpeaks(X,'MinPeakHeight',threshold,'MinPeakDistance',refractory_period/2);

for i = 1:length(location)
    spike_window(i,:) = location(1,i) - refractory_period + 1:location(1,i) + refractory_period;
    spikes(i,:) = X(spike_window(i,:));
end

spikes = spikes;
locs = location;
peaks = peaks;

end