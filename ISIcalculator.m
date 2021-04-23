function ISIcalculator(n,x_lim, sample_rate, num_stim, name_stim, ave, fecha, file, profundidad, desired_channel_neural, binsize, spike_lcs_ss,thr,std_min)
%%ISIcalculator
%Hace histogramas con los interspike intervals para el estimulo elegido

isi= (diff(spike_lcs_ss{1,n})/sample_rate)*1000; %calculo las diferencias entre los tiempos de los spikes levantados y las dejo en milisegundos
isifigure=figure(1);
estimulo=name_stim(num_stim==n); %nombre del estimulo
estimulo=char(estimulo(1)); %para tenerlo una sola vez

is(1)=subplot(2,1,1); %hago un subplot de su isi
yyaxis right
histogram(isi,'BinWidth', binsize,'FaceAlpha',0,'EdgeColor','none'); %segundo eje con valores absolutos
ylabel('Numero de spikes');
yyaxis left
h= histogram(isi,'BinWidth', binsize, 'Normalization','pdf'); %hago histograma de los ISIS relativizado
h.BinLimits=x_lim;
h.NumBins=x_lim(2);
ylabel('Probabilidad');
hold on
xlim(x_lim)
xlabel 'tiempo/[ms]'
title 'Interspike intervals'
hold off 
linkaxes(is,'x'); 
numspikes=length(isi);

 %tabla de datos del ave
 colnames={'Ave', 'Fecha', 'Protocolo','Profundidad', 'Estimulo', 'Canal', 'Umbral', 'Desvio', 'Spikes', 'Binsize histograma (ms)'};
 valuetable={ave, fecha, file, profundidad, estimulo, desired_channel_neural, thr, std_min, numspikes, binsize};       
 uitable(isifigure,'Data', valuetable, 'RowName', [], 'ColumnName', colnames,'Position', [50 30 1200 40.5]);
        
end