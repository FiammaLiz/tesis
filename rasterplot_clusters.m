function rasterplot_clusters (num_stim, name_stim, t_audio_stim, audio_stim, L, duracion_stim, sample_rate,... 
ntrials, spike_stim,tetrode,cluster,points_bins,tg,colorp,... 
binsize, ave, fecha, file, profundidad)
%Devuelve tantas figuras como tipos de estimulos haya: sonograma, audio, 
%raster e histograma
%Matlab 2017aindex_selected
%Fiamma Liz Leites

%% ESTIMULO, RASTER E HISTOGRAMA

 %Si hay mas de un est√≠mulo, saca una figura por cada estimulo
 
    for n=1:(length(unique(num_stim)))  %para cada estimulo

        f2=figure(n+1); %para que no se superponga si saca una figura con spike check
        
        ax(1)=subplot(5,1,1);
        %Audio del estimulo
        plot(t_audio_stim{n}, audio_stim{n},'Color','k'); %grafico el audio
        hold on
        line([0 0],ax(1).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]); %linea de principio de estimulo
        line((t_audio_stim{n}(length(t_audio_stim{n}))*[1 1])',ax(1).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5 0.6]); %linea de fin de estimulo
        %Hace parches que van cambiando de color para cada silaba, traza lineas
        %divisorias para ayudar en gris
        hold on
        
        if n<=length(tg) %solo si est·n los datos del textgrid los levanta y hace parches + nombres
        num_silb=length(tg(n).tier{1,1}.Label);
        for tx=1:num_silb
        patch([tg(n).tier{1,1}.T1(tx) tg(n).tier{1,1}.T1(tx) tg(n).tier{1,1}.T2(tx) tg(n).tier{1,1}.T2(tx)],[ax(1).YLim(1) ax(1).YLim(2) ax(1).YLim(2) ax(1).YLim(1)],colorp{tx,1},'FaceAlpha',0.15,'EdgeColor','none');
        hold on
        line(tg(n).tier{1,1}.T1(tx)*[1 1],ax(1).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]);
        line(tg(n).tier{1,1}.T2(tx)*[1 1],ax(1).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]); 
        end
        %Escribe los nombres de las sÌlabas centrados en el parche a 3/4 de altura
        for k=1:num_silb
        text((tg(n).tier{1,1}.T1(k)+tg(n).tier{1,1}.T2(k))/2,(ax(1).YLim(2))*3/4,tg(n).tier{1,1}.Label(k),'FontSize',10,'Interpreter','none');
        end
        end
        hold off
        xlim([-L duracion_stim(n)+L]); %pongo de limite a la ventana seleccionada
        title 'Estimulo, Raster e Histograma';
        ylabel 'Sonido(u.a)'
        
        %Espectograma del estimulo
        window_width=sample_rate/100;   %points
        [~,f,t,p] = spectrogram(audio_stim{n},...
        gausswin(window_width,5),...
        ceil(0.75*window_width),...
        linspace(0,ceil(sample_rate/2),...
        round(sample_rate/window_width)),...
        sample_rate,'yaxis');
    
        ax(2)=subplot(5,1,2);
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
        ylabel 'Frecuencia (Hz)';
        
        ax(3)=subplot(5,1,3);
        %Raster
        for i= 1:(ntrials(n)) %para todos los trials en el estimulo n
            for g= 1: length(spike_stim(n).trial{1,i})
            line(spike_stim(n).trial{1,i}(g)'*[1 1],[-0.5 0.5] + i,'LineStyle','-','MarkerSize',4,'Color','b'); %extrae las instancias de disparo y hace lineas azules, apil·ndolas por cada trial 
            end
            hold on
            line([0 0],ax(3).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]); %linea de principio de estimulo
            line((t_audio_stim{n}(length(t_audio_stim{n}))*[1 1])',ax(3).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5 0.6]); %linea de fin de estimulo
            hold off
            xlim([-L duracion_stim(n)+L]); %pongo de limite en x a la ventana seleccionada
            ylim([0 ntrials(n)+2]) %pongo de limite en y dos filas mas que el numero de trials porque arranca en 1
            ylabel '# de repeticiÛn'
        end 
    
        ax(4)=subplot(5,1,4);
        
        %Histograma
        % num_points=pausa/binsize*1000 %otro modo de puntos para suavizado
         hist_spikes=cell2mat(spike_stim(n).trial); %agrupo las instancias spikes del mismo estimulo en un solo vector para funcion histograma
         yyaxis left
         histogram(hist_spikes,'BinWidth', binsize,'FaceAlpha',0,'EdgeColor','none'); %segundo eje con valores absolutos
         ylabel ('PSTH(disparos/s)')       
         hold on
         yyaxis right
         counts=histogram(hist_spikes,'BinWidth', binsize, 'Normalization','pdf'); %hago histograma relativizado
         ylabel 'Probabilidad de disparo'
         num_points=counts.NumBins*points_bins;
         %counts=histogram(hist_spikes,'BinWidth',binsize,'Normalization','probability');
         %hago histograma % otra normalizacion
%        yyaxis left
         [f,xi]=ksdensity(hist_spikes,'BandWidth',binsize,'function','pdf','NumPoints',num_points); %funcion de suavizado para histograma
         plot(xi,f,'LineWidth',1,'Color','r')
%        plot(xi,f.*max(counts.Values)/max(f),'LineWidth',1.5);
         line([0 0],ax(4).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]); %linea de principio de estimulo
         line((duracion_stim(n)*[1 1])',ax(4).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5 0.6]); %linea de fin de estimulo
         hold off
         xlim([-L duracion_stim(n)+L]); %Pongo de limite a la ventana seleccionada
        
        
        xlabel 'Tiempo(s)';
        equispace(f2)  
        linkaxes(ax,'x');

        %Tabla con datos
        estimulo=name_stim(num_stim==n); %nombre del estimulo
        estimulo=char(estimulo(1)); %para tenerlo una sola vez
        
        spikenumtrial=zeros(ntrials(n));
        for i= 1:(ntrials(n)) %para todos los trials del estimulo
        spikenumtrial(i)=numel(spike_stim(n).trial{i}); %cuenta el numero de spikes 
        numspikes= sum(spikenumtrial(1:i)); %y los suma para tener #spikes/trial
        end
        
        colnames={'Ave', 'Fecha', 'Protocolo', 'Estimulo','Repeticiones','Profundidad','Tetrodo','Cluster','Spikes','Binsize histograma'};
        valuetable={ave, fecha, file, estimulo, ntrials(n), profundidad, tetrode, cluster, numspikes, binsize};       
        uitable(f2,'Data', valuetable, 'RowName', [], 'ColumnName', colnames,'Position', [50 30 1220 40.5]);
    
    end
     