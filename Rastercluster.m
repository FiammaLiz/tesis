%% Para hacer el raster ingresando el cluster

%% Cargo datos
addpath('C:\Users\tesistas\Documents\MATLAB\npy-matlab')
path_file= 'D:\Datos Canarios Protocolos\Datos_cantando\14_CeVio_170210\';
cd (path_file);
protocolo='protocolo3_VeNe_181025_132701'; 
load(protocolo); %cargo datos del .mat
path_function ='D:\Datos Canarios Protocolos\Scripts\';
cd (path_function);

%% Cargo clusters y spike-times
tetrode='4';
cd ([path_file 'mergeprotocolo1-2' '\Tetrodo' tetrode '\Results'])
spike_clusters=readNPY('spike_clusters.npy');
spike_clusters= cast(spike_clusters,'double');
spike_times_t=readNPY('spike_times.npy');
spike_times_t= cast(spike_times_t,'double');
cluster_list=unique(spike_clusters);
for k=1:length(cluster_list)
    ID= find(spike_clusters==cluster_list(k));
    spike_lcs_cluster=spike_times_t(ID);
    spike_times_cluster= spike_lcs_cluster/sample_rate;
    spike_times(k).cluster=spike_times_cluster';
    spike_lcs(k).cluster=spike_lcs_cluster';
end 

cd (path_function);
%% Preparando herramientas para alinear el raster

% Asigna inicios al tipo de trial

s=struct('t0s',zeros(1,length(unique(num_stim))));

for n=1:length(unique(num_stim))  %para todos los estimulos del 1 al n
s(n).t0s= t0s(num_stim==n);  %guarda en un struct todos los t0s en distintos fields por estimulo
end

% CALCULOS PARA RASTER E HISTOGRAMAS ALINEADOS CON LOS T0s
%Tiene en cuenta que el numero de trials puede no ser el mismo
%No pongo identidad de 1, 2 o 3 porque podrian no ser el mismo en todos los
%protocolos, despues los traigo de name_stim

%Cuenta las veces que se hizo cada trial y los guarda

ntrials=zeros(length(unique(num_stim)),1);

for n=1:length(unique(num_stim))  
ntrials(n)= sum(num_stim==n);
end

%Calcula ventana de tiempo hacia atras y hacia adelante del estimulo

duracion_stim=zeros(length(unique(num_stim)));
L1=zeros(1);

for n=1:length(unique(num_stim))
    duracion_stim(n)= length(t_audio_stim{n})/sample_rate; %calcula la duracion de cada estimulo en segundos
    L1(n)= (pausa-duracion_stim(n))/2; %calcula las ventanas posibles (la mitad de la distancia entre pausa y comienzo del estimulo)
end 
    L=min(L1); %scojo la ventana mas chiquita 

%% Separo los spike times de un cluster y grafico

binsize=0.008; %tamanio del bin del histograma, en segundos
points_bins= 1000; %puntos por bin para suavizado
cluster=0;
k=find(cluster_list==cluster);
    
 for m=1:(length(unique(num_stim)))  %para cada tipo de estímulo
    for l=1:ntrials(m) %y para todos los trials adentro
    found_trial{l,1}= (spike_times(k).cluster(spike_times(k).cluster<=(s(m).t0s(l)+(duracion_stim(m)+L))))> (s(m).t0s(l)-L); %#ok<*AGROW> %selecciono spikes entre estímulo dentro de mi ventana, retorna valores booleanos
    tstim{l,1} = spike_times(k).cluster(found_trial{l,1})-s(m).t0s(l);%paso a tiempo y lo relativizo a su t0 para alinear, me da tiempo en segundos donde dispara cada spike alineados
    lcstim{l,1}=spike_lcs(k).cluster(found_trial{l,1})'; %indice de spikes encontrados
    end
    spike_stim(m).trial= {tstim{1:ntrials(m),1}}; %voy guardando las celdas en el struct (instancia de spikes en segundos alineados)
 end 
 
rasterplot_clusters (num_stim, name_stim, t_audio_stim, audio_stim, L, duracion_stim, sample_rate,... 
ntrials, spike_stim,tetrode,cluster,points_bins,tg,colorp,... 
binsize, ave, fecha, file, profundidad)
