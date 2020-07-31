function rasterplot (num_stim, name_stim, t_audio_stim, audio_stim, pause, sample_rate,... 
ntrials, spike_stim, desired_channel_neural, thr,... 
binsize, ave, fecha, file, profundidad)
%Devuelve tantas figuras como tipos de estimulos haya: sonograma, audio, 
%raster e histograma
%Versión 30/07/2020
%Matlab 2017a
%Fiamma Liz Leites

%% ESTÍMULO, RASTER E HISTOGRAMA

 %Si hay más de un estímulo, saca una figura por cada estímulo
 
for n=1:(length(unique(num_stim)))  %para cada estimulo
    
        f2=figure(n+1); %para que no se superponga si saca una figura con spike check
        
        ax(1)=subplot(5,1,1);
        %Audio del estimulo
        plot(t_audio_stim{n}, audio_stim{n}); %grafico el audio
        hold on
        line([0 0],ax(1).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]); %linea de principio de estímulo
        line((t_audio_stim{n}(length(t_audio_stim{n}))*[1 1])',ax(1).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5 0.6]); %línea de fin de estímulo
        hold off
        xlim([-pause/5 pause*4/5]); %pongo de límite a la ventana seleccionada
        title 'Estimulo, Raster e Histograma';
        ylabel 'Estimulo'
        
        %Espectograma del estímulo
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
        xlim([-pause/5 pause*4/5]); %límite de ventana en x
        hold on
        line([0 0],ax(2).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]); %linea de principio de estímulo
        line((t_audio_stim{n}(length(t_audio_stim{n}))*[1 1])',ax(2).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5 0.6]); %línea de fin de estímulo
        hold off
        ylabel 'Espectograma';
        
        ax(3)=subplot(5,1,3);
        %Raster
        for i= 1:(ntrials(n)) %para todos los trials en el estimulo n
            line((spike_stim(n).stim{1,i}'*[1 1])',[0 1] + i,'LineStyle','-','MarkerSize',4,'Color','r'); %extrae las instancias de disparo y hace lineas rojas, apilándolas por cada trial
            hold on
            line([0 0],ax(3).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]); %linea de principio de estímulo
            line((t_audio_stim{n}(length(t_audio_stim{n}))*[1 1])',ax(3).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5 0.6]); %línea de fin de estímulo
            hold off
            xlim([-pause/5 pause*4/5]); %pongo de límite en x a la ventana seleccionada
            ylim([0 ntrials(n)+2]) %pongo de límite en y dos filas más que el numero de trials porque arranca en 1
            ylabel 'Raster';
        end 
    
        ax(4)=subplot(5,1,4);
        
        %Histograma

         hist_spikes=cell2mat(spike_stim(n).stim); %agrupo las instancias spikes del mismo estímulo en un solo vector para función histograma
         histogram(hist_spikes,'BinWidth',binsize) %hago histograma
         hold on
         line([0 0],ax(4).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]); %linea de principio de estímulo
         line((t_audio_stim{n}(length(t_audio_stim{n}))*[1 1])',ax(4).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5 0.6]); %línea de fin de estímulo
         hold off
         xlim([-pause/5 pause*4/5]); %Pongo de límite a la ventana seleccionada
        
        ylabel 'Histograma'
        xlabel 'tiempo/[s]';
        equispace(f2)  
        linkaxes(ax,'x');

        %Tabla con datos
        estimulo=name_stim(num_stim==n); %nombre del estimulo
        estimulo=char(estimulo(1)); %para tenerlo una sola vez
        move_to_base_workspace(estimulo);
        
        for i= 1:(ntrials(n)) %para todos los trials del estimulo
        spikenumtrial(i)=numel(spike_stim(n).stim{i}); %cuenta el número de spikes 
        move_to_base_workspace=(spikenumtrial);
        numspikes= sum(spikenumtrial(1:i)); %y los suma para tener #spikes/trial
        end
        move_to_base_workspace=(numspikes);
        
        colnames={'Ave', 'Fecha', 'Protocolo', 'Estimulo','Repeticiones','Profundidad', 'Canal', 'Umbral', 'Spikes','Binsize histograma'};
        valuetable={ave, fecha, file, estimulo, ntrials(n), profundidad, desired_channel_neural, thr, numspikes, binsize};       
        t = uitable(f2,'Data', valuetable, 'RowName', [], 'ColumnName', colnames,'Position', [50 30 1200 40.5]);
    
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