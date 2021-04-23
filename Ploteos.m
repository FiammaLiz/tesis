%Script donde llamo a las distintas funciones para plotear
%los datos preprocesados levantados con Levantar_data.m
%Fiamma Liz Leites

%% Cargo el protocolo preprocesado y me voy al directorio de las funciones

%path_file= 'D:\Datos Canarios Protocolos\ca16-CeRo_2018-2019\181126\';
path_file='D:\Datos Canarios Protocolos\ca188-RoNe_2018-2019\181220\';
cd (path_file);
protocolo='mergeprotocolo35';
%protocolo='protocolo2_CeRo_181126_143704.mat'; 
load(protocolo); %cargo datos del .mat
path_function ='D:\Datos Canarios Protocolos\Scripts\';
cd (path_function);


%% 1) Visualizar raw data
%Devuelve graficados la senial testigo, el espectograma etiquetado con los
%estimulos y la senial de los cuatro canales del tetrodo con marcas de
%inicio y fin de los estimulos.

%Tetrodos (para la olvidadiza :D):
%desired_channels_neural= 8:11; canales= '8 a 11';
%desired_channels_neural= 12:15; canales= '12 a 15';
%desired_channels_neural= 16:19; canales= '16 a 19';
%desired_channels_neural= 20:23; canales= '20 a 23';

numch=length(desired_channels_neural);
trial_i= 1;
trial_f= 20;
lim_ejey=[-600 300];

%Para poder llamar solo los 4 canales que quiero arriba
for ch = 1:numch
    channels_neural(ch)=find(chip_channels==desired_channels_neural(ch));
end

%Extract data from desired channel
channel_neural_data=filtered_neural_data(:,channels_neural);
%Plotear raw data
plotrawdata (lim_ejey, ave, fecha, file, profundidad,canales,... %datos del protocolo
numch, t_amplifier, t_board_adc,trial_i,trial_f,pausa,... %tiempos
channel_neural_data,filtered_audio_data, filtered_stimuli_data,... %datos filtrados
t0s, name_stim, y, sample_rate, desired_channels_neural) %datos de la tabla

%% 2) Deteccion de spikes
%Filtra por el umbral seleccionado la raw data y luego los guarda en un
%struct segun el tipo de estimulo y trial al que pertenezcan

%Si extraje un grupo de canales
desired_channel_neural=20; %este es el canal que quiero
channels_neural=find(chip_channels==desired_channel_neural); %para llamar al canal que quiero

%Extract data from desired channel
channel_neural_data=filtered_neural_data(:,channels_neural);

%Umbral de deteccion
 %Criterio 1: Calculo de umbral con desvio estandar
  %std_min= 2.5; %Desvio estandar
  %abs_neural_data= abs(channel_neural_data); %Valor absoluto de los datos
  %std_noise_detect=median(abs_neural_data)/0.6745; %Calcula desvio estandar de mediana de los datos
  %thr= -std_min*std_noise_detect; %calcula thr como x desvios estandar de la mediana
  
  %Criterio 2: Asigno manualmente el umbral
  thr=-55; 
  abs_neural_data= abs(channel_neural_data); %Valor absoluto de los datos
  std_noise_detect=median(abs_neural_data)/0.6745; %Calcula desvio estandar de mediana de los datos
  std_min= thr/std_noise_detect; %Calculo cuantos desvios estandard representa mi umbral escogido para posterior comparacion
  maximo= 400; %tamaño del shoulder de arriba
  minimo= -1000; %tamaño del spike, para eliminar artefactos de técnica para spike shape
  spikedetection (maximo, minimo, thr,channel_neural_data, sample_rate, num_stim, t0s, t_audio_stim,pausa);
  disp(['std=' num2str(std_min)]);

%% 3) Chequeo de la deteccion de spikes
%Devuelve una figura con el canal neuronal seleccionado (raw data) donde marco umbral y eventos
%de spike. Para ver si lo que levanto respeta la actividad de la unidad y
%otros chequeos

trial_i= 10;
trial_f= 20;

spikecheck (trial_f, trial_i, t_board_adc, t_amplifier,t0s, sample_rate, ... %tiempos
filtered_audio_data, channel_neural_data, spike_times, spike_tot,... %audio, canal neuronal, spikes
ave, fecha, file, thr,std_min, profundidad,name_stim, desired_channel_neural)   %datos de la tabla

