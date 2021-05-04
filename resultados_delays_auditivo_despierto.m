%Grafico resumen agrupado de data delays auditivo despierto de archivo gsheets "Datos Protocolos"

%creo una tabla y le cargo los datos
%CHEQUEAR QUE SEAN LOS DATOS FINALES
%delays=table();
%cargar los datos a mano desde el excel
%ponerle titulos a las variables (ID, Silaba, Latencia, TipoUnidad)

%cambiar coma decimal de las Latencias a puntos
%delays.Latencia = strrep(delays.Latencia, ',', '.');


%y convertir a numero posta las latencias
%sacarle el identificador del bout a Silaba (porque si no parecen distintos)
%no se hacerlo sin loopear
%for item=1:size(delays,1)
%    delays.Silaba{item}=delays.Silaba{item}(1:end-2);
%    delays.Latencia{item}= str2num(delays.Latencia{item});
%end

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
binsize=0.015;
points_bins=1000;

fig1=figure(1);
clf
s(1)=subplot(3,1,1:2);
hold on
errorbar(puntostable.puntos_media,puntostable.Var1,[],[], puntostable.puntos_sd,puntostable.puntos_sd,...
    'Color',[0.5 0.5 0.5],'LineStyle','none','Marker','none')
gscatter(puntostable.puntos_media,puntostable.Var1,puntostable.gID);
ylabel '# de unidad'

s(2)=subplot(3,1,3);
%fijarse que binwidth esta bueno usar para ksdensity
counts=histogram(puntostable.puntos_media,'BinWidth', binsize, 'Normalization','pdf');
hold on
num_points=counts.NumBins*points_bins;
[f,xi]=ksdensity(puntostable.puntos_media,'BandWidth',binsize,'NumPoints',num_points);
plot(xi,f,'LineWidth',1,'Color','r')
hold off
ylabel 'Histograma'
xlabel 'tiempo normalizado'
linkaxes(s,'x')
xlim([0,1])

[~,latencia_picos,ancho_picos]= findpeaks(f,xi);
err_picos=ancho_picos/2;
disp(['latencias relativas=' num2str(latencia_picos)]);
disp(['error=' num2str(err_picos)]);
clear ancho_picos

%A QUE LATENCIA ESTAN LOS PICOS DE LOS RESULTADOS AGRUPADOS?
%VeNe es un tercer pico o le pasó algo? (puede ser que haya tres picos).
%% el mismo grafico sin agrupar

%ojo que los colores mezclan unidades "iguales" que no lo son porque estan
%tanto mu como su incluidas
%tambien hace falta agregar etiquetas de ejes
binsize=0.015;
points_bins=1000;

fig2=figure(2);
clf
s(1)=subplot(3,1,1:2);
gscatter([delays.Latencia{:}],1:size(delays.Latencia,1),delays.ID);
%add errorbars
ylabel '#de silaba'

s(2)=subplot(3,1,3);
%fijarse que binwidth esta bueno usar para ksdensity
counts=histogram([delays.Latencia{:}],'BinWidth', binsize, 'Normalization','pdf');
hold on
num_points=counts.NumBins*points_bins;
[f,xi]=ksdensity([delays.Latencia{:}],'BandWidth',binsize,'function','pdf','NumPoints',num_points);
plot(xi,f,'LineWidth',1,'Color','r')
linkaxes(s,'x')
xlim([0,1])
hold off
ylabel 'Histograma'
xlabel 'Tiempo normalizado'

[~,latencia_picos,ancho_picos]= findpeaks(f,xi);
err_picos=ancho_picos/2;
disp(['latencias relativas=' num2str(latencia_picos)]);
disp(['error=' num2str(err_picos)]);
clear ancho_picos



%% guardo la data porlas
% save('data_delays_agrupada.mat','delays','puntostable');



