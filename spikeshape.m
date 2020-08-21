function spikeshape(w_pre,w_post,desired_channels_neural,desired_channel_neural,canales,channel_neural_data,numch, spike_lcs_ss,sample_rate, num_stim, ave, fecha, file, name_stim, profundidad, thr, std_min)
 %Devuelve spike shapes de los canales seleccionados en diferentes
 %subplots, hace una figura por estimulo.
 %Version 06/08/2020
 %Matlab 2017a

for k=1:length(unique(num_stim)) %para cada tipo de estimulo
        for ch=1:numch %y para cada canal
 for m=1:length(spike_lcs_ss{1,k}) %tomo cada instancia de spike
     hold on
     spikeshapes(:,m)=channel_neural_data(spike_lcs_ss{1,k}(m)-w_pre*sample_rate : spike_lcs_ss{1,k}(m)+w_post*sample_rate,ch); %y tomo la ventana que yo le seteé
 end
     spikeshapes_ch(ch).ch=spikeshapes; %voy guardando cada uno de ese conjunto de spikes en un struct por canal
        end 
        
ss=figure(k); %armo tantas figuras como tipos de estimulos tenga
t_ss= (1:length(spikeshapes(:,1)))/sample_rate; %tiempo que duran los spikes para poder plotear

    sss(1)=subplot(3,1,1);
for ch=1:numch %para cada canal
    for m=1:length(spike_lcs_ss{k}) %ploteo cada spike apilandolos en un plot por canal 
    plot (t_ss+(w_pre+w_post)*(ch-1),spikeshapes_ch(ch).ch(:,m),'color',[0.4940 0.1840 0.5560 0.3]); %color violeta con cierta transparencia, cuando se apilan se oscurece las partes donde coinciden
    hold on
    end 
    line((w_pre+w_post)*(ch-1)*[1 1],sss(1).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]); %separa los spikes de distintos canales
    if desired_channels_neural(ch)==desired_channel_neural %escribe en rojo el numero de canal del cual levante los spikes y en negro el resto
        text((w_pre+w_post)*(ch-1)+w_pre,500,{'Canal',num2str(desired_channel_neural)},'Color','red','FontSize',13);
    else
        text((w_pre+w_post)*(ch-1)+w_pre,500,{'Canal',num2str(desired_channels_neural(ch))},'FontSize',13);
    end 
    ylabel 'Voltaje/[mV]';
        % pause %por si quiero ir viendo los spikes mientras apila
    %pause %por si quiero ver los spikes apilados antes de poner media +
    %desvio
end 
    hold off 
title 'Spike shapes de un tetrodo'

for ch=1:numch %para cada canal hago un subplot
    sss(2)=subplot(3,1,2);
    for m=1:length(spike_lcs_ss{k}) %ploteo cada spike apilandolos en un plot por canal 
    plot (t_ss+(w_pre+w_post)*(ch-1),spikeshapes_ch(ch).ch(:,m)), %multicolor si uso desvío estandard 
    hold on
    line((w_pre+w_post)*(ch-1)*[1 1],sss(1).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]); %separa los spikes de distintos canales
    end 
    %agrego promedio + desvio estandard
    prom_spikes=mean(spikeshapes_ch(ch).ch,2)';
    move_to_base_workspace(prom_spikes);
    plot (t_ss+(w_pre+w_post)*(ch-1), prom_spikes,'color','k','LineWidth',1.3); %ploteo la media superpuesta a los spikes
    desv_std= std(spikeshapes'); %calculo el desvio estandard de la media
    plot(t_ss+(w_pre+w_post)*(ch-1),prom_spikes+desv_std,'k:','LineWidth',1.6); %grafico desvio estandard como linea punteada
    plot(t_ss+(w_pre+w_post)*(ch-1),prom_spikes-desv_std,'k:','LineWidth',1.6); %grafico desvio estandard como linea punteada
    line((w_pre+w_post)*(ch-1)*[1 1],sss(1).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]); %separa los spikes de distintos canales con una linea
    %errorbar(t_ss+(w_pre+w_post)*(ch-1),mean(spikeshapes_ch(ch).ch,2),desv_std,'color',[0 0 0 0],'LineWidth',0.01); %ploteo barras de error
    xlabel 'tiempo/[s]';
    ylabel 'Voltaje/[mV]';
end
    hold off
    linkaxes(sss); %alinea los ejes
    equispace(ss); %pega los ejes
    
%Tabla de datos
 estimulo=name_stim(num_stim==k); %nombre del estimulo
        estimulo=char(estimulo(1)); %para tenerlo una sola vez
        move_to_base_workspace(estimulo);
        
        numspikes_stim(k)=numel(spike_lcs_ss{k}); %cuenta el número de spikes por estimulo 
        move_to_base_workspace(numspikes_stim);
      
colnames={'Ave', 'Fecha', 'Protocolo', 'Estimulo','Profundidad', 'Canales', 'Umbral','Desvio', 'Spikes'};
valuetable={ave, fecha, file, estimulo, profundidad, canales, thr,std_min, numspikes_stim(k)};       
uitable(ss,'Data', valuetable, 'RowName', [], 'ColumnName', colnames,'Position', [110 30 1100 40.5]);

end 

return

 function move_to_base_workspace(variable)

% move_to_base_workspace(variable)
%
% Move variable from function workspace to base MATLAB workspace so
% user will have access to it after the program ends.

variable_name = inputname(1);
assignin('base', variable_name, variable);

 return;