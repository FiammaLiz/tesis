
%Hace parches que van cambiando de color para cada sílaba, traza líneas
%divisorias para ayudar en gris
for tx=1:length(textgrid.tmin)
patch([textgrid.tmin(tx) textgrid.tmax(tx)],ax(1).YLim,[0.05*tx 0.05*tx 0.05*tx],'FaceAlpha',0.2,'EdgeColor','none'); 
hold on
line(textgrid.tmin(tx),ax(1).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]);
line(textgrid.tmax(tx),ax(1).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]); 
end

%Escribe los nombres de las sílabas centrados en el parche a 3/4 de altura
for n=1:length(tgrid)
text((textgrid.tmin(n)+textgrid.tmax(n))/2,(ax(1).YLim(2))*3/4,textgrid.tier{tier}.name(n),'FontSize',10,'Interpreter','none');
end 
hold off

