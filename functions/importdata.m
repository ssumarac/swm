function [X, Fs, GT] = importdata(dataset,filename)

switch(dataset)
    
    case 1
        load(filename);
        spike_class = cell2mat(spike_class);
        spike_times = cell2mat(spike_times);
        Fs = 1/samplingInterval*1000;
        X = bandpass(data,[300 3000],Fs);
        
        window_size = 64;
        
        for i = 1:length(spike_times)
            spike_window(i,:) = spike_times(1,i) + 1:spike_times(1,i) + window_size;
            spikes(i,:) = X(spike_window(i,:));
        end
        
        for a = 1:length(spikes)
            [maxSpike(a), locs(a)] = max(spikes(a,:));
        end
        
        spike_times_max = spike_times + locs;
        
        for i = 1:length(spike_times_max)
            spike_window_max(i,:) = spike_times_max(1,i) + 1 - 24:spike_times_max(1,i) + 40;
            spikes_max(i,:) = X(spike_window_max(i,:));
        end
        
        GT = [spike_times_max' spike_class'];
        
    case 2
        X = h5read(filename,'/X');
        Fs = h5read(filename,'/srate');
end
