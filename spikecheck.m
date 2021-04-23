function spikecheck (trial_f, trial_i, t_board_adc, t_amplifier,t0s, sample_rate, ... 
filtered_audio_data, channel_neural_data, spike_times, spike_tot,... 
ave, fecha, file, thr,std_min, profundidad, name_stim, desired_channel_neural) 
%Check spike detection
%Devuelve una figura con el canal neuronal seleccionado (raw data) donde marco umbral y eventos
%de spike
%Matlab 2017a
%Fiamma Liz Leites

sample_f=t0s(trial_f)*sample_rate; %calcula el sample final para poder extraer solo una parte de los datos y asi no se traba
sample_i=t0s(trial_i)*sample_rate; %calcula el sample inicial

f1=figure(1);
num_t0s=length(t0s);
%Canal de audio 
h(1)=subplot(3,1,1);
plot(t_board_adc(sample_i:sample_f),filtered_audio_data(sample_i:sample_f));  %Audio filtrado de estimulos pasados
v_altura= repmat(h(1).YLim(2)-0.2,1,num_t0s); %Posicion en y de las etiquetas
text(t0s,v_altura,name_stim,'FontSize',10,'Interpreter','none'); %Etiqueta que estimulo es al principio del estimulo
ylabel 'Canal audio'
title 'Chequeo de deteccion de spikes'

%Raw data con marquitas de spikes
h(2)=subplot(3,1,2);
plot(t_amplifier(sample_i:sample_f),channel_neural_data(sample_i:sample_f),'Color','k') %Canal neuronal
hold on

%Agrego lineas con comienzos de trials (grises, verticales)
line((t0s(trial_i:trial_f)'*[1 1])',h(2).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.3 0.3 0 0.6]);   
%Agrego linea de umbral (azul, horizontal)
line([t0s(trial_i) t0s(trial_f)], [thr thr],'Color','b','LineWidth',0.05);
%Agrego lineas con spikes detectados (rojas, verticales)
spikes_ind = find(and(spike_times<=t0s(trial_f), spike_times>=t0s(trial_i)));
line((spike_times(spikes_ind(1):spikes_ind(end))'*[1 1])',[thr+10 thr+50],'LineStyle','-','MarkerSize',4,'Color','r','LineWidth',0.05); 
hold off
ylabel 'Raw data con spikes marcados'
xlabel 'tiempo/[s]'
linkaxes(h,'x'); %alinea los ceros
equispace(f1); %pega los ejes

%Tabla con datos 
colnames_sd={'Ave', 'Fecha', 'Protocolo', 'Profundidad', 'Canal', 'Umbral','Desvio', 'Spikes'};
valuetable_sd={ave, fecha, file,  profundidad, desired_channel_neural,thr,std_min, spike_tot};       
uitable(f1,'Data', valuetable_sd, 'RowName', [], 'ColumnName', colnames_sd,'Position', [320 100 750 40.5]);

end 