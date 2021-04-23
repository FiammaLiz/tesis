function [params] = def_params(params)
%% Default values
params.fs=params.fs;
params.ft=2*floor(0.5*(641/44100*params.fs))+1; % windowlen for any fs
params.expf=0.5E-3; % for exponential filtering
params.smd=2E-3;  % for moving average smoothing of derivatives
params.o_thresh=0.025; % threshold for onset and offset detection
params.deadtime=(10E-3); % deadtime for on & off detection
params.min_duration=15E-3; % minimum duration of syllable to be considered
params.tolerance=5E-3; % tolerance for intrasyllabic breaking (less than param discarded)
params.d2promthreshm=0.05; % min prominence for finding minima in normalized d2
params.d2promthreshM=2; % min prominence for finding maxima in normalized d2
params.d2pkthresh=0.045; % also requires a minimum absolute value in amplitude
params.min_dist=5E-3; % minimum distance for instances to be considered
params.deadt=2.5E-3; % keep instance farther than params.deadt from onset and offsets
                     % (avoids confusing relevant minima and maxima with
                     % fluctuations of the derivative due to sound
                     % onset/offset)
params.eps=0.05; % epsilon for first deriv. to be considered "near zero"
params.wdw=round((1.5E-3)*params.fs); % window for eps to be considered
params.coincidence=5E-3; % time window to check for GTE coincidence between motifs
%% ZF
if(strcmp(params.birdname(1:2),'zf') || strcmp(params.birdname(1:2),'ZF'))
params.fs=params.fs;
params.ft=2*floor(0.5*(641/44100*params.fs))+1; % windowlen for any fs
params.expf=0.5E-3; % for exponential filtering
params.smd=2E-3;  % for moving average smoothing of derivatives
params.o_thresh=0.025; % threshold for onset and offset detection
params.deadtime=(10E-3); % deadtime for on & off detection
params.min_duration=15E-3; % minimum duration of syllable to be considered
params.tolerance=5E-3; % tolerance for intrasyllabic breaking (less than param discarded)
params.d2promthreshm=0.05; % min prominence for finding minima in normalized d2
params.d2promthreshM=2; % min prominence for finding maxima in normalized d2
params.d2pkthresh=0.045; % also requires a minimum absolute value in amplitude
params.min_dist=0;   % minimum distance for instances to be considered
params.deadt=2.5E-3; % keep instance farther than params.deadt from onset and offsets
                     % (avoids confusing relevant minima and maxima with
                     % fluctuations of the derivative due to sound
                     % onset/offset)
params.eps=0.05; % epsilon for first deriv. to be considered "near zero"
params.wdw=round((1.5E-3)*params.fs); % window for eps to be considered
params.coincidence=5E-3; % time window to check for GTE coincidence between motifs
end
%% BF
if(strcmp(params.birdname(1:2),'BF'))
params.fs=params.fs;
params.ft=2*floor(0.5*(641/44100*params.fs))+1; % S-G windowlen for any fs
params.expf=10E-3; % for exponential filtering
params.smd=1E-3;  % for moving average smoothing of derivatives
params.o_thresh=0.12; % threshold for onset and offset detection. 
                       % If unsuccessful segmentation occurs, change this.
                       % parameter estimated range: 0.01-0.035
params.deadtime=(10E-3); % deadtime for on & off detection
params.min_duration=15E-3; % minimum duration of syllable to be considered
params.tolerance=5E-3; % tolerance for intrasyllabic breaking (less than param discarded)
params.d2promthreshm=0.05; % min prominence for finding minima in normalized d2
params.d2promthreshM=2; % min prominence for finding maxima in normalized d2
params.d2pkthresh=0.045; % also requires a minimum absolute value in amplitude
params.min_dist=5E-3; % minimum distance for instances to be considered
params.deadt=3E-3; % keep instance farther than params.deadt from onset and offsets
                     % (avoids confusing relevant minima and maxima with
                     % fluctuations of the derivative due to sound
                     % onset/offset)
params.eps=0.05; % epsilon for first deriv. to be considered "near zero"
params.wdw=round((2E-3)*params.fs); % window for eps to be considered
params.coincidence=5E-3; % time window to check for GTE coincidence between motifs
end
%% C
if(strcmp(params.birdname(1:2),'C'))
params.fs=params.fs;
params.ft=2*floor(0.5*(641/44100*params.fs))+1; % S-G windowlen for any fs
params.expf=1E-3; % for exponential filtering
params.smd=1E-3;  % for moving average smoothing of derivatives
params.o_thresh=0.015; % threshold for onset and offset detection. 
                       % If unsuccessful segmentation occurs, change this.
                       % parameter estimated range: 0.01-0.035
params.deadtime=(3E-3); % deadtime for on & off detection
params.min_duration=13E-3; % minimum duration of syllable to be considered
params.tolerance=5E-3; % tolerance for intrasyllabic breaking (less than param discarded)
params.d2promthreshm=0.05; % min prominence for finding minima in normalized d2
params.d2promthreshM=2; % min prominence for finding maxima in normalized d2
params.d2pkthresh=0.045; % also requires a minimum absolute value in amplitude
params.min_dist=5E-3; % minimum distance for instances to be considered
params.deadt=3E-3; % keep instance farther than params.deadt from onset and offsets
                     % (avoids confusing relevant minima and maxima with
                     % fluctuations of the derivative due to sound
                     % onset/offset)
params.eps=0.05; % epsilon for first deriv. to be considered "near zero"
params.wdw=round((2E-3)*params.fs); % window for eps to be considered
params.coincidence=5E-3; % time window to check for GTE coincidence between motifs
end
%% LF
if(strcmp(params.birdname(1:2),'LF'))
params.fs=params.fs;
params.ft=2*floor(0.5*(641/44100*params.fs))+1; % S-G windowlen for any fs
params.expf=2E-3; % for exponential filtering
params.smd=1E-3;  % for moving average smoothing of derivatives
params.o_thresh=0.03; % threshold for onset and offset detection. 
                       % If unsuccessful segmentation occurs, change this.
                       % parameter estimated range: 0.01-0.035
params.deadtime=(10E-3); % deadtime for on & off detection
params.min_duration=15E-3; % minimum duration of syllable to be considered
params.tolerance=5E-3; % tolerance for intrasyllabic breaking (less than param discarded)
params.d2promthreshm=0.1; % min prominence for finding minima in normalized d2
params.d2promthreshM=2; % min prominence for finding maxima in normalized d2
params.d2pkthresh=0.12; % also requires a minimum absolute value in amplitude
params.min_dist=10E-3; % minimum distance for instances to be considered
params.deadt=3E-3; % keep instance farther than params.deadt from onset and offsets
                     % (avoids confusing relevant minima and maxima with
                     % fluctuations of the derivative due to sound
                     % onset/offset)
params.eps=0.08; % epsilon for first deriv. to be considered "near zero"
params.wdw=round((2E-3)*params.fs); % window for eps to be considered
params.coincidence=5E-3; % time window to check for GTE coincidence between motifs
end
end