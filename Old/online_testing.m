clear all; close all; clc;

%% LOAD BENCHMARK DATA
dataset = 1;
filename = 'simulation_1.mat';

[X, Fs, GT] = importdata(dataset,filename);

%X = bandpass(X_raw,[300 3000],Fs);

% set parameters
window_size = 64;
threshold = 4*median(abs(X))/0.6745;
refractory_period = window_size/2; %in ms

%% IMPLEMENT MOVING WINDOW

i = 1 + window_size/2;
x = 1;
y = 1;

a = 1;
b = 1;
c = 1;

calibration = 500;

figure
while i <= length(X) - window_size/2;
    
    window1 = X(i - window_size/2:i - 1);
    window2 = X(i:i + window_size/2 - 1);
    
    if (window1(end) > threshold) || (window1(end) < -threshold)
        
        if x < calibration + 1
            spike_init(x,:) = [window1 window2];
        end
        
        
        if x == calibration + 1
            [coeff,score,latent] = pca(spike_init);
            
            features = [score(:,1) score(:,2)];
            
            %             C_init = [-0.1791 -1.9023; -1.8387 1.1068; 2.0333 0.8349];
            %
            %             [kidx,C] = kmeans(features,k,'Display','iter','Start',C_init);
            
            [kidx] = kmeans(features,k,'Display','iter');
            
            
            spikes1 = spike_init(kidx == 1,:);
            spikes2  = spike_init(kidx == 2,:);
            spikes3 = spike_init(kidx == 3,:);
            
            template = [mean(spikes1); mean(spikes2); mean(spikes3)];
            
            spikes1_calibrated = spikes1;
            spikes2_calibrated = spikes2;
            spikes3_calibrated = spikes3;
            
        end
        
        if x > calibration + 1
            
            spike = [window1 window2];
            
            for j = 1:k
                PsC_score(j) = PsC(template(j,:),spike);
            end
            
            [val,idx] = max(PsC_score);
            
            %{
            for j = 1:k
                [istart(j,1),istop(j,1),dist(j,1)] = findsignal(spike(x,:),template(j,:));
            end
            
            [val,idx(x)] = min(dist);
            %fprintf('\t%d\n',idx);
            %}
            
            if idx == 1
                spikes1(1,:) = [];
                spikes1 = [spikes1; spike];
                template(1,:) = mean(spikes1);
                
                %plot(1:window_size,spike,'r'); hold on;
                plot(template(1,:),'r'); hold on;
                %drawnow;
                
                a = a + 1;
                
            end
            
            if idx == 2
                spikes2(1,:) = [];
                spikes2 = [spikes2; spike];
                template(2,:) = mean(spikes2);
                
                %plot(1:window_size,spike,'b'); hold on;
                plot(template(2,:),'b'); hold on;
                %drawnow;
                
                b = b + 1;
                
            end
            
            if idx == 3
                spikes3(1,:) = [];
                spikes3 = [spikes3; spike];
                template(3,:) = mean(spikes3);
                
                %plot(1:window_size,spike,'g'); hold on;
                plot(template(3,:),'g'); hold on;
                %drawnow;
                
                c = c + 1;
                
            end
            
            y = y + 1;
            
        end
        
        x = x + 1;
        i = i + window_size*3/2;
    end
    
    i = i + 1;
end
