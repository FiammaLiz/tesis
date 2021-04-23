function [h]=plotgte(motif,params)
sound=motif.sound;
env_norm=motif.env_norm;
gtes=motif.gtes;
d=motif.d;
d2=motif.d2;
figure();
% This function produces a plot for the results found with find_gte
% Inputs: sound, envelope, parameters and gte results
t=(1/params.fs)*(0:1:(length(sound)-1));
[~,F,T,P]=spectrogram(sound,gausswin(ceil((10E-3)*params.fs),2),...
    floor(0.975*(10E-3)*params.fs),[],params.fs,...
    'yaxis','psd','MinThrehsold',-100);

%Calculate moving threshold
adapt_thr_unsmoothed = movmean(env_norm,params.window_th*params.fs/1000)/params.prop_th;
%smoothing de esto 
adapt_thr = movmean(adapt_thr_unsmoothed,params.window_th*params.fs/1000);

h(1)=subplot(3,1,1);
plot(t,sound./max(abs(sound)));hold on;
plot(t,env_norm,'LineWidth',1.5);
plot(t,adapt_thr,'m')
line((1/params.fs)*(gtes.gtes1.*[1 1])',[-1 1]','LineWidth',1,'color','blue') % onsets
line((1/params.fs)*(gtes.gtes2.*[1 1])',[-1 1]','LineWidth',1,'color','blue') % offsets
if(~isempty(gtes.gtes3))
line((1/params.fs)*(gtes.gtes3.*[1 1])',[-1 1]','LineWidth',1,'color','green') % minima
end
if(~isempty(gtes.gtes4))
line((1/params.fs)*(gtes.gtes4.*[1 1])',[-1 1]','LineWidth',1,'color','red') % maxima
end
ylabel('Sound (arb. units)');
%
h(2)=subplot(3,1,2);
plot(t,d./max(abs(d)),'color','black','LineWidth',1);hold on;
plot(t,d2./max(abs(d2)),'color','red','LineWidth',1.5);
line([0 t(end)],[0 0],'color','magenta')
%
line((1/params.fs)*(gtes.gtes1.*[1 1])',[-1 1]','LineWidth',1,'color','blue') % onsets
line((1/params.fs)*(gtes.gtes2.*[1 1])',[-1 1]','LineWidth',1,'color','blue') % offsets
if(~isempty(gtes.gtes3))
line((1/params.fs)*(gtes.gtes3.*[1 1])',[-1 1]','LineWidth',1,'color','green') % minima
line((1/params.fs)*(gtes.gtes3.*[1 1]-params.wdw*[1 1])',[-1 1]','LineWidth',1,'color','green','LineStyle',':') % minima
line((1/params.fs)*(gtes.gtes3.*[1 1]+params.wdw*[1 1])',[-1 1]','LineWidth',1,'color','green','LineStyle',':') % minima
end
if(~isempty(gtes.gtes4))
line((1/params.fs)*(gtes.gtes4.*[1 1])',[-1 1]','LineWidth',1,'color','red') % maxima
line((1/params.fs)*(gtes.gtes4.*[1 1]-params.wdw*[1 1])',[-1 1]','LineWidth',1,'color','red','LineStyle',':') % minima
line((1/params.fs)*(gtes.gtes4.*[1 1]+params.wdw*[1 1])',[-1 1]','LineWidth',1,'color','red','LineStyle',':') % minima
end
ylabel('2nd deriv. (arb. units)');
line([0 1/params.fs*(length(sound)-1)]',[params.eps params.eps]','color','red','LineStyle','--');
line([0 1/params.fs*(length(sound)-1)]',-[params.eps params.eps]','color','red','LineStyle','--');
h(3)=subplot(3,1,3);
imagesc(T,F/1000,10*log10(P));set(gca,'YDir','normal');
ylim([0 10]) % sets spectrogram limit to 10 kHz
xlabel('Time (s)')
ylabel('Freq. (kHz)')
colormap(1-gray)
line((1/params.fs)*(gtes.gtes1.*[1 1])',[0 10]','LineWidth',1,'color','blue') % onsets
line((1/params.fs)*(gtes.gtes2.*[1 1])',[0 10]','LineWidth',1,'color','blue') % offsets
if(~isempty(gtes.gtes3))
line((1/params.fs)*(gtes.gtes3.*[1 1])',[0 10]','LineWidth',1,'color','green') % minima
end
if(~isempty(gtes.gtes4))
line((1/params.fs)*(gtes.gtes4.*[1 1])',[0 10]','LineWidth',1,'color','red') % maxima
end
linkaxes(h,'x')
xlim([0 t(end)])
end