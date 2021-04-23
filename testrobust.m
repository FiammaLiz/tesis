function [motifs] = testrobust(motifs,motif_list,params)
%% tests for gte robustness
gtes1=[];gtes2=[];gtes3=[];gtes4=[];gtes3_selec=[];syll_onset=[];syll_offset=[];
% First, eliminate false positive onsets
for k=1:size(motif_list,1) %
gtes1{k}=motifs(k).gtes.gtes1; % takes all onsets
gtes2{k}=motifs(k).gtes.gtes2; % takes all offsets
end
gtes1d=gtes1; % new variable for logical indexing
for k=1:length(gtes1) % length will always work: gtes 1 is 1xN cell (N motifs)
    for l=1:length(gtes1{:,k}) % how many gtes1 vector for motif k
       a=vertcat(gtes1{:})-gtes1{:,k}(l); % compares current onset to all
       if(length(find(abs(a)<round((40E-3)*params.fs)))>1) % onsets among motifs
        gtes1d{:,k}(l)=1;
        else
        gtes1d{:,k}(l)=0;
    end
    end
    gtes1n{:,k}=gtes1{:,k}(logical(gtes1d{:,k})); % clears non-robust onsets
end
% offsets
gtes2d=gtes2; % same scheme as for onsets
for k=1:length(gtes2)
    for l=1:length(gtes2{:,k})
       a=vertcat(gtes2{:})-gtes2{:,k}(l);
       if(length(find(abs(a)<round((40E-3)*params.fs)))>1)
        gtes2d{:,k}(l)=1;
        else
        gtes2d{:,k}(l)=0;
    end
    end
    gtes2n{:,k}=gtes2{:,k}(logical(gtes2d{:,k}));
end
%
for k=1:size(motif_list)
motifs(k).gtes.gtes1=gtes1n{k};
motifs(k).gtes.gtes2=gtes2n{k};
end
%
% test for robustness in repetitions
mot_table=motcorr(motifs); % needs further testing. Works OK for most cases
%
for k=1:size(mot_table,2) % motif formed by distinct syllables
 [row,col]=find(mot_table==k); % to identify struct indexes
 for i=1:length(row)
  aux=motifs(row(i)).gtes;
  syll_onset(row(i),k)=aux.gtes1(col(i)); % syllable onset
  syll_offset(row(i),k)=aux.gtes2(col(i)); % syllable offset
  gtes3{row(i),k}=aux.gtes3(aux.gtes3>syll_onset(row(i),k) & aux.gtes3<syll_offset(row(i),k))-syll_onset(row(i),k);
  gtes4{row(i),k}=aux.gtes4(aux.gtes4>syll_onset(row(i),k) & aux.gtes4<syll_offset(row(i),k))-syll_onset(row(i),k);
  % gtes3 & gtes4: relevant minima and maxima, respectively
  % syll onset is substracted to compare gte timing on different song
  % renditions
 end
end
% The end result is a cell matrix with gtes3 and gtes4 for each syllable in
% each motif
% Checks minima robustness
gtes3d=gtes3;
b=cellfun(@length,gtes3);
for i=1:size(gtes3,2) % for each syllable in each motif
 for j=1:size(gtes3,1) % for all motifs
  for l=1:length(gtes3{j,i}) % for all gtes
    a=vertcat(gtes3{:,i})-gtes3{j,i}(l);
    if(length(find(abs(a)<(params.coincidence)*params.fs))>(size(b,1)-length(find(b(:,i)==0)))/2)
        gtes3d{j,i}(l)=1;
    else
        gtes3d{j,i}(l)=0;
    end
  end
  gtes3n{j,i}=gtes3{j,i}(logical(gtes3d{j,i}))+syll_onset(j,i);
 end
end
% Checks maxima robustness
gtes4d=gtes4;
b=cellfun(@length,gtes4);
for i=1:size(gtes4,2)
 for j=1:size(gtes4,1)
  for l=1:length(gtes4{j,i})
    a=vertcat(gtes4{:,i})-gtes4{j,i}(l);
    % since maxima are fewer, allow for a larger coincidence window
    if(length(find(abs(a)<(2*params.coincidence)*params.fs))>(size(b,1)-length(find(b(:,i)==0)))/2)
        gtes4d{j,i}(l)=1;
    else
        gtes4d{j,i}(l)=0;
    end
  end
  gtes4n{j,i}=gtes4{j,i}(logical(gtes4d{j,i}))+syll_onset(j,i);
 end
end
%
for k=1:length(motifs) % and now replaces gtes with the robust ones
motifs(k).gtes.gtes3=vertcat(gtes3n{k,:});
motifs(k).gtes.gtes4=vertcat(gtes4n{k,:});
end
end