function [h]=plotgteall(motifs,params)
figure()
% This function produces a plot for the results found with find_gte
% Inputs: sound, envelope, parameters and gte results
how_many_subplots=length(motifs);
for z=1:length(motifs)
    sound=motifs(z).sound;
    gtes=motifs(z).gtes;
    env_norm=motifs(z).env_norm;
    dt0=gtes.gtes1(1);
    t=(1/params.fs)*((0:1:(length(sound)-1))-dt0);
    [~,F,T,P]=spectrogram(motifs(z).sound,gausswin(ceil((10E-3)*params.fs),2.5),...
        floor(0.975*(10E-3)*params.fs),[],params.fs,...
        'yaxis','psd','MinThrehsold',-100);
    h(2*z-1)=subplot(2*length(motifs),1,2*z-1);
    plot(t,sound./max(abs(sound)));hold on;
    plot(t,env_norm,'LineWidth',1)
    line((1/params.fs)*(gtes.gtes1.*[1 1]-dt0*[1 1])',[-1 1]','LineWidth',0.5,'color','blue') % onsets
    line((1/params.fs)*(gtes.gtes2.*[1 1]-dt0*[1 1])',[-1 1]','LineWidth',0.5,'color','blue') % offsets
    if(~isempty(gtes.gtes3))
    line((1/params.fs)*(gtes.gtes3.*[1 1]-dt0*[1 1])',[-1 1]','LineWidth',0.5,'color','green') % minima
    end
    if(~isempty(gtes.gtes4))
    line((1/params.fs)*(gtes.gtes4.*[1 1]-dt0*[1 1])',[-1 1]','LineWidth',0.5,'color','red') % maxima
    end
    h(2*z)=subplot(2*length(motifs),1,2*z);
    imagesc(T-dt0/params.fs,F/1000,10*log10(P));set(gca,'YDir','normal');
    ylim([0 10]) % sets spectrogram limit to 10 kHz
    colormap(1-gray)
    line((1/params.fs)*(gtes.gtes1.*[1 1]-dt0*[1 1])',[0 10]','LineWidth',0.5,'color','blue') % onsets
    line((1/params.fs)*(gtes.gtes2.*[1 1]-dt0*[1 1])',[0 10]','LineWidth',0.5,'color','blue') % offsets
    if(~isempty(gtes.gtes3))
    line((1/params.fs)*(gtes.gtes3.*[1 1]-dt0*[1 1])',[0 10]','LineWidth',0.5,'color','green') % minima
    end
    if(~isempty(gtes.gtes4))
    line((1/params.fs)*(gtes.gtes4.*[1 1]-dt0*[1 1])',[0 10]','LineWidth',0.5,'color','red') % maxima
    end
    linkaxes(h,'x')
end
  xlabel('Time (s)')
  ylabel('Freq. (kHz)','FontSize',7)
  ylabel(h(end-1),{'Sound', '(arb. units)'},'FontSize',7)
 set(h(1:(2*z-1)),'XTick',[])
end