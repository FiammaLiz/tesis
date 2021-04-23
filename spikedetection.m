function spikedetection (maximo, minimo, thr, channel_neural_data, sample_rate, num_stim, t0s, t_audio_stim, pausa)
%Deteccion de spikes
%Filtra por el umbral seleccionado la raw data y luego los guarda en un
%struct segun el tipo de estimulo y trial al que pertenezcan
%Matlab 2018a
%Fiamma Liz Leites

% SPIKE DETECTION
 %Busco elementos que crucen el umbral, teniendo en cuenta si el umbral
  %es positivo o negativo


 
 if thr < 0 %si el umbral es negativo
    [~,spike_lcs1]=findpeaks(-channel_neural_data','MinPeakHeight',-thr); %Encuentra los minimos
    spike_lcs2=find(channel_neural_data<maximo & channel_neural_data>minimo)';
    spike_lcs=intersect(spike_lcs1,spike_lcs2);
 else
    [~,spike_lcs]=findpeaks(channel_neural_data','MinPeakHeight',thr); %Si es positivo, los maximos
 end 
move_to_base_workspace(spike_lcs);
spike_times = spike_lcs/sample_rate; %Lo paso a tiempo en segundos, porque spike_lcs es en samples
move_to_base_workspace(spike_times);
spike_tot=length(spike_times); %Este es el numero de spikes que encontro
move_to_base_workspace(spike_tot);

%Me avisa cuantos spikes encontro con ese umbral:
fprintf('\n\n\nHAY %d EVENTOS QUE SUPERAN EL UMBRAL DE %d\n\n\n',spike_tot,round(thr))

% Asigna inicios al tipo de trial

for n=1:length(unique(num_stim))  %para todos los estimulos del 1 al n
s(n).t0s= t0s(num_stim==n);  %guarda en un struct todos los t0s en distintos fields por estimulo
end
move_to_base_workspace(s); 

% CALCULOS PARA RASTER E HISTOGRAMAS ALINEADOS CON LOS T0s
%Tiene en cuenta que el numero de trials puede no ser el mismo
%No pongo identidad de 1, 2 o 3 porque podrian no ser el mismo en todos los
%protocolos, despues los traigo de name_stim

%Cuenta las veces que se hizo cada trial y los guarda
for n=1:length(unique(num_stim))  
ntrials(n)= sum(num_stim==n);
end
move_to_base_workspace(ntrials);

%Calcula ventana de tiempo hacia atras y hacia adelante del estimulo
for n=1:length(unique(num_stim))
    duracion_stim(n)= length(t_audio_stim{n})/sample_rate; %calcula la duracion de cada estimulo en segundos
    L1(n)= (pausa-duracion_stim(n))/2; %calcula las ventanas posibles (la mitad de la distancia entre pausa y comienzo del estimulo)
end 
    L=min(L1); %escojo la ventana mas chiquita 
    
move_to_base_workspace(duracion_stim);
move_to_base_workspace(L);

% Separa los spikes por tipo de estimulo y por trial, guarda
%todo en un struct de celdas si es mas de un estimulo, sino lo hace
%para uno solo en una variable

 for m=1:(length(unique(num_stim)))  %para cada tipo de estimulo
    for l=1:ntrials(m) %y para todos los trials adentro
    found_trial{l,1}= (spike_times(spike_times<=(s(m).t0s(l)+(duracion_stim(m)+L))))> (s(m).t0s(l)-L); %selecciono spikes entre estimulo dentro de mi ventana, retorna valores booleanos
    tstim{l,1} = spike_times(found_trial{l,1})-s(m).t0s(l);%paso a tiempo y lo relativizo a su t0 para alinear, me da tiempo en segundos donde dispara cada spike alineados
    lcstim{l,1}=spike_lcs(found_trial{l,1})'; %indice de spikes encontrados
    end
 spike_stim(m).trial= {tstim{1:ntrials(m),1}}; %voy guardando las celdas en el struct (instancia de spikes en segundos alineados)
 spike_lcs_ss{m}=cell2mat(lcstim)'; %agrupo en celdas todos los indices de spikes por estimulo (para spike shape)
 end
 move_to_base_workspace(spike_stim);
 move_to_base_workspace(spike_lcs_ss);
 
return

    function move_to_base_workspace(variable)

% move_to_base_workspace(variable)
%
% Move variable from function workspace to base MATLAB workspace so
% user will have access to it after the program ends.

variable_name = inputname(1);
assignin('base', variable_name, variable);

return;