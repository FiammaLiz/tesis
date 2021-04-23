%Grafico resumen agrupado de data delays auditivo despierto de archivo gsheets "Datos Protocolos"

%creo una tabla y le cargo los datos
%CHEQUEAR QUE SEAN LOS DATOS FINALES
delays=table();
%cargar los datos a mano desde el excel
%ponerle titulos a las variables (ID, Silaba, Latencia, TipoUnidad)

%cambiar coma decimal de las Latencias a puntos
delays.Latencia = strrep(delays.Latencia, ',', '.');


%y convertir a numero posta las latencias
%sacarle el identificador del bout a Silaba (porque si no parecen distintos)
%no se hacerlo sin loopear
for item=1:size(delays,1)
    delays.Silaba{item}=delays.Silaba{item}(1:end-2);
    delays.Latencia{item}= str2num(delays.Latencia{item});
end

%me fijo que grupos (ID en determinada silaba) tengo en la tabla
[puntos,gID,gsilaba,gtipo] = findgroups(delays.ID,delays.Silaba,delays.TipoUnidad);

%tabulo los grupos
puntostable=table(unique(puntos),gID,gsilaba,gtipo);
fprintf('Hay %d grupos en los %d datos/n',size(unique(puntos),1),size(puntos,1));


%tomo medida de resumen de cada grupo
for s = 1:size(unique(puntos),1)
    
    index=puntos==s;
    datosgrupo=vertcat(delays.Latencia{index});
%     puntos_grupo(s)={index};
    puntos_media(s,:)=mean(datosgrupo,1);
    puntos_sd(s,:)=std(datosgrupo,[],1);
    puntos_n(s,:)=size(datosgrupo,1);
end

%agrego columnas con las medidas de resumen

puntostable = addvars(puntostable, puntos_media,puntos_sd,puntos_n);


%% hago un scatter rapidito de tanto mu como su 
%ojo que los colores mezclan unidades "iguales" que no lo son porque estan
%tanto mu como su incluidas
%tambien hace falta agregar etiquetas de ejes

fig1=figure(1);
clf
s(1)=subplot(3,1,[1:2]);
hold on
errorbar(puntostable.puntos_media,puntostable.Var1,puntostable.puntos_sd,puntostable.puntos_sd,[],[],...
    'Color',[0.5 0.5 0.5],'LineStyle','none','Marker','none')
gscatter(puntostable.puntos_media,puntostable.Var1,puntostable.gID);

s(2)=subplot(3,1,3);
%fijarse que binwidth esta bueno usar para ksdensity
ksdensity(puntostable.puntos_media,'BandWidth',0.007)
ylabel 'Curva de histograma suavizada'
xlabel 'Tiempo desde el comienzo de la sílaba(s)'
linkaxes(s,'x')
xlim([0,3])

%[~,lcs,ancho_picos]=findpeaks(f,'Annotate','extents','WidthReference','halfheight');
%latencias_promedio=x(lcs);


%A QUE LATENCIA ESTAN LOS PICOS DE LOS RESULTADOS AGRUPADOS?
%VeNe es un tercer pico o le pasó algo? (puede ser que haya tres picos).
%% el mismo grafico sin agrupar

%ojo que los colores mezclan unidades "iguales" que no lo son porque estan
%tanto mu como su incluidas
%tambien hace falta agregar etiquetas de ejes

fig2=figure(2);
clf
s(1)=subplot(3,1,1:2);
gscatter([delays.Latencia{:}],1:size(delays.Latencia,1),delays.ID);
%add errorbars
ylim([0,22])
ylabel ('Número de silaba','FontSize',12)

s(2)=subplot(3,1,3);
%fijarse que binwidth esta bueno usar para ksdensity
counts= histogram([delays.Latencia{:}], 'BinWidth', 0.05,'Normalization','pdf','EdgeColor','k','FaceColor','black');
num_points=counts.NumBins*1000;
hold on
[f,xi]=ksdensity([delays.Latencia{:}],'BandWidth',0.08,'function','pdf','NumPoints',num_points);
plot(xi,f,'LineWidth',2,'Color','r')
ylabel ('Histograma','FontSize',12)
xlabel ('Tiempo desde el comienzo de la sílaba relativizado(s)','FontSize',12)

linkaxes(s,'x')
xlim([0,1.1])


%% guardo la data porlas
% save('data_delays_agrupada.mat','delays','puntostable');



