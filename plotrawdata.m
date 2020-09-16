function plotrawdata (ave, fecha, file, profundidad, canales, numch,t_amplifier, t_board_adc,channel_neural_data, filtered_audio_data, filtered_stimuli_data, t0s, name_stim, y, sample_rate, desired_channels_neural)
%Grafica los datos levantados con Levantar_data
%Devuelve graficados la senial testigo, el espectograma estiquetado con los
%estimulos y la senial de los cuatro canales del tetrodo con marcas de
%inicio y fin de los estiulos.

%Espectograma del estímulo
    window_width=sample_rate/100;   %points
     [~,f,t,p] = spectrogram(filtered_audio_data,...
         gausswin(window_width,5),...
         ceil(0.75*window_width),...
         linspace(0,ceil(sample_rate/2),...
         round(sample_rate/window_width)),...
         sample_rate,'yaxis');
     
       
r1=figure(1);
clf
num_fig=3+numch; %número de subplots de acuerdo a la cantidad de canales que ingrese

%Canal testigo
 h(1)= subplot(num_fig,1,1);
 plot(t_board_adc,filtered_stimuli_data,'Color','k'); 
 ylabel ('Canal testigo','FontSize',9)
 line((t0s'*[1 1])',h(1).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.3 0.3 0 0.6]); 
 title 'Raw data: canal testigo, espectograma y canales neuronales';

%Espectograma
 h(2)=subplot(num_fig,1,2);
 imagesc('XData',t,'YData',f,'CData',10*log10(p(1:100,:)));
    colormap(flipud(jet));
    ylim([0 10000]);
    text(t0s,y,name_stim,'FontSize',10,'Interpreter','none'); %etiqueta qué estimulo es al principio del estímulo
    line((t0s'*[1 1])',h(2).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.3 0.3 0 0.6]); 
    ylabel ('frecuencia/[Hz]','FontSize',9);
%     title 'Espectrograma';
 
 %Canales de la señal neuronal
lim_ejey=[-500 500];
 for ch = 1:numch
     h(2+ch)= subplot(num_fig,1,2+ch);
     plot(t_amplifier,channel_neural_data(:,ch));
     ylim(lim_ejey);
     ylabel ({['Ch' num2str(desired_channels_neural(ch))],'Voltaje/[mV]'}, 'FontSize',9);
%     title 'Raw data neuronas';
    hold on
    
    %forma con markers
%     plot(t0s,0,'-s','MarkerFaceColor','red','MarkerSize',6) %plotea las marquitas de inicio del estímulo
%     plot(pos_fin_stimuli,0,'-p','MarkerFaceColor','red','MarkerSize',6) %plotea las marquitas de fin del estímulo
    
%     forma con lineas verticales
    line((t0s'*[1 1])',lim_ejey,'LineStyle','-','MarkerSize',4,'Color',[0.3 0.3 0 0.6]);    

    %forma con patches  (no la codee)
%     patch(xvertices,yvertices,[0.8 0.8 0.8],'FaceAlpha',0.5,'EdgeColor','none');

    hold off
 end
      xlabel 'tiempo/[s]';
      
   equispace(r1);
   linkaxes(h,'x');
   
        colnames={'Ave', 'Fecha', 'Protocolo','Profundidad','Canales'};
        valuetable={ave, fecha, file, profundidad, canales};       
        uitable(r1,'Data', valuetable, 'RowName', [], 'ColumnName', colnames,'Position', [330 30 560 40.5]);
end 