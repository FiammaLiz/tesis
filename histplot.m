function histplot (num_stim, name_stim, t_audio_stim, audio_stim, L, duracion_stim, sample_rate,... 
ntrials, spike_stim, desired_channel_neural, thr,std_min,points_bins,tg,colorp,... 
binsize, ave, fecha, file, profundidad)
%Devuelve tantas figuras como tipos de estimulos haya: sonograma, audio, 
%y solo histograma por si M.U. es muy ruidoso.
%Matlab 2017a
%Fiamma Liz Leites

%% ESTIMULO E HISTOGRAMA

 %Si hay mas de un estimulo, saca una figura por cada estimulo
 
    for n=1:(length(unique(num_stim)))  %para cada estimulo

        f2=figure(n+1); %para que no se superponga si saca una figura con spike check
        
        ax(1)=subplot(4,1,1);
        %Audio del estimulo
        plot(t_audio_stim{n}, audio_stim{n},'Color','k'); %grafico el audio
        hold on
        line([0 0],ax(1).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]); %linea de principio de estimulo
        line((t_audio_stim{n}(length(t_audio_stim{n}))*[1 1])',ax(1).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5 0.6]); %linea de fin de estimulo
        %Hace parches que van cambiando de color para cada silaba, traza lineas
        %divisorias para ayudar en gris
        hold on
        
        if n<=length(tg) %solo si están los datos del textgrid los levanta y hace parches + nombres
        num_silb=length(tg(n).tier{1,1}.Label);
        for tx=1:num_silb
        patch([tg(n).tier{1,1}.T1(tx) tg(n).tier{1,1}.T1(tx) tg(n).tier{1,1}.T2(tx) tg(n).tier{1,1}.T2(tx)],[ax(1).YLim(1) ax(1).YLim(2) ax(1).YLim(2) ax(1).YLim(1)],colorp{tx,1},'FaceAlpha',0.15,'EdgeColor','none');
        hold on
        line(tg(n).tier{1,1}.T1(tx)*[1 1],ax(1).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]);
        line(tg(n).tier{1,1}.T2(tx)*[1 1],ax(1).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]); 
        end
        %Escribe los nombres de las sílabas centrados en el parche a 3/4 de altura
        for k=1:num_silb
        text((tg(n).tier{1,1}.T1(k)+tg(n).tier{1,1}.T2(k))/2,(ax(1).YLim(2))*3/4,tg(n).tier{1,1}.Label(k),'FontSize',10,'Interpreter','none');
        end
        end
        hold off
        xlim([-L duracion_stim(n)+L]); %pongo de limite a la ventana seleccionada
        title 'Estimulo e Histograma';
        ylabel 'Estimulo'
        
        %Espectograma del estimulo
        window_width=sample_rate/100;   %points
        [~,f,t,p] = spectrogram(audio_stim{n},...
        gausswin(window_width,5),...
        ceil(0.75*window_width),...
        linspace(0,ceil(sample_rate/2),...
        round(sample_rate/window_width)),...
        sample_rate,'yaxis');
    
        ax(2)=subplot(4,1,2);
        imagesc('XData',t,'YData',f,'CData',10*log10(p(1:100,:)));
        colormap(jet);
        ylim([0 10000]);
        xlim([-L duracion_stim(n)+L]); %limite de ventana en x
        hold on
        line([0 0],ax(2).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]); %linea de principio de estimulo
        line((t_audio_stim{n}(length(t_audio_stim{n}))*[1 1])',ax(2).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5 0.6]); %linea de fin de estimulo
        if n<=length(tg)
        for tx=1:num_silb
        line(tg(n).tier{1,1}.T1(tx)*[1 1],ax(2).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]);
        line(tg(n).tier{1,1}.T2(tx)*[1 1],ax(2).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]); 
        end
        end
        hold off
        ylabel 'Espectograma';
        
        ax(3)=subplot(4,1,3);
        
        %Histograma
        % num_points=pausa/binsize*1000 %otro modo de puntos para suavizado
         hist_spikes=cell2mat(spike_stim(n).trial); %agrupo las instancias spikes del mismo estimulo en un solo vector para funcion histograma
         counts=histogram(hist_spikes,'BinWidth',binsize,'Normalization','pdf'); %hago histograma con tipo de normalizacion pdf
         num_points=counts.NumBins*points_bins;
         %counts=histogram(hist_spikes,'BinWidth',binsize,'Normalization','probability');
         %hago histograma % otra normalizacion
         hold on
%        yyaxis left
         [f,xi]=ksdensity(hist_spikes,'BandWidth',binsize,'function','pdf','NumPoints',num_points); %funcion de suavizado para histograma
         plot(xi,f,'LineWidth',1,'Color','r')
%        plot(xi,f.*max(counts.Values)/max(f),'LineWidth',1.5);
         line([0 0],ax(3).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]); %linea de principio de estimulo
         line((duracion_stim(n)*[1 1])',ax(3).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5 0.6]); %linea de fin de estimulo
         hold off
         xlim([-L duracion_stim(n)+L]); %Pongo de limite a la ventana seleccionada
        
        ylabel 'Histograma'
        xlabel 'tiempo/[s]';
        equispace(f2)  
        linkaxes(ax,'x');

        %Tabla con datos
        estimulo=name_stim(num_stim==n); %nombre del estimulo
        estimulo=char(estimulo(1)); %para tenerlo una sola vez
        move_to_base_workspace(estimulo);
        
        for i= 1:(ntrials(n)) %para todos los trials del estimulo
        spikenumtrial(i)=numel(spike_stim(n).trial{i}); %cuenta el numero de spikes 
        move_to_base_workspace(spikenumtrial);
        numspikes= sum(spikenumtrial(1:i)); %y los suma para tener #spikes/trial
        end
        move_to_base_workspace(numspikes);
        
        colnames={'Ave', 'Fecha', 'Protocolo', 'Estimulo','Repeticiones','Profundidad', 'Canal', 'Umbral','Desvio','Spikes','Binsize histograma'};
        valuetable={ave, fecha, file, estimulo, ntrials(n), profundidad, desired_channel_neural, thr, std_min, numspikes, binsize};       
        uitable(f2,'Data', valuetable, 'RowName', [], 'ColumnName', colnames,'Position', [50 30 1220 40.5]);
    
    end 
return

function move_to_base_workspace(variable)

% move_to_base_workspace(variable)
%
% Move variable from function workspace to base MATLAB workspace so
% user will have access to it after the program ends.

variable_name = inputname(1);
assignin('base', variable_name, variable);

return