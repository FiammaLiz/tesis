function spikecheck (t_board_adc, t_amplifier,t0s, num_t0s, sample_rate, ... 
filtered_audio_data, channel_neural_data, spike_times, spike_tot,... 
ave, fecha, file, thr,std_min, profundidad, name_stim, desired_channel_neural) 
%Check spike detection
%Devuelve una figura con el canal neuronal seleccionado (raw data) donde marco umbral y eventos
%de spike
%Versión 30/07/2020
%Matlab 2017a
%Fiamma Liz Leites
f1=figure(1);

%Canal de audio 
h(1)=subplot(3,1,1);
plot(t_board_adc, filtered_audio_data); %Audio filtrado de estímulos pasados
v_altura= repmat(h(1).YLim(2)-0.2,1,num_t0s); %Posición en y de las etiquetas
text(t0s,v_altura,name_stim,'FontSize',10,'Interpreter','none'); %Etiqueta qué estimulo es al principio del estímulo
ylabel 'Canal audio'
title 'Chequeo de detección de spikes'

%Raw data con marquitas de spikes
h(2)=subplot(3,1,2);
plot(t_amplifier,channel_neural_data); %Canal neuronal
hold on
%Agrego lineas con comienzos de trials (grises, verticales)
line((t0s'*[1 1])',h(2).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.3 0.3 0 0.6]);   
%Agrego linea de umbral (azul, horizontal)
line([1 length(t_amplifier)/sample_rate], [thr thr],'Color','b','LineWidth',0.05);
%Agrego lineas con spikes detectados (rojas, verticales)
line((spike_times'*[1 1])',[thr+10 thr+50],'LineStyle','-','MarkerSize',4,'Color','r','LineWidth',0.05); 
hold off
ylabel 'Raw data con spikes marcados'
xlabel 'tiempo/[s]'
linkaxes(h,'x'); %alinea los ceros
equispace(f1); %pega los ejes

%Tabla con datos 
colnames_sd={'Ave', 'Fecha', 'Protocolo', 'Profundidad', 'Canal', 'Umbral','Desvío', 'Spikes'};
valuetable_sd={ave, fecha, file,  profundidad, desired_channel_neural,thr,std_min, spike_tot};       
uitable(f1,'Data', valuetable_sd, 'RowName', [], 'ColumnName', colnames_sd,'Position', [320 100 750 40.5]);

end 