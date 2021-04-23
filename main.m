% main script for gte work
clear all;close all;
cd D:\Users\Ceci\Documents\LSD_Ceci\Scripts\Matlab\GTE_ceci

% par.database='C:\Users\Ceci\Google Drive\Soft\Database_code\PhrasedB_200406.mat';
par.database='C:\Users\Ceci\Google Drive\Soft\Database_code\PhrasedB_200507_LFPfreq.mat';

par.bird_tag='CeVio';
par.day_tag='170105';
par.phrase_tag='G';
par.type_of_phrase='P1';

%para establecer parametros por file
% par.filename='trigger_VioAma_171117_123739.rhd';

if or(or(isequal(par.bird_tag,'CeVio'),isequal(par.bird_tag,'RoVe')),isequal(par.bird_tag,'BlaVio'))
    par.sample_rate=20000;
else
    par.sample_rate=30000;
end

    % Define parameters
    params.fs=par.sample_rate;
    params.birdname=par.bird_tag;
    params=def_params(params);
%     params.prop_th=3; % in case automatic segmentation fails 0.0275

% load(par.database,'PhrasedB')
load(par.database,'PhrasedB2')
PhrasedB=PhrasedB2;
clear PhrasedB2

%este funciona para PhrasedB2
test=strcmp([PhrasedB{:,1}],par.bird_tag) & strcmp([PhrasedB{:,2}],par.day_tag) & ...
     strcmp(PhrasedB(:,7),par.phrase_tag)'; %Filas de ese dia y esa frase

% % Busco archivo usando parametros
% test=strcmp(PhrasedB(:,1),par.bird_tag) & strcmp(PhrasedB(:,2),par.day_tag) & ...
%      strcmp(PhrasedB(:,7),par.phrase_tag); %Filas de ese dia y esa frase
test_index=find(test)
% sounds_segmented=PhrasedB(test,12); % P0s de cada frase
num_phrases=length(test_index);
onsets_ori = PhrasedB(test,10);
syll_nums_ori=cellfun('length',onsets_ori);

%opcion uno puedo cargar t0 y motif_list desde la database y que esto
%recorte la frase
%u opcion 2 yo generar motifs(k).sound (struct) con los sonidos de las frases
%reconstituidos (USE ESTA OPCION) o bien cargando el file y volviendo a recortar

%OJO si no tiene la misma cantidad de onsets que mi dB, se va a saltear
%silabas el raster y a mi me interesan las del ppio

%para cada frase de ese tipo encontrada en el file
%detecta los gte segun la frase del db
%NO RECONSTITUIR! INCLUIR LA FRASE EN LA DB
%reconstituida a partir de sus
%segmented syllables

%     stacked_sounds=vertcat(sounds_segmented{k,:});
%     reconstituted_phrase=vertcat(stacked_sounds{:,:});
for k = 1:num_phrases
%     for k =3
    motifs(k).sound=PhrasedB{test_index(k),21};
    [motifs(k).gtes,motifs(k).env_norm,motifs(k).d,motifs(k).d2,params]=find_gte(motifs(k).sound,params);
%     plotgte(motifs(k),params);
%     pause
    % To print figures for individual motifs, uncomment following line:
    % print(['./songs/' birdname '_' num2str(k) '_.ps'],gcf,'-depsc','-r300','-painters');
    % Tests for instances to be in majority of motifs before accepting them
    % Using params.coincidence within each syllable. If it's at least in half
    % of the motifs where that syllable is present, it keeps it.
    %[motifs]=testrobust(motifs,motif_list,params);
    % Plots all motifs and the selected relevant instances 
    % (each motif might vary slightly than individual figs, because robustness
    % was tested afterwards)
%     plotgteall(motifs,params);

    %
    %print(['./songs/' birdname '.ps'],gcf,'-depsc','-r300','-painters')
end

%% correct, re-reference to syllable and save in phrase/syllable envelope cell

for i = 1:num_phrases
%     for i=3
    %All GTEs for the phrase in samples from start of phrase
    onsets = motifs(i).gtes.gtes1;
    offsets = motifs(i).gtes.gtes2;
    minima = motifs(i).gtes.gtes3;
    maxima = motifs(i).gtes.gtes4;

    %checks for discrepancies in number of syllables in dB
    if length(onsets) ~= syll_nums_ori(i)
        sprintf('Phrase %d i=%d has %d sylls but db has %d',test_index(i),i,length(onsets),syll_nums_ori(i))
    end
    
    %re-reference onsets to file start to override database next time
    t0=PhrasedB{test_index(i),15};
    
    ati = PhrasedB{test_index(i),5};
    atis=round((ati-t0)*par.sample_rate);  %converted to samples
    
    phrase_sound=PhrasedB{test_index(i),21};
     
    
      clear f t p
                %Calculate segment spectrogram
            window_width=10*par.sample_rate/1000;   %points
            [~,f,t,p] = spectrogram(phrase_sound,...
            gausswin(window_width,2),round(0.95*window_width),...
            linspace(0,round(par.sample_rate/2),round(par.sample_rate/window_width)),...
            par.sample_rate,'yaxis');
    %%
    figure(1) %seria como el chequeo que hago en las corrected figs
    clf
    subplot(2,1,1)
% plot(atis:atis+length(PhrasedB{test_index(i),21})-1,PhrasedB{test_index(i),21},'k');
plot(phrase_sound,'k');
ax=gca;
hold on

