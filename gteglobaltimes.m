function [gte] = gteglobaltimes(motifs,motif_list,params)
gtes1=[];gtes2=[];gtes3=[];gtes4=[];
for k=1:length(motifs)
gtes1=vertcat(gtes1,(1/params.fs)*motifs(k).gtes.gtes1+motif_list(k,1));
gtes2=vertcat(gtes2,(1/params.fs)*motifs(k).gtes.gtes2+motif_list(k,1));
gtes3=vertcat(gtes3,(1/params.fs)*motifs(k).gtes.gtes3+motif_list(k,1));
gtes4=vertcat(gtes4,(1/params.fs)*motifs(k).gtes.gtes4+motif_list(k,1));
end
gte.gtes1=gtes1;
gte.gtes2=gtes2;
gte.gtes3=gtes3;
gte.gtes4=gtes4;
end