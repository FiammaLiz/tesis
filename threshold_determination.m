%para cargar frases
clear all;close all;

par.database='C:\Users\Ceci\Google Drive\Soft\Database_code\PhrasedB_200305.mat';
par.bird_tag='VioAma';
par.day_tag='171117';
par.phrase_tag='A';
par.type_of_phrase='P1';

%para establecer parametros por file
% par.filename='trigger_VioAma_171117_123739.rhd';

if or(isequal(par.bird_tag,'CeVio'),isequal(par.bird_tag,'RoNa'))
    par.sample_rate=20000;
else
    par.sample_rate=30000;
end

    % Define parameters
    params.fs=par.sample_rate;
    params.birdname=par.bird_tag;
    params=def_params(params);
    params.o_thresh=0.05; % in case automatic segmentation fails 0.0275

% Carga de archivo
load(par.database,'PhrasedB')
% Busco archivo usando parametros
test=strcmp(PhrasedB(:,1),par.bird_tag) & strcmp(PhrasedB(:,2),par.day_tag) & ...
     strcmp(PhrasedB(:,7),par.phrase_tag); %Filas de ese dia y esa frase
test_index=find(test);
sounds_segmented=PhrasedB(test,12); % P0s de cada frase
num_phrases=length(test_index);
syll_nums_ori=cellfun('length',sounds_segmented);

%%
   
for phrasenum = 1:num_phrases
 clear z z2 z3

stacked_sounds=vertcat(sounds_segmented{phrasenum,:});
reconstituted_phrase=vertcat(stacked_sounds{:,:});
       
sound = reconstituted_phrase;

% lo que hay en find_gte

% Compute absolute value of Hilbert Transform from input
s=abs(hilbert(sound));
z(1)=0; % Integration for smoothing (1 ms time window)
z2(1)=0;
for ka=1:1:(length(sound)-1)
z(ka+1)=z(ka)+(1/params.fs)*(-1/(params.expf)*z(ka)+s(ka)); % integrate forward
end

for kb=1:1:(length(sound)-1)
z2(kb+1)=z2(kb)+(1/params.fs)*(-1/(params.expf)*z2(kb)+s(end-kb)); % integrate back
end
z3=0.5*(z+fliplr(z2)); % average both integrations = smooth with no delay
env=fliplr(sgolayfilt(fliplr(z3),4,params.ft)); % filter it
env_norm=env./max(env);



% %onsets solo con umbral (diff marca donde cruza el umbral)
[~,onsets]=findpeaks(diff(env_norm>params.o_thresh),'MinPeakDistance',round((params.deadtime)*params.fs));

%% umbral adaptativo de 1s
window_th=100; %(in ms) 100ms va bien para P1

adapt_thr_unsmoothed = movmean(env_norm,window_th*params.fs/1000)/3;
%smoothing de esto 
adapt_thr = movmean(adapt_thr_unsmoothed,window_th*params.fs/1000);

[~,onsets_adaptive]=findpeaks(diff(env_norm>adapt_thr),'MinPeakDistance',round((params.deadtime)*params.fs));



%% ploteo la comparacion con el umbral adaptativo
fig1=figure(1);
clf
plot(sound./max(sound),'Color',[0.5 0.5 0.5 0.5])
hold on
plot(env_norm,'k')
plot(adapt_thr,'c')
plot(adapt_thr_unsmoothed,'b')

