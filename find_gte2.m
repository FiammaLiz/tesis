function [gtes,env_norm,d,d2,params] = find_gte2(sound,params)
% this function extracts GTEs for each syllable. 
% Inputs: sound: song syllable, including silent gap aparams.fter syllable onset
%         params: struct with fields: fs (sampling frequency)
%                                     deadtime (onset detector deadtime)
% Outputs: gtes: list of gtes for the syllable
%%
% Compute absolute value of Hilbert Transform from input
s=abs(hilbert(sound));
z(1)=0; % Integration for smoothing (1 ms time window)
z2(1)=0;
for k=1:(length(sound)-1)
z(k+1)=z(k)+(1/params.fs)*(-1/(params.expf)*z(k)+s(k)); % integrate forward
end
for k=1:(length(sound)-1)
z2(k+1)=z2(k)+(1/params.fs)*(-1/(params.expf)*z2(k)+s(end-k)); % integrate back
end
z3=0.5*(z+fliplr(z2)); % average both integrations = smooth with no delay
env=fliplr(sgolayfilt(fliplr(z3),4,params.ft)); % filter it
env_norm=env./max(env);
% Compute 5-point stencil derivative of env_norm
d=zeros(length(sound),1);
for k=3:(length(d)-2)
d(k)=(-env_norm(k+2)+8*env_norm(k+1)-8*env_norm(k-1)+env_norm(k-2));
end
% Compute 2nd-order derivative as a 5-point stencil derivative of d(t)
d2=zeros(length(sound),1);
for k=3:(length(sound)-2)
d2(k)=(-d(k+2)+8*d(k+1)-8*d(k-1)+d(k-2));
end
% Smooth out derivatives: Savitzky-Golay filtering and moving average
d=sgolayfilt(d,4,params.ft);
d=smooth(d,round((params.smd)*params.fs))./max(smooth(d,round((params.smd)*params.fs))); % smoothed derivative
d2=sgolayfilt(d2,4,params.ft);
d2=smooth(d2,round((params.smd)*params.fs))./max(smooth(d2,round((params.smd)*params.fs))); % smoothed 2nd derivative

%Calculate moving threshold
adapt_thr_unsmoothed = movmean(env_norm,params.window_th*params.fs/1000)/params.prop_th;
%smoothing de esto 
adapt_thr = movmean(adapt_thr_unsmoothed,params.window_th*params.fs/1000);

% Finds syllable onsets and offsets
%antes comparaba con un fixed threshold params.o_thresh
[~,onsets]=findpeaks(diff(env_norm>adapt_thr),'MinPeakDistance',round((params.deadtime)*params.fs));
[~,offsets]=findpeaks(-diff(env_norm>adapt_thr),'MinPeakDistance',round((params.deadtime)*params.fs));
%ESTE DEADTIME ASUME QUE lo primero que se detecta esta bien
%podria adecuarse a que se quede con los que esten mas cerca
%de un maximo en la pendiente de la envolvente por ejemplo,
%y no con el primero que aparece (los otros se cancelan con el deadtime)




%test de que tienen la misma cantidad de onsets y offsets
%si no lo tiene, recorre aquel vector (onsets u offsets)
%con menor cantidad y le asigna el corresondiente mas cercano

%lo cambie porque incluia un deadtime, lo que hacia que hubiera repetidos
if not(length(onsets)==length(offsets))
%     display('Warning! Different number of onsets and offsets');
%     keyboard
    if(length(onsets)<length(offsets))

     offsets_aux=nan(1,length(onsets));
     for k=1:length(onsets)
         offsets_aux(k)=offsets(find((offsets-onsets(k))>0,1,'first'));
     end    
     offsets=offsets_aux;

    elseif(length(offsets)<length(onsets))
    
     onsets_aux=nan(1,length(offsets));
     for k=1:length(offsets)
         onsets_aux(k)=onsets(find((onsets-offsets(k))<0,1,'first'));
     end 
         onsets=onsets_aux;
    end
end

% Corrects in case that detection yields different amount of onsets/offsets
%easy case first: offsets before first onset or viceversa
if any(offsets<=onsets(1))
    offsets(offsets<=onsets(1))=[];
end
if any(onsets>=offsets(end))
    onsets(onsets>=offsets(end))=[];
end

if not(length(onsets)==length(offsets))
    display('Warning! Different number of onsets and offsets');
end
%      [~,onsetsb]=findpeaks(diff(env_norm>adapt_thr));   
%      for k=1:length(offsets)
%      onsets_aux(k)=onsetsb(find((offsets(k)-onsetsb)>round((params.deadtime)*params.fs),1,'last'));
%      end
%      onsets=onsets_aux;
%     end

