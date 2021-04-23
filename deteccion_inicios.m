 
%Datos necesarios
 silaba= 'P1(F)'; %poner identidad de sílaba que me va a interesar
 n=1; %identificador del estimulo (BOS/CON/REV)

 %Para extraer el momento temporal de la silaba en BOS
 find_sil= strfind(tg(n).tier{1,1}.Label,silaba); %encuentra los indices donde esta la silaba de interes
 sil_position_logical = ~cellfun(@isempty,find_sil); %paso a array logico para poder indexar
 sil_position_init=tg(n).tier{1,1}.T1(sil_position_logical)*sample_rate; %encuentro los valores de indice inicial 
 sil_position_end=tg(n).tier{1,1}.T2(sil_position_logical)*sample_rate;  %y el final de la silaba     

%Detecto inicios
maxvalue_silence=max(findpeaks(audio_stim{1}((tg(1).tier{1,1}.T2(end)*30000):end))); %Calculo el valor maximo de los picos en el silencio, ruido blanco
[pks,lcs]=findpeaks(audio_stim{n}(sil_position_init:sil_position_end),'MinPeakHeight',maxvalue_silence,'MinPeakProminence',maxvalue_silence*3); %Encuentro picos en la onda de sonido, dos criterios: superar el maximo del valor del ruido blanco y ademas, una cierta prominencia de tres veces ruido blanco
m=mean(diff(lcs(1:20))); %calculo la distancia media entre los indices de cada pico
found=diff(lcs); %calculo todas las distancias entre los indices de los picos
test= find(found>20*m)+1; %ahora encuentro aquellas distancias pronunciadas, que corresponderian a un silencia entre medio de dos picos=separacion entre silabas
lcs2= [lcs(1) lcs(test)]; %añado a la listita de picos el primer pico de la serie, la primera silaba
inicios_silabas=lcs2/sample_rate+tg(n).tier{1,1}.T1(sil_position_logical);

%Testeo para ver si me detecto bien los inicios de las silabas
ax(1)=subplot(1,1,1);
findpeaks(audio_stim{1}(sil_position_init:sil_position_end),'MinPeakHeight',maxvalue_silence,'MinPeakProminence',maxvalue_silence*3)
hold on
for j=1:length(lcs2)
line(lcs2(j)*[1 1],ax(1).YLim,'LineStyle','-','MarkerSize',4,'Color',[0.5 0.5 0.5]);
end

