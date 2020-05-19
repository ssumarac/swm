function [templates, window_size, spikes] = template(window_size_init,spikes_init,label,trigger)

c = 1;

if trigger == 1
    figure
end

%figure
for a = 1:max(label)
    for b = 1:max(label)
        template(b,:) = median(spikes_init(label == b,:));
        temp1(b,:) = [zeros(1,window_size_init/2) template(b,:) zeros(1,window_size_init/2)];
        
        for i = 1+window_size_init/4:window_size_init-window_size_init/4
            
            temp2 = [zeros(1,i) template(b,:) zeros(1,window_size_init-i)];
            temp3 = temp1(a,:) + temp2;
            overlapped_template(c,:) = temp3(:,window_size_init/2 + 1:length(temp1) - window_size_init/2);
            
            if trigger == 1
                plot((1:window_size_init)/24000,overlapped_template(c,:),'r*-');
                axis([1*1000/24000 window_size_init*1000/24000 -2 2])
                title('Construction of Overlapped Spike Templates')
                xlabel('Time (ms)')
                ylabel('Voltage (uV)')
                %drawnow;
                %pause(0.02)
                M(c) = getframe;
            end
            %{
            if c == 244
                subplot(1,3,2)
                plot((1:window_size_init)/24000,overlapped_template(c,:),'k'); hold on;
                plot((1:window_size_init)/24000,temp1(a,window_size_init/2 + 1:length(temp1) - window_size_init/2),'b'); hold on;
                plot((1:window_size_init)/24000,temp2(window_size_init/2 + 1:length(temp1) - window_size_init/2),'g'); hold on;
                legend('Superimposed Template', 'Spike Template #3', 'Spike Template #2')
                title('Construction of Template #244')
                xlabel('Time (ms)')
                ylabel('Voltage (uV)')
            end
            
            if c == 242
                subplot(1,3,1)
                plot((1:window_size_init)/24000,overlapped_template(c,:),'k'); hold on;
                plot((1:window_size_init)/24000,temp1(a,window_size_init/2 + 1:length(temp1) - window_size_init/2),'b'); hold on;
                plot((1:window_size_init)/24000,temp2(window_size_init/2 + 1:length(temp1) - window_size_init/2),'g'); hold on;
                legend('Superimposed Template', 'Spike Template #3', 'Spike Template #2')
                title('Construction of Template #242')
                xlabel('Time (ms)')
                ylabel('Voltage (uV)')
            end
            
            if c == 120
                subplot(1,3,3)
                plot((1:window_size_init)/24000,overlapped_template(c,:),'k'); hold on;
                plot((1:window_size_init)/24000,temp1(a,window_size_init/2 + 1:length(temp1) - window_size_init/2),'r'); hold on;
                plot((1:window_size_init)/24000,temp2(window_size_init/2 + 1:length(temp1) - window_size_init/2),'g'); hold on;
                legend('Superimposed Template', 'Spike Template #1', 'Spike Template #2')
                title('Construction of Template #120')
                xlabel('Time (ms)')
                ylabel('Voltage (uV)')
            end
            %}
            
            c = c + 1;
        end
    end
end

if trigger == 1
    v = VideoWriter('GetTemplates','Archival');
    open(v)
    writeVideo(v,M)
    close(v)
end

templates = [overlapped_template; template];

templates = templates(:,1+window_size_init/4:window_size_init - window_size_init/4);
window_size = window_size_init/2;
spikes = spikes_init(:,1+window_size_init/4:window_size_init - window_size_init/4);


end