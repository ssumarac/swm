function label = Classification(spikes,corr_cutoff,clusters)
x = 1;

similarity = corrcoef(spikes(2,:),spikes(1,:));
if similarity(2,1) > 0.8
    label_test(2) = x;
    label_test(1) = x;
else
    x = x + 1;
    label_test(2) = x;
    label_test(1) = x - 1;
end


for k = 3:length(spikes)
    
    for m = 1:k-1
        similarity = corrcoef(spikes(k,:),spikes(k - m,:));
        
        if similarity(2,1) > corr_cutoff
            label_test(k) = label_test(k - m);
            break
        end
        
        if m == k - 1
            x = x + 1;
            label_test(k) = x;
        end
        
    end
end

for kk = 1:x
    tempo(kk) = sum(label_test == kk);
end

%{
[maxk_val maxk_ind] = maxk(tempo,clusters);

label_test(not(ismember(label_test, maxk_ind))) = -1;

for d = 1:length(maxk_ind)
    label_test(ismember(label_test, maxk_ind(d))) = d;
end

label = label_test';
%}

cluster_cut = mad(tempo);

x_array = 1:x;
x_array_cut = x_array(tempo > cluster_cut);

label_test(not(ismember(label_test, x_array_cut))) = -1;

for d = 1:length(x_array_cut)
    label_test(ismember(label_test, x_array_cut(d))) = d;
end

label = label_test';

end