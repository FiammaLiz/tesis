
function tasadisparos (s, n, L, num_stim, name_stim, sample_rate, spike_lcs_ss, duracion_stim, ave, fecha, file, ntrials, profundidad, desired_channel_neural)
%%TASADISPAROS
%Cálculo de tasa de disparo dentro y fuera del estímulo
%Guarda en un struct las tasas de cada trial dentro y fuera; también el
%promedio con su desvio y hace un gráfico de barras con los promedios.
%Fiamma Liz Leites
%Matlab 2017a

for t0=1:length(s(n).t0s)
    v_ini=spike_lcs_ss{1,n}(spike_lcs_ss{1,n}>s(n).t0s(t0)*sample_rate);
    spikes_dentro= spike_lcs_ss{1,n}(v_ini<(s(n).t0s(t0)+duracion_stim(n))*sample_rate);
    tasa.dentro(t0)=length(spikes_dentro)/duracion_stim(n);
end 

for t0=1:length(s(n).t0s)
    v_ini=spike_lcs_ss{1,n}(and(spike_lcs_ss{1,n}<s(n).t0s(t0)*sample_rate,spike_lcs_ss{1,n}>(s(n).t0s(t0)-L)*sample_rate));
    v_fin=spike_lcs_ss{1,n}(and(spike_lcs_ss{1,n}>(s(n).t0s(t0)+duracion_stim(n))*sample_rate,spike_lcs_ss{1,n}<(s(n).t0s(t0)+duracion_stim(n)+L)*sample_rate));
    spikes_fuera= [v_ini, v_fin];
    tasa.fuera(t0)=length(spikes_fuera)/(L*2);
end 

tasa.promedio(1)=mean(tasa.dentro);
tasa.promedio(2)=mean(tasa.fuera);
tasa.std(1)= std(tasa.dentro);
tasa.std(2)=std(tasa.fuera);
move_to_base_workspace(tasa);

name_bar = categorical({'Dentro','Fuera'});
tasas_prom = [tasa.promedio(1) tasa.promedio(2)];
t=figure(1);
b= subplot(2,1,1);
bar(name_bar,tasas_prom,'FaceColor','flat');
hold on
errorbar(1,tasa.promedio(1),tasa.std(1),'Color','k','LineWidth',1.5);    
errorbar(2,tasa.promedio(2),tasa.std(2),'Color','k','LineWidth',1.5);    
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
        
return

 function move_to_base_workspace(variable)

% move_to_base_workspace(variable)
%
% Move variable from function workspace to base MATLAB workspace so
% user will have access to it after the program ends.

variable_name = inputname(1);
assignin('base', variable_name, variable);

return;
