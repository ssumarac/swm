function [overlapped_template,template,undetected_overlaps, overlapped_locations] = template(window_size,spikes,label,threshold,trigger)

c = 1;

if trigger == 1
    figure
end

for a = 1:max(label)
    for b = 1:max(label)
        template(b,:) = mean(spikes(label == b,:));
        temp1(b,:) = [zeros(1,window_size/2) template(b,:) zeros(1,window_size/2)];
        
        for i = 1:window_size
            
            temp2 = [zeros(1,i) template(b,:) zeros(1,window_size-i)];
            temp3 = temp1(a,:) + temp2;
            overlapped_template(c,:) = temp3(:,window_size/2 + 1:length(temp1) - window_size/2);
            
            if trigger == 1
                plot(1:window_size,overlapped_template(c,:),'r*-');
                axis([1 window_size -2 2])
                drawnow;
            end
            
            overlapped_locations(c) = i;
            
            c = c + 1;
        end
    end
end

j = 1;
for i = 1:length(overlapped_template)
    
    temp4 = numel(findpeaks(overlapped_template(i,:),'MinPeakHeight',threshold));
    temp5 = numel(findpeaks(-overlapped_template(i,:),'MinPeakHeight',threshold));
    
    if (temp4 == 1) && (temp5 == 1)
        undetected_overlaps(j) =  i;
        j = j + 1;
    end
    
end

overlapped_locations = reshape(overlapped_locations,72,9)';

end