%% 4) Ploteo de raster+histograma o solo histograma
%Devuelve tantas figuras como tipos de estimulos haya: sonograma, audio, 
%raster e histograma. 

binsize=0.008; %tamanio del bin del histograma, en segundos
points_bins= 1000; %puntos por bin para suavizado

rasterplot (num_stim, name_stim, t_audio_stim, audio_stim, L, duracion_stim, sample_rate,...  %datos del estimulo
ntrials, spike_stim, desired_channel_neural,thr,std_min,points_bins,tg,colorp,... 
binsize, ave, fecha, file, profundidad) %datos de la tabla

%Si esta muy ruidoso el raster por mucha densidad de spikes, solo plotear
%histograma
%histplot (num_stim, name_stim, t_audio_stim, audio_stim, L, duracion_stim, sample_rate,...  %datos del estimulo
%ntrials, spike_stim, desired_channel_neural,thr,std_min,points_bins,tg,colorp,... 
%binsize, ave, fecha, file, profundidad) %datos de la tabla

%%
%Para añadir etiquetas al REV, si fuese necesario

 num_silb=length(tg(1).tier{1,1}.Label);

        for tx=1:num_silb
        patch([duracion_stim(n)-tg(1).tier{1,1}.T1(tx) duracion_stim(n)-tg(1).tier{1,1}.T1(tx) duracion_stim(n)-tg(1).tier{1,1}.T2(tx) duracion_stim(n)-tg(1).tier{1,1}.T2(tx)],[ax(1).YLim(1) ax(1).YLim(2) ax(1).YLim(2) ax(1).YLim(1)],colorp{tx,1},'FaceAlpha',0.15,'EdgeColor','none');
        hold on
        line((duracion_stim(n)-tg(1).tier{1,1}.T1(tx))*[1 1],ax(1).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]);
        line((duracion_stim(n)-tg(1).tier{1,1}.T2(tx))*[1 1],ax(1).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]); 
        end
        %Escribe los nombres de las sílabas centrados en el parche a 3/4 de altura
        for k=1:num_silb
        text(duracion_stim(n)-((tg(1).tier{1,1}.T1(k)+tg(1).tier{1,1}.T2(k))/2),(ax(1).YLim(2))*3/4,tg(1).tier{1,1}.Label(k),'FontSize',10,'Interpreter','none');
        end
        hold off

%% Spike shape
%Dibuja los spikes que levanto anteriormente

w_pre=0.001; %ventana anterior del pico del spike
w_post=0.0015; %ventana posterior del pico del spike
y_lim=[-400 300];
%desired_channels_neural= 8:11; canales= '8 a 11';
%desired_channels_neural= 12:15; canales= '12 a 15';
desired_channels_neural= 16:19; canales= '16 a 19';
%desired_channels_neural= 20:23; canales= '20 a 23';
numch=length(desired_channels_neural);

%Para poder llamar solo los 4 canales que quiero arriba
for ch = 1:numch
    channels_neural(ch)=find(chip_channels==desired_channels_neural(ch));
end

%Extract data from desired channel
channel_neural_data=filtered_neural_data(:,channels_neural);
numch=length(desired_channels_neural);

%% TODOS LOS SPIKES
spikeshape(y_lim,w_pre,w_post,desired_channels_neural,desired_channel_neural,canales,channel_neural_data,...
    numch, spike_lcs_ss,sample_rate, num_stim, ave, fecha, file, name_stim, profundidad, thr, std_min)

%% test con menos spikes
subset_spikes=mat2cell(spike_lcs_ss{1}(1:2000),1);
% spike_lcs_ss{1}(5000:6000) tiene los artefactos
spikeshape(y_lim,w_pre,w_post,desired_channels_neural,desired_channel_neural,canales,channel_neural_data,...
    numch, subset_spikes,sample_rate, num_stim, ave, fecha, file, name_stim, profundidad, thr, std_min)

%%
%spike_template=prom_spikes;

%testeo correlacion vs spikes
%primero tomo un subset porque corre lento
subset_spikes=mat2cell(spike_lcs_ss{1},1); %pasarle una celda de m (no 1)
%recupero spikes malos
spikeshape(y_lim,w_pre,w_post,desired_channels_neural,desired_channel_neural,canales,channel_neural_data,...
    numch, subset_spikes,sample_rate, num_stim, ave, fecha, file, name_stim, profundidad, thr, std_min)