a=gca;
line([a.XLim(1) a.XLim(2)],[params.o_thresh params.o_thresh],'Color','m')

    line((onsets'*[1 1])',[a.YLim(1),a.YLim(2)],'LineWidth',0.5,'LineStyle','--','Color','m');
    line((onsets_adaptive'*[1 1])',[a.YLim(1),a.YLim(2)],'LineWidth',0.5,'LineStyle','-.','Color','c');
ylim([0 1])
% con el umbral adaptativo recupero aprox la misma cantidad de onsets que con el
% umbral fijo, lo cual está bueno. No sé si se respeta que siempre lo voy a
% poder determinar como un tercio de la media para canarios. si fuera asi
% seria un gol no tener que setear el umbral como parametro (aunque el
% parametro escondido que aparece seria esta proporcion 1/3).

 


   annotation('textbox',[0.9 0.4 0.0664 0.5309],'String',[num2str(size(onsets,2)) ' onsets fixedthr'],'Color','m','FitBoxToText','on','EdgeColor','none','FontWeight','bold') 
   annotation('textbox',[0.9 0.375 0.0664 0.5309],'String',[num2str(size(onsets_adaptive,2)) ' onsets adaptthr'],'Color','c','FitBoxToText','on','EdgeColor','none','FontWeight','bold') 
  box off
set(a,'xtick',[])
set(a,'xticklabel',[])
set(a,'ytick',[])
set(a,'yticklabel',[])
pause
%     set(fig1,'Position',[9.2    455.6    1686.3    420.2]);
%     savefig(fig1,['C:\Users\Ceci\Desktop\Phrase_' num2str(phrasenum) '.fig'],'compact')
%     print(fig1,['C:\Users\Ceci\Desktop\Phrase_' num2str(phrasenum) '.png'],'-dpng','-painters','-cmyk');


end

% %% pruebas anteriores
% %%
% plot(sound)
% 
% plot(s)
% 
% plot(z3)
% 
% plot(env)
% 
% plot(env_norm)
% 
% plot(log10(env))
% 
% %onsets solo con umbral (diff marca donde cruza el umbral)
% [~,onsets]=findpeaks(diff(env_norm>params.o_thresh),'MinPeakDistance',round((params.deadtime)*params.fs));
% 
% %para hacer yo quiero un umbral pero sobre una transformada log de la env
% %asi recupero las silabas del ppio.
% 
% % o hacer un umbral adaptativo??? onda normalizar cada pedacito
% 
% 
% %% transformando la señal con log
% plot(env_norm)
% hold on
% transf = log10(env);
% raised = transf+abs(min(transf));
% transf_norm = raised./max(raised);
% new_env=transf_norm-prctile(transf_norm,[15]);
% plot(new_env)
% 
% [~,onsets_newenv]=findpeaks(diff(new_env>params.o_thresh),'MinPeakDistance',round((params.deadtime)*params.fs));
% 
% 
% %% ploteo la comparacion con la transformada
% plot(env)
% a=gca;
% hold on
%     line((onsets'*[1 1])',[a.YLim(1),a.YLim(2)],'LineWidth',0.5,'LineStyle','-','Color','r');
%     line((onsets_newenv'*[1 1])',[a.YLim(1),a.YLim(2)],'LineWidth',0.5,'LineStyle','--','Color','k');
% 
% % la transformacion mejora la deteccion en las primeras
% % pero tambien agrega muchos espurios que la otra forma no
% % además, no se cuanto bajar al transf_norm (yo la bajé hasta el percentil
% % 15, pero esto puede variar calculo)
% 
% 
% %% lo que hay en s01
% squared_sound=sound.*sound;
% binned_sound=buffer(squared_sound,100);
% avg_binned_sound=sum(binned_sound,1)'/100;
% envelope_for_onsets=smooth(avg_binned_sound);
% envelope_for_onsets(log10(envelope_for_onsets)==-Inf)=NaN;
% 
% plot(log10(envelope_for_onsets))
% 
% %maxima in derivative of log env (diff marca donde sube con mayor pendiente de una env bien suavizada)
% [~,onset_timestamps]=findpeaks(diff(log10(envelope_for_onsets)),'MinPeakProminence',0.2*max(diff(log10(envelope_for_onsets))),...
%     'MinPeakHeight',0.1*max(diff(log10(envelope_for_onsets))),'MinPeakDistance',2);
% 
