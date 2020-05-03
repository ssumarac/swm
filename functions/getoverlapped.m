function [overlapped_idx spikes_idx overlapped_logical] = getoverlapped(spikes_combined, threshold)

spikes_combined_count = 1:length(spikes_combined);

for i = 1:size(spikes_combined,1)
    
    [temp_pos temp_locs] = findpeaks(spikes_combined(i,:),'MinPeakHeight',threshold);
    warning('off')
    
    if length(temp_pos) > 1
       index(i) = i; 
       
       
       
    end
    
    count_pos(i) = length(temp_pos);
end

overlapped_logical = (count_pos > 1);

overlapped_idx = spikes_combined_count(overlapped_logical);
spikes_idx = spikes_combined_count(not(overlapped_logical));

overlapped = spikes_combined(overlapped_idx,:);
spikes = spikes_combined(spikes_idx,:);

end