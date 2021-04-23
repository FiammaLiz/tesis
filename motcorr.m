function [mot_table]=motcorr(motifs)
% This function computes a table of syllable correspondence across motifs
% by computing cross-correlations of sound segments. 
% Might need some work, specially if the first fed motif begins with a
% different syllable than the rest. 
% For longer motifs that add syllables at the end, it seems to be working
% fine. 
for k=1:length(motifs)
 syllcount(k)=length(motifs(k).gtes.gtes1);
end
for k=1:(length(motifs))
   for i=1:syllcount(k)
     syll{i}=motifs(k).sound(motifs(k).gtes.gtes1(i):motifs(k).gtes.gtes2(i));
    % 
    for kk=(k):(length(motifs))
     corre=[];dife=[];
      for j=1:syllcount(kk)
      if(i<=j)
      syll{j}=motifs(kk).sound(motifs(kk).gtes.gtes1(j):motifs(kk).gtes.gtes2(j));
      aux=xcov(syll{i},syll{j},1);
      corre(i,j)=max(aux);
      dife(i,j)=diff([length(syll{i}),length(syll{j})]);
      end
      end
      %
     try 
     mottable(kk,i)=find(max(corre(i,:))==corre(i,:) & min(abs(dife(i,:)))==dife(i,:));
     catch
     mottable(kk,i)=0;    
     end
    end
   end
end
mot_table=mottable;
mot_table(:,sum(mot_table)==0)=[];
end