spikeshapes_test=spikeshapes_ch(1).ch; %los del canal que yo necesito

umbral=0.7;
figure(33)
allcorrs=[];
for spike=1:size(spikeshapes_test,2)

    corrresult=corr(spike_template',spikeshapes_test(:,spike))
    allcorrs(spike)=corrresult;
    
        if corrresult>= umbral

%     if not(corrresult>= umbral)
        plot(spikeshapes_test(:,spike))
    hold on
    plot(spike_template,'k')
    end
%     pause
%     clf
end

sum(allcorrs>=umbral)
good_spikes_subset=find(allcorrs>=umbral)-1;
%doble check que estos sean los indices que queres!! ojo hardcodeo del 5300

%%
% %Ploteo los spikes shapes con la funcion
% spikeshape(y_lim,w_pre,w_post,desired_channels_neural,desired_channel_neural,canales,channel_neural_data,...
%     numch, spike_lcs_ss,sample_rate, num_stim, ave, fecha, file, name_stim, profundidad, thr, std_min)

%% Histograma de ISIS
%Para cuantificar los interspikes intervals. Solo tiene sentido para las SU
%(filtradas en los pasos anteriores)

n=1; %numero que corresponde al estimulo
binsize= 1; %binsize del histograma en milisegundos
x_lim=[0 50]; %limite del eje x para el histograma en milisegundos

ISIcalculator(n,x_lim, sample_rate, num_stim, name_stim, ave, fecha, file, profundidad, desired_channel_neural, binsize, spike_lcs_ss, thr, std_min)

%% Calculo de tasa de disparo dentro y fuera del estimulo
%Guarda en un struct las tasas de cada trial dentro y fuera; tambien el
%promedio con su desvio.

n=1; %estimulo que quiero

for t0=1:length(s(n).t0s)
    v_ini=spike_lcs_ss{n}(spike_lcs_ss{n}>s(n).t0s(t0)*sample_rate);
    spikes_dentro= spike_lcs_ss{n}(v_ini<(s(n).t0s(t0)+duracion_stim(n))*sample_rate);
    tasa.dentro(t0)=length(spikes_dentro)/duracion_stim(n);
end 

for t0=1:length(s(n).t0s)
    v_ini=spike_lcs_ss{n}(and(spike_lcs_ss{n}<s(n).t0s(t0)*sample_rate,spike_lcs_ss{n}>(s(n).t0s(t0)-L)*sample_rate));
    v_fin=spike_lcs_ss{n}(and(spike_lcs_ss{n}>(s(n).t0s(t0)+duracion_stim(n))*sample_rate,spike_lcs_ss{n}<(s(n).t0s(t0)+duracion_stim(n)+L)*sample_rate));
    spikes_fuera= [v_ini, v_fin];
    tasa.fuera(t0)=length(spikes_fuera)/(L*2);
end 

tasa.promedio(1)=mean(tasa.dentro);
tasa.promedio(2)=mean(tasa.fuera);
tasa.std(1)= std(tasa.dentro);
tasa.std(2)=std(tasa.fuera);

name_bar = categorical({'Dentro','Fuera'});
tasas_prom = [tasa.promedio(1) tasa.promedio(2)];
t=figure(1);
b(1)= subplot(2,1,1);
bar(name_bar,tasas_prom);
hold on
er1 = errorbar(1,tasa.promedio(1),tasa.std(1),'Color','k');    
er2 = errorbar(2,tasa.promedio(2),tasa.std(2),'Color','k');    
hold off
ylabel 'Tasa de disparo/[spikes/s]'
xlabel 'Instancia del estimulo'
title 'Tasas de disparo promedio'

%Tabla con datos
        estimulo=name_stim(num_stim==n); %nombre del estimulo
        estimulo=char(estimulo(1)); %para tenerlo una sola vez
        
        colnames={'Ave', 'Fecha', 'Protocolo', 'Estimulo','Repeticiones','Profundidad', 'Canal', 'Spikes totales','Tasa fuera', 'Tasa dentro'};
        valuetable={ave, fecha, file, estimulo, ntrials(n), profundidad, desired_channel_neural, length(spike_lcs_ss{n}),tasa.promedio(1),tasa.promedio(2)};       
        t = uitable(t,'Data', valuetable, 'RowName', [], 'ColumnName', colnames,'Position', [125 30 1100 40.5]);
        



