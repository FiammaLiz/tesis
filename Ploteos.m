%Script donde llamo a las distintas funciones para plotear
%los datos preprocesados levantados con Levantar_data.m
%Versión 15/07/2020
%Fiamma Liz Leites

%% Cargo el protocolo preprocesado y me voy al directorio de las funciones

path_file= '/home/alex/Documents/Fiamma/Datos_Canarios_Playback/ca313-VioAzu_2018-2019/190307/';
cd (path_file); 
protocolo='protocolo3_VioAzu_190307_120148.mat'; 
load(protocolo); %cargo datos del .mat
path_function ='/home/alex/Documents/Fiamma/Scripts/Scripts_Fiamma';
cd (path_function);


%% Visualizar raw data
%Devuelve graficados la senial testigo, el espectograma estiquetado con los
%estimulos y la senial de los cuatro canales del tetrodo con marcas de
%inicio y fin de los estimulos.

desired_channels_neural= 12:15;
canales= '12 a 15';
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
t0s, name_stim, y, sample_rate) %datos de la tabla

%% Detección de spikes
%Filtra por el umbral seleccionado la raw data y luego los guarda en un
%struct según el tipo de estímulo y trial al que pertenezcan

%Si extraje un grupo de canales
desired_channel_neural= 19; %este es el canal que quiero
channels_neural=find(chip_channels==desired_channel_neural); %para llamar al canal que quiero

%Extract data from desired channel
channel_neural_data=filtered_neural_data(:,channels_neural);

%Si solo extraje un canal del protocolo
%desired_channel_neural= 19; %este es el canal que quiero
%channel_neural_data=filtered_neural_data';

%Umbral de detección
 %Criterio 1: Cálculo de umbral con desvío estándar
  % std_min=7; %Desvío estándar
  %abs_neural_data= abs(channel_neural_data); %Valor absoluto de los datos
  %std_noise_detect=median(abs_neural_data)/0.6745; %Calcula desvío estandar de mediana de los datos
  %thr= std_min*std_noise_detect; %calcula thr como x desvíos estandar de la mediana
  
  %Criterio 2: Asigno manualmente el umbral
  thr=-100; 
  
spikedetection (thr,channel_neural_data, sample_rate, num_stim, t0s, t_audio_stim,pause);

%% Chequeo de la detección de spikes
%Devuelve una figura con el canal neuronal seleccionado (raw data) donde marco umbral y eventos
%de spike

spikecheck (t_board_adc, t_amplifier,t0s, num_t0s, sample_rate, ... %tiempos
filtered_audio_data, channel_neural_data, spike_times, spike_tot,... %audio, canal neuronal, spikes
ave, fecha, file, thr, profundidad,name_stim, desired_channel_neural)   %datos de la tabla

%% Ploteo de raster
%Devuelve tantas figuras como tipos de estimulos haya: sonograma, audio, 
%raster e histograma

binsize=0.010; %tamaño del bin del histograma, en segundos

rasterplot (num_stim, name_stim, t_audio_stim, audio_stim, L, duracion_stim, sample_rate,...  %datos del estímulo
ntrials, spike_stim, desired_channel_neural, thr,... 
binsize, ave, fecha, file, profundidad) %datos de la tabla





