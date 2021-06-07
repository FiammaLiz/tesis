anchor_points=[1, 903, 510, 6681]; %anchor points para P0
%anchor_points=[1,785]; %anchor points para P1
max_ini_length=anchor_points(1);
max_note_a_length=anchor_points(2);
max_gap_length=anchor_points(3);       
max_note_b_length=anchor_points(4); 
    
new_onset_a=0;
new_onset_gap=anchor_points(2)/sample_rate;
new_onset_b=sum(anchor_points(2:3))/sample_rate;
new_onset_ini=sum(anchor_points(2:4))/sample_rate;
    
onset_a=[10.9832 11.2827 11.5865 11.97]*sample_rate;
offset_a=[10.9891 11.292324 11.5959 11.9783]*sample_rate;
onset_b=[11.0074 11.3086 11.6167 11.9975]*sample_rate;
offset_b=[11.2225 11.5359 11.9095 12.2760]*sample_rate;
syll_end=[11.2827 11.5865 11.97 12.3409]*sample_rate;

for t=1:length(onset_a)    
sound_a(t)={audio_stim{1}(onset_a(t):offset_a(t))};
sound_b(t)={audio_stim{1}(onset_b(t):offset_b(t))};
sound_gap(t)={audio_stim{1}(offset_a(t):onset_b(t))};
end 

for g=1:length(onset_a)
stretched_notes_a{g}=interp1(1:size(sound_a{g},2),sound_a{g},linspace(1,size(sound_a{g},2),max_note_a_length))';
stretched_gap{g}=interp1(1:size(sound_gap{g},2),sound_gap{g},linspace(1,size(sound_gap{g},2),max_gap_length))';
stretched_notes_b{g}=interp1(1:size(sound_b{g},2),sound_b{g},linspace(1,size(sound_b{g},2),max_note_b_length))';
end

for g=1:length(onset_a)
stretched_syllabes(:,g)= [stretched_notes_a{g}; stretched_gap{g}; stretched_notes_b{g}];
end

for t=1:length(onset_a)  
    plot(stretched_syllabes(:,t))
    hold on 
end

plot(stretched_syllabes)

spikes_totales=cell2mat(spike_stim(1).trial);
length_note_a=offset_a-onset_a;
length_gap=onset_b-offset_a;
length_note_b=offset_b-onset_b;
length_end=syll_end-offset_b;
stretched_spike_train_sil={};
stretched_spike_train=[];
onset_a=[10.9832 11.2827 11.5865 11.97];
offset_a=[10.9891 11.292324 11.5959 11.9783];
onset_b=[11.0074 11.3086 11.6167 11.9975];
offset_b=[11.2225 11.5359 11.9095 12.2760];
syll_end=[11.2827 11.5865 11.97 12.3409];

for h=1:length(onset_a)

spike_train=spikes_totales((spikes_totales>=onset_a(h))&(spikes_totales<=syll_end(h)));
spike_train_reset=spike_train;

for spike = 1:length(spike_train_reset)
    spike_timestamp = spike_train_reset(spike);
%     display(spike_timestamp)
    if spike_timestamp < onset_a(h) %no tendrían que haber antes del onset de la nota si alineo con onsets
        %no le hice stretching
        difference=onset_a-spike_timestamp;
        stretched_spike_timestamp = new_onset_a-difference;
        disp('Warning, spike out of range')

%         * max_ini_length/length_ini; %-0*max_ini_length/window %en general son iguales
        
    elseif spike_timestamp >= onset_a(h) && spike_timestamp < offset_a(h)
        
        stretched_spike_timestamp = (spike_timestamp-onset_a(h)) * max_note_a_length/length_note_a(h) + new_onset_a;
            
    elseif spike_timestamp >= offset_a(h) && spike_timestamp < onset_b(h)
        
        stretched_spike_timestamp = (spike_timestamp-offset_a(h)) * max_gap_length/length_gap(h) + new_onset_gap;

    elseif spike_timestamp >= onset_b(h) && spike_timestamp < offset_b(h)
        
        stretched_spike_timestamp = (spike_timestamp-onset_b(h)) * max_note_b_length/length_note_b(h) + new_onset_b; 
        
    elseif spike_timestamp >= offset_b(h) && spike_timestamp <syll_end(h)
        
        stretched_spike_timestamp = (spike_timestamp-offset_b(h)) * max_ini_length/length_end(h) + new_onset_ini;
    end
    
    stretched_spike_train(spike)=stretched_spike_timestamp;
end
 
   stretched_spike_train_sil(h)={stretched_spike_train};
   
end
stretched_spike_train=cell2mat(stretched_spike_train_sil);

duration_syllabe= (1:length(stretched_syllabes))/sample_rate;
binsize=0.008;
points_bins=1000;

f1= figure(1); %figura superpuesta
n(1)=subplot(2,1,1);
plot(duration_syllabe,stretched_syllabes);
n(2)=subplot(2,1,2);
for t=1:length(onset_a)
counts=histogram(stretched_spike_train_sil{1,t},'BinWidth', binsize, 'Normalization','pdf'); %hago histograma relativizado
num_points=counts.NumBins*points_bins;
hold on
[f,xi]=ksdensity(stretched_spike_train_sil{1,t},'BandWidth', binsize,'Function','pdf','NumPoints',num_points); %funcion de suavizado para histograma
plot(xi,f,'LineWidth',1,'Color','r')
end
linkaxes(n,'x')
hold off

f2= figure(2); %figura separada
u(1)= subplot(5,1,1);
plot(duration_syllabe,stretched_syllabes);
for t=1:length(onset_a)
u(t+1)=subplot(5,1,t+1);
counts=histogram(stretched_spike_train_sil{1,t},'BinWidth', binsize, 'Normalization','pdf'); %hago histograma relativizado
num_points=counts.NumBins*points_bins;
hold on
[f,xi]=ksdensity(stretched_spike_train_sil{1,t},'BandWidth',binsize,'NumPoints',num_points); %funcion de suavizado para histograma
plot(xi,f,'LineWidth',1,'Color','r')
end
linkaxes(u,'x')
hold off
