function [X, Fs, GT] = GetData(N,plot)

filename = ["C_Easy1_noise005"
    "C_Easy1_noise01"
    "C_Easy1_noise015"
    "C_Easy1_noise02"
    "C_Easy2_noise005"
    "C_Easy2_noise01"
    "C_Easy2_noise015"
    "C_Easy2_noise02"
    "C_Difficult1_noise005"
    "C_Difficult1_noise01"
    "C_Difficult1_noise015"
    "C_Difficult1_noise02"
    "C_Difficult2_noise005"
    "C_Difficult2_noise01"
    "C_Difficult2_noise015"
    "C_Difficult2_noise02"
    "C_Burst_Easy2_noise015"];

load(filename(N));

spike_times = cell2mat(spike_times);
spike_class_1 = cell2mat(spike_class(1))';
spike_class_2 = cell2mat(spike_class(2))';
spike_class_3 = cell2mat(spike_class(3))';
%spike_times = spike_times + 22;

Fs = 1/samplingInterval*1e3;
X = data;

GT = [spike_times' spike_class_1 spike_class_2];

GT(:,1) = GT(:,1) + 22;

end
