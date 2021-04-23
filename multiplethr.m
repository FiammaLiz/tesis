%% MULTIPLETHR
%Para hacer n cantidad de histogramas con n cantidad de umbrales en un
%canal
%Fiamma Liz Leites
%Script para Matlab 2017a
%Version 07/08/2020

%% Selecciono canal y umbrales

%Si extraje un grupo de anales
desired_channel_neural=21; %este es el canal que quiero
channels_neural=find(chip_channels==desired_channel_neural); %para llamar al canal que quiero

%Extract data from desired channel
channel_neural_data=filtered_neural_data(:,channels_neural);

%Si solo extraje un canal del protocolo
%desired_channel_neural= 19; %este es el canal que quiero
%channel_neural_data=filtered_neural_data';

abs_neural_data= abs(channel_neural_data); %Valor absoluto de los datos
std_noise_detect=median(abs_neural_data)/0.6745; %Calcula desvío estandar de mediana de los datos
thr_m=(-200:10:-100); %umbrales que quiero abarcar
maximo= 400; %tama�o del shoulder de arriba
minimo= -800; %tama�o del spike, para eliminar artefactos de t�cnica para spike shape
std_m= round(thr_m/std_noise_detect,2); %conversion a desvio

binsize= 0.008;

%% Detecto los spikes


for i=1:length(thr_m) %para todos los umbrales
    spikedetection (maximo,minimo,thr_m(i), channel_neural_data, sample_rate, num_stim, t0s, t_audio_stim, pausa) %levanto los spikes
    for a=1:length(unique(num_stim))
        for k=1:ntrials(a)
    thrspike(a).stim(i).thr{k}=spike_stim(a).trial{1,k}; %los guardo en un struct por estimulo y umbral
        end 
    end
end 

%% Ploteo

for n=1:length(unique(num_stim)) %para cada estimulo
    f1= figure(n); %hace una figura
    
    h(1)=subplot(3+length(thr_m),1,1);
      %Espectograma del estímulo
        window_width=sample_rate/100;   %points
        [~,f,t,p] = spectrogram(audio_stim{n},...
        gausswin(window_width,5),...
        ceil(0.75*window_width),...
        linspace(0,ceil(sample_rate/2),...
        round(sample_rate/window_width)),...
        sample_rate,'yaxis');
    
        imagesc('XData',t,'YData',f,'CData',10*log10(p(1:100,:)));
        colormap(jet);
        ylim([0 10000]);
        xlim([-L duracion_stim(n)+L]); %límite de ventana en x
        hold on
        line([0 0],h(1).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]); %linea de principio de estímulo
        line((t_audio_stim{n}(length(t_audio_stim{n}))*[1 1])',h(1).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5 0.6]); %línea de fin de estímulo
        hold off
        ylabel ('Espectograma', 'FontSize', 10);
        title 'Barrido con distintos umbrales'
        
     h(2)=subplot(3+length(thr_m),1,2);
        %Audio del estimulo
        plot(t_audio_stim{n}, audio_stim{n}); %grafico el audio
        hold on
        line([0 0],h(2).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]); %linea de principio de estímulo
        line((t_audio_stim{n}(length(t_audio_stim{n}))*[1 1])',h(2).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5 0.6]); %línea de fin de estímulo
        hold off
        xlim([-L duracion_stim(n)+L]); %pongo de límite a la ventana seleccionada
        ylabel ('Estimulo', 'FontSize', 10);
        

for th = 1:length(thr_m) %para cada umbral
    hist_spike_thrm{th}= thrspike(n).stim(th); %junta los datos para hacer el histograma
    
     h(2+th)= subplot(3+length(thr_m),1,2+th);
         histogram(cell2mat(hist_spike_thrm{1,th}.thr),'BinWidth',binsize,'Normalization','pdf'); %hago histograma, convirtiendo mis datos en un solo vector para que histogram lo tome
         hold on
         %ksdensity(hist_spike_thrm{1,th}.thr,'BandWidth',binsize,'NumPoints',100000, 'function', 'pdf');
         line([0 0],h(2+th).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]); %linea de principio de estímulo
         line((duracion_stim(n)*[1 1])',h(2+th).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5 0.6]); %línea de fin de estímulo
         xlim([-L duracion_stim(n)+L]); %Pongo de límite a la ventana seleccionada
         text(h(2+th).XLim(1),h(2+th).YLim(2)*4/5,['Std=' num2str(std_m(th))],'FontSize',10,'Interpreter','none');
         ylabel(['Thr=' num2str(thr_m(th))], 'FontSize', 10); %Nombro el umbral usado en el eje y
         %ylim([0 1])
end 
        xlabel ('tiempo/[s]');
        %Tabla con datos
        estimulo=name_stim(num_stim==n); %nombre del estimulo
        estimulo=char(estimulo(1)); %para tenerlo una sola vez
        
        colnames={'Ave', 'Fecha', 'Protocolo', 'Estimulo','Repeticiones','Profundidad', 'Canal', 'Binsize histograma'};
        valuetable={ave, fecha, file, estimulo, ntrials(n), profundidad, desired_channel_neural, binsize};       
        t = uitable(f1,'Data', valuetable, 'RowName', [], 'ColumnName', colnames,'Position', [250 30 920 40.5]);
        
        equispace(f1)  
        linkaxes(h,'x');
        
end 