% line((onsets_ori{i}-atis*[1 1])',ax.YLim,'LineWidth',1.5,'Color','m');
line((onsets*[1 1])',ax.YLim,'LineWidth',1.5,'Color','b');
line((offsets*[1 1])',ax.YLim,'LineWidth',1.5,'Color','b');

% line((minima*[1 1])',ax.YLim,'LineWidth',1.5,'Color','g');
% line((maxima*[1 1])',ax.YLim,'LineWidth',1.5,'Color','g');

    subplot(2,1,2)
            hold on

            imagesc('XData',t*par.sample_rate,'YData',f,'CData',10*log10(p(1:100,:)));
            colormap(flipud(hot))
            ylim([0 10000])
            ax2=gca;
            line((onsets*[1 1])',ax2.YLim,'LineWidth',1,'Color','g','LineStyle','--');
line((offsets*[1 1])',ax2.YLim,'LineWidth',1,'Color','b','LineStyle','--');

linkaxes([ax,ax2],'x');

%para corregir
  disp('Type <a href="matlab:dbcont">dbcont</a> or press F5 to continue');
  keyboard;    
    
    newonsets{i,1}=test_index(i);
    newonsets{i,2}=onsets+atis; 
    
    for j = 1:length(onsets)
        
        current_onset=onsets(j);
        current_offset=offsets(j);
        
        %si es la ultima de la frase, tomo hasta el final de la frase
        %(siempre lo hice asi)
        if j==length(onsets)
          current_sound = motifs(i).sound(current_onset:length(motifs(i).sound));
          current_envelope_normalized=motifs(i).env_norm(current_onset:length(motifs(i).sound));
        else
          current_sound = motifs(i).sound(current_onset:onsets(j+1));
          current_envelope_normalized=motifs(i).env_norm(current_onset:onsets(j+1));
        end
        
        envelopes{i,7}{j,1}=current_sound;
        envelopes{i,1}{j,1}=current_envelope_normalized'; %transpuesto para matchear lo que tenia

        %NO VOY A GUARDAR MAX NI MIN POR AHORA
%         %gtes in current syll
%         max_in_syll=maxima(maxima>=current_onset & maxima<current_offset);
%         if not(length(max_in_syll)==1)
%             display('More than one maximum found!')
%         end
%         min_in_syll=minima(minima>=current_onset & minima<current_offset);
% 
%         %ver cuales guardo. por ahora, el maximo y el minimo anterior mas
%         %cercano. ojo si hay mas de un maximo
% %         earlier_min_in_syll=min_in_syll(min_in_syll<max_in_syll);
%         later_min_in_syll=min_in_syll(min_in_syll>max_in_syll);
%         [~,loc_closest_min]=min(abs(max_in_syll-later_min_in_syll));
%         closest_min = later_min_in_syll(loc_closest_min);
        
        %re-referencio al onset
        envelopes{i,3}{j,1}=current_onset-current_onset+1;
        envelopes{i,4}{j,1}=current_offset-current_onset+1;
%         envelopes{i,5}{j,1}=max_in_syll-current_onset+1;
%         envelopes{i,6}{j,1}=closest_min-current_onset+1;

        envelopes{i,9}{j,1} = j;
        
        % plot per syllable to check

%         figure(1)
%         clf
%         plot(envelopes{i,1}{j,1},'Color','b')
%         hold on
%         line([envelopes{i,3}{j,1} envelopes{i,3}{j,1}]',[0 0.5],'Color','g')
%         line([envelopes{i,4}{j,1} envelopes{i,4}{j,1}]',[0 0.5],'Color','r')
%         line([envelopes{i,5}{j,1} envelopes{i,5}{j,1}]',[0 0.5],'Color','k')
%         try
%         line([envelopes{i,6}{j,1} envelopes{i,6}{j,1}]',[0 0.5],'Color','m')
%         catch
%             continue
%         end
%         pause

    end
    
  
end
%%
num_phrases = size(envelopes,1);
for i = 1:num_phrases
    
    for j = 1:length([envelopes{i,3}{:,1}])
%         plot per syllable to check

        figure(1)
        clf
        plot(envelopes{i,1}{j,1},'Color','b')
        hold on
        line([envelopes{i,3}{j,1} envelopes{i,3}{j,1}]',[0 0.5],'Color','g')
        line([envelopes{i,4}{j,1} envelopes{i,4}{j,1}]',[0 0.5],'Color','r')
%         line([envelopes{i,5}{j,1} envelopes{i,5}{j,1}]',[0 0.5],'Color','k')
%         try
%         line([envelopes{i,6}{j,1} envelopes{i,6}{j,1}]',[0 0.5],'Color','m')
%         catch
%             continue
%         end
%         pause

    end
    
  
end

%% sobreescribir database con los onsets nuevos
display('overwriting phrasedb2')
for n=1:size(newonsets,1) 
    PhrasedB(newonsets{n,1},10)=newonsets(n,2);
end

PhrasedB2=PhrasedB;
save(par.database,'PhrasedB2','-append')

%faltaria joinear distintos envelopes files de la misma sesion
% save(['D:\Users\Ceci\Documents\LSD_Ceci\Scripts\Matlab\Experimentos_Tetrodos_v3_Cronicos\180515_Threshold_Crossing\CeVio_170125\',...
%     'P1_A_CeVio_170125_features_santi_corr.mat'],'envelopes','newonsets','params')

save(sprintf('C:\\Users\\Ceci\\Desktop\\%s_%s_%s_%s_features_santi_corr.mat',par.type_of_phrase,par.phrase_tag,par.bird_tag,par.day_tag),'envelopes','newonsets','params')
