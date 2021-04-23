function [motif_list]=parse_motifs(birdname)
% reads a plain-text (.txt) file with timestamps for motifs.
% Filename should be the same as .wav file and have no data apart from
% timestamps for motif beggining and end
% each line in the .txt should have a pair of values (t_begin, t_end)
% separated by a \t (tab) delimiter)
% files should be in a "./song" folder from where this is running
motif_list=table2array(readtable(['./songs/' birdname '.txt']));
end