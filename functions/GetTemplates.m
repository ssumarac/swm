function templates = template(window_size,spikes,label,trigger)

c = 1;

if trigger == 1
    figure
end

for a = 1:max(label)
    for b = 1:max(label)
        template(b,:) = median(spikes(label == b,:));
        temp1(b,:) = [zeros(1,window_size/2) template(b,:) zeros(1,window_size/2)];
        
        for i = 1:window_size
            
            temp2 = [zeros(1,i) template(b,:) zeros(1,window_size-i)];
            temp3 = temp1(a,:) + temp2;
            overlapped_template(c,:) = temp3(:,window_size/2 + 1:length(temp1) - window_size/2);
            
            if trigger == 1
                plot((1:window_size)*1000/24000,overlapped_template(c,:),'r*-');
                axis([1*1000/24000 window_size*1000/24000 -2 2])
                title('Construction of Overlapped Spike Templates')
                xlabel('Time (ms)')
                ylabel('Voltage (uV)')
                %drawnow;
                %pause(0.02)
                M(c) = getframe;
            end
            
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

end