%Script donde llamo a las distintas funciones para plotear
%los datos preprocesados levantados con Levantar_data.m
%Versión 07/08/2020
%Fiamma Liz Leites

%% Cargo el protocolo preprocesado y me voy al directorio de las funciones

path_file= '/home/alex/Documents/Fiamma/Datos_Canarios_Playback/ca313-VioAzu_2018-2019/190307/';
cd (path_file);
protocolo='protocolo3_VioAzu_190307_120148'; 
%protocolo3_VioAzu_190307_120148
%protocolo2_VioAzu_190307_114152
%protocolo1_VioAzu_190307_113706
load(protocolo); %cargo datos del .mat
path_function ='/home/alex/Documents/Fiamma/Scripts/Scripts_Fiamma';
cd (path_function);


%% 1) Visualizar raw data
%Devuelve graficados la senial testigo, el espectograma estiquetado con los
%estimulos y la senial de los cuatro canales del tetrodo con marcas de
%inicio y fin de los estimulos.

%Tetrodos (para la olvidadiza :D):
%tetrodo_1= 8:11;
%tetrodo_2= 12:15;
%tetrodo_3= 16:19;
%tetrodo_4= 20:23;
desired_channels_neural= 20:23;
canales= '20 a 23'; %Ojo no olvidarse de esto que sino aparece mal en la tabla
numch=length(desired_channels_neural);

%Para poder llamar solo los 4 canales que quiero arriba
for ch = 1:numch
    channels_neural(ch)=find(chip_channels==desired_channels_neural(ch));
end

%Extract data from desired channel
channel_neural_data=filtered_neural_data(:,channels_neural);
%Plotear raw data
plotrawdata (ave, fecha, file, profundidad,canales,... %datos del protocolo
numch, t_amplifier, t_board_adc,... %tiempos
channel_neural_data,filtered_audio_data, filtered_stimuli_data,... %datos filtrados
t0s, name_stim, y, sample_rate, desired_channels_neural) %datos de la tabla

%% 2) Detección de spikes
%Filtra por el umbral seleccionado la raw data y luego los guarda en un
%struct según el tipo de estímulo y trial al que pertenezcan

%Si extraje un grupo de canales
desired_channel_neural= 22; %este es el canal que quiero
channels_neural=find(chip_channels==desired_channel_neural); %para llamar al canal que quiero

%Extract data from desired channel
channel_neural_data=filtered_neural_data(:,channels_neural);

%Si solo extraje un canal del protocolo
%desired_channel_neural= 19; %este es el canal que quiero
%channel_neural_data=filtered_neural_data';

%Umbral de detección
 %Criterio 1: Cálculo de umbral con desvío estándar
  %std_min=-15; %Desvío estándar
  %abs_neural_data= abs(channel_neural_data); %Valor absoluto de los datos
  %std_noise_detect=median(abs_neural_data)/0.6745; %Calcula desvío estandar de mediana de los datos
  %thr= -std_min*std_noise_detect; %calcula thr como x desvíos estandar de la mediana
  
  %Criterio 2: Asigno manualmente el umbral
  thr=-250; 
  abs_neural_data= abs(channel_neural_data); %Valor absoluto de los datos
  std_noise_detect=median(abs_neural_data)/0.6745; %Calcula desvío estandar de mediana de los datos
  std_min= thr/std_noise_detect %Calculo cuántos desvíos estandard representa mi umbral escogido para posterior comparación
spikedetection (thr,channel_neural_data, sample_rate, num_stim, t0s, t_audio_stim,pausa);

%% 3) Chequeo de la detección de spikes
%Devuelve una figura con el canal neuronal seleccionado (raw data) donde marco umbral y eventos
%de spike. Para ver si lo que levanté respeta la actividad de la unidad

spikecheck (t_board_adc, t_amplifier,t0s, num_t0s, sample_rate, ... %tiempos
filtered_audio_data, channel_neural_data, spike_times, spike_tot,... %audio, canal neuronal, spikes
ave, fecha, file, thr,std_min, profundidad,name_stim, desired_channel_neural)   %datos de la tabla

%% 4) Ploteo de raster+histograma
%Devuelve tantas figuras como tipos de estimulos haya: sonograma, audio, 
%raster e histograma. 

binsize=0.010; %tamaño del bin del histograma, en segundos
points_bins= 1000; %puntos por bin para suavizado

rasterplot (num_stim, name_stim, t_audio_stim, audio_stim, L, duracion_stim, sample_rate,...  %datos del estímulo
ntrials, spike_stim, desired_channel_neural,thr,std_min,points_bins,... 
binsize, ave, fecha, file, profundidad) %datos de la tabla

%% Spike shape
%Dibuja los spikes que levanté anteriormente

w_pre=0.001; %ventana anterior del pico del spike
w_post=0.0015; %ventana posterior del pico del spike
numch=length(desired_channels_neural);

%Para poder llamar solo los 4 canales que quiero arriba
for ch = 1:numch
    channels_neural(ch)=find(chip_channels==desired_channels_neural(ch));
end

%Extract data from desired channel
channel_neural_data=filtered_neural_data(:,channels_neural);
numch=length(desired_channels_neural);

%Ploteo los spikes shapes con la funcion
spikeshape(w_pre,w_post,desired_channels_neural,desired_channel_neural,canales,channel_neural_data,...
    numch, spike_lcs_ss,sample_rate, num_stim, ave, fecha, file, name_stim, profundidad, thr, std_min)

%% Histograma de ISIS
%Para cuantificar los interspikes intervals. Solo tiene sentido para las SU
%(filtradas en los pasos anteriores)

n=1; %número que corresponde al estímulo
binsize= 1; %binsize del histograma en milisegundos
x_lim=[0 50]; %límite del eje x para el histograma en milisegundos

ISIcalculator(n,x_lim, sample_rate, num_stim, name_stim, ave, fecha, file, profundidad, desired_channel_neural, binsize, spike_lcs_ss, thr, std_min)

%% Cálculo de tasa de disparo dentro y fuera del estímulo
%Guarda en un struct las tasas de cada trial dentro y fuera; también el
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
xlabel 'Instancia del estímulo'
title 'Tasas de disparo promedio'

%Tabla con datos
        estimulo=name_stim(num_stim==n); %nombre del estimulo
        estimulo=char(estimulo(1)); %para tenerlo una sola vez
        
        colnames={'Ave', 'Fecha', 'Protocolo', 'Estimulo','Repeticiones','Profundidad', 'Canal', 'Spikes totales','Tasa fuera', 'Tasa dentro'};
        valuetable={ave, fecha, file, estimulo, ntrials(n), profundidad, desired_channel_neural, length(spike_lcs_ss{n}),tasa.promedio(1),tasa.promedio(2)};       
        t = uitable(t,'Data', valuetable, 'RowName', [], 'ColumnName', colnames,'Position', [125 30 1100 40.5]);
        



