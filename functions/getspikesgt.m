function spikesgt = getspikesgt(X,window_size,location)

for i = 1:length(location)
    spike_window(i,:) = location(1,i) + 1:location(1,i) + window_size;
    spikesgt(i,:) = X(spike_window(i,:));
end

end