% % % %     roundTargets= onsets';
% % % %     spectMarks= offsets';    %sacando offset que esta bien determinado
% % % %     
% % % %     [~,min_dist_index]=pdist2(onsets,offsets,'euclidean' ,'Smallest',1);
% % % %     
% % % %     spectMarksrounded=roundTargets(min_dist_index);
% % % %     spectMarksrounded=unique([spectMarksrounded]);
   
%test de que no hay repetidos
if or(not(length(unique(onsets))==length(onsets)),not(length(unique(offsets))==length(offsets)))
    display('Warning! Repeated onsets or offsets');
end

%test de que estan intercalados (duraciones mayores a cero)
if any((offsets-onsets)<=0)
    display('Warning! Not intercalated on-off');
end

%todo lo que sigue trabaja con k y k-1, entonces asume que
%los onsets y offsets estan intercalados uno a uno

% Eliminates short intrasyllabic interrupts (params.tolerance)
onsets2go=[];offsets2go=[];
z=1;
for k=2:length(onsets)
tolerance=onsets(k)-offsets(k-1);
if(tolerance<round(params.tolerance*params.fs))
onsets2go(z)=onsets(k);
offsets2go(z)=offsets(k-1);
z=z+1;
end
end
prevonsets=onsets;
prevoffsets=offsets;
onsets(ismember(onsets,onsets2go))=[];
offsets(ismember(offsets,offsets2go))=[];
% Eliminates short segments (params.min_duration)
try
duration=offsets-onsets;
onsets(duration<round((params.min_duration)*params.fs))=[];
offsets(duration<round((params.min_duration)*params.fs))=[];
catch
end
% Now it searches for relevant instances in the envelope 
% MinPeakProminence: set to avoid noise/artifacts. Might vary.
[pk,lc]=findpeaks(abs(diff(d>0))); % all zero-crossings of d(t)
% Minimum prominence and minimum time window (takes out subtle modulations
% in envelope which are not robust instances)
[pk,lc2]=findpeaks(d2./max(d2),'MinPeakProminence',params.d2promthreshm,'MinPeakHeight',params.d2pkthresh,'MinPeakDistance',round(params.min_dist*params.fs)); % for minima
[pk,lc3]=findpeaks(-d2./max(-d2),'MinPeakProminence',params.d2promthreshM,'MinPeakHeight',params.d2pkthresh,'MinPeakDistance',round(params.min_dist*params.fs)); % for maxima
%
lcc=sort([lc2' lc3']','ascend');
%window : 1 ms
lc(lc<10)=[]; % corrects a possible false positive at sound onset
z=1;
candidate=[];
for k=1:length(lcc)
% Checks for peaks in d2(t) to be near-zero in d(t) (and thus, env. minima)
prueba=abs(d((lcc(k)-params.wdw):(lcc(k)+params.wdw)));
if(length(find(prueba<params.eps))>=1)
candidate(z)=lcc(k);
z=z+1;
end
end
candidate=unique(candidate); % removes possible double detections
%
% Keeps only intrasyllabic instances and kills the rest
which=zeros(length(candidate),1);
for k=1:length(onsets)
which(candidate>onsets(k) & candidate<offsets(k))=1;
end
candidate(~find(which))=[];
mins=candidate(d2(candidate)>0); % candidates d2>0, d~0 are minima
maxs=candidate(d2(candidate)<0); % candidates d2<0, d~0 are maxima
%
minima_mot=mins;
maxima_mot=maxs;
%
minima_prom=[];maxima_prom=[];

% Segments on a syllable-by-syllable basis
for k=1:length(onsets)
maxima=maxima_mot(maxima_mot>onsets(k) & maxima_mot<offsets(k));
minima=minima_mot(minima_mot>onsets(k) & minima_mot<offsets(k));
env_norm_seg=env_norm(onsets(k):offsets(k));
%
minima(abs(minima-onsets(k))<round((params.deadt)*params.fs))=[];
minima(abs(minima-offsets(k))<round((params.deadt)*params.fs))=[];
maxima(abs(maxima-onsets(k))<round((params.deadt)*params.fs))=[];
maxima(abs(maxima-offsets(k))<round((params.deadt)*params.fs))=[];
%
extra=find(env_norm_seg==max(env_norm_seg));
% If it is not already consdiered, forces the absolute maximum of 
% each syllable to be considered, regardless of parameters
if(isempty(find(abs(extra+onsets(k)-1-maxima)<(5E-3)*params.fs)))
maxima=[maxima,extra+onsets(k)-1];
end
minima_prom=[minima_prom,minima];
maxima_prom=[maxima_prom,maxima];
%
end
%
% Outputs "gtes"
gtes.gtes1=onsets';
gtes.gtes2=offsets';
gtes.gtes3=sort(unique(minima_prom),'ascend')';
gtes.gtes4=sort(unique(maxima_prom),'ascend')';
end