%% Convert data
%Guarda los registros neuronales del Intan en un archivo binario,
%seleccionando los tetrodos

%% Defino cosas
clear
close all

path_file = 'D:\Datos Canarios Protocolos\ca219-VeNe_2018-2019\181030\';
file = 'protocolo4_VeNe_181030_190902';
cd(path_file);
load(file);

%% Seleccion de tetrodo/canales

%Selecciono tetrodo que quiero o todos los canales
%desired_channels_neural=8:11; tetrode='tetrodo 1';
%desired_channels_neural=12:15; tetrode='tetrodo 2';
%desired_channels_neural=16:19; tetrode='tetrodo 3';
desired_channels_neural=20:23; tetrode='tetrodo 4';

%% Opción 1: raw data sin filtrar

path_function ='D:\Datos Canarios Protocolos\Scripts\Lectura de Intan';
cd (path_function);

filename = [path_file file '.rhd'];
read_Intan_RHD2000_file(filename); %Levanto datos con el Read_Intan

%Extract data from desired channel
channel_neural_data=amplifier_data(channels_neural,:);

%% Opción 2: limpieza de artefactos

thr=[250 -300]; %umbral positivo o negativo para detectar los artefactos
numch=16; %cantidad de canales
noisy=2; %trial mas ruidoso para comparar el antes y el después
[filtered_neural_data_clean]=cleanartifacts(filtered_neural_data,t_board_adc,thr,numch,noisy);

%% Preparo los canales
%Para hallar el canal deseado en amplifier_channels

numch=length(desired_channels_neural); %cuantos canales son
chip_channels=[amplifier_channels.chip_channel]; %correspondencia de numero de canal e indice

channels_neural= zeros(1,numch);
for ch = 1:numch
    channels_neural(ch)=find(chip_channels==desired_channels_neural(ch));
end

%Extract data from desired channel
channel_neural_data=filtered_neural_data_clean(:,channels_neural)'; %OJO: tiene que quedar en formato ch x data

%% Guardo en un archivo binario para Kilosort

cd(path_file);
fid = fopen([file '-' tetrode '.bin'],'w');
count = fwrite(fid,channel_neural_data,'*int16'); 
fclose(fid);

%% Chequeo que se guardó bien

channel_neural_data_test=channel_neural_data';

fid = fopen([file '-' tetrode '.bin'],'r');
test = fread(fid,[4 inf],'*int16')';
fclose(fid);


a(1)=subplot(2,1,1);
plot(channel_neural_data_test(:,1));

a(2)=subplot(2,1,2);
plot(test(:,1));

linkaxes(a);

clear test
clear channel_neural_data_test
clear channel_neural_data
clear a

