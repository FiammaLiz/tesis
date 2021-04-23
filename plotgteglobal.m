function [h]=plotgteglobal(song,gte,params)
sound=song;
%env_norm=motif.env_norm;
gtes=gte;
figure();
% This function produces a plot for the results found with find_gte
% Inputs: whole sound, parameters and gte results
t=(1/params.fs)*(0:1:(length(sound)-1));
[~,F,T,P]=spectrogram(sound,gausswin(ceil((10E-3)*params.fs),3.5),...
    floor(0.975*(10E-3)*params.fs),[],params.fs,...
    'yaxis','psd','MinThrehsold',-100);
h(1)=subplot(2,1,1);
plot(t,sound./max(abs(sound)));hold on;
line((gtes.gtes1.*[1 1])',[-1 1]','LineWidth',1,'color','blue') % onsets
line((gtes.gtes2.*[1 1])',[-1 1]','LineWidth',1,'color','blue') % offsets
if(~isempty(gtes.gtes3))
line((gtes.gtes3.*[1 1])',[-1 1]','LineWidth',1,'color','green') % minima
end
if(~isempty(gtes.gtes4))
line((gtes.gtes4.*[1 1])',[-1 1]','LineWidth',1,'color','red') % maxima
end
ylabel('Sound (arb. units)');
%
h(2)=subplot(2,1,2);
imagesc(T,F/1000,10*log10(P));set(gca,'YDir','normal');
ylim([0 10]) % sets spectrogram limit to 10 kHz
xlabel('Time (s)')
ylabel('Freq. (kHz)')
colormap(1-gray)
line((gtes.gtes1.*[1 1])',[0 10]','LineWidth',1,'color','blue') % onsets
line((gtes.gtes2.*[1 1])',[0 10]','LineWidth',1,'color','blue') % offsets
if(~isempty(gtes.gtes3))
line((gtes.gtes3.*[1 1])',[0 10]','LineWidth',1,'color','green') % minima
end
if(~isempty(gtes.gtes4))
line((gtes.gtes4.*[1 1])',[0 10]','LineWidth',1,'color','red') % maxima
end
linkaxes(h,'x')
xlim([0 t(end)])
end