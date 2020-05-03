function [] = results(X,Fs,spikes,window_size,score,kidx)

t = 0:1/Fs:(length(X)-1)/Fs;

figure
plot(t,X); hold on;
title('Raw Truth Data')
xlabel('Time (s)')
ylabel('Voltage (uV)')

figure
plot(1:window_size,spikes);
title('Extracted Spike Waveforms')
xlabel('Samples')
ylabel('Voltage(uV)')

figure
gscatter(score(:,1),score(:,2),kidx);
title('Dimentional Reduction In Feature Space')
xlabel('1st Principal Component')
ylabel('2nd Principal Component')

figure
subplot(3,1,1);
plot(1:window_size, spikes(kidx == 1,:),'r'); hold on;
title('Extracted Waveform 1')
xlabel('Samples')
ylabel('Voltage(uV)')

subplot(3,1,2);
plot(1:window_size, spikes(kidx == 2,:),'b'); hold on;
title('Extracted Waveform 2')
xlabel('Samples')
ylabel('Voltage(uV)')

subplot(3,1,3);
plot(1:window_size, spikes(kidx == 3,:),'g'); hold on;
title('Extracted Waveform 3')
xlabel('Samples')
ylabel('Voltage(uV)')

% figure
% plot(1:window_size, template(1,:),'r'); hold on;
% plot(1:window_size, template(2,:),'b'); hold on;
% plot(1:window_size, template(3,:),'g'); hold on;
% title('Mean of Extracted Waveforms used as a Template')
% xlabel('Samples')
% ylabel('Voltage(uV)')

figure
plot(1:window_size, spikes(kidx == 1,:),'r'); hold on;
plot(1:window_size, spikes(kidx == 2,:),'b'); hold on;
plot(1:window_size, spikes(kidx == 3,:),'g'); hold on;
title('Sorting of Extracted Spike Waveforms')
xlabel('Samples')
ylabel('Voltage(uV)')

fprintf('\nSpike 1: %d\n',sum(kidx == 1));

fprintf('\nSpike 2: %d\n',sum(kidx == 2));

fprintf('\nSpike 3: %d\n',sum(kidx == 3));

fprintf('Total Spikes: %d\n',length(kidx))
