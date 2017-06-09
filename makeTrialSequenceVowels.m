
function trials = makeTrialSequenceVowels;

%%
%Tspeaker, Dspeaker, F0t, F0d, dVowel, tVowel, ntSeqelements, nvSeqelements

trials = [10, 10, 150, 170, 3, 1,5,7; %pitch no space
    10 5 150 170, 3, 1, 5, 7;% pitch and space
    10, 10, 150, 150, 3, 1, 5, 7;%no space no pitch
    10 5 150 150, 3, 1, 5, 7;% no pitch space
    %temporally coherent
    10, 10, 150, 170, 3, 1,6,6;
    10 5 150 170, 3, 1, 6, 6;
    10, 10, 150, 150, 3, 1, 6, 6;
    10 5 150 150, 3, 1, 6, 6;
    %no precursor
    10, 10, 150, 170, 3, 1,0, 0;
    10 5 150 170, 3, 1, 0, 0;
    10, 10, 150, 150, 3, 1, 0, 0;
    10 5 150 150, 3, 1, 0, 0;
    
    10, 10, 150, 170, 3, 0,5,7; %pitch no space
    10 5 150 170, 3, 0, 5, 7;% pitch and space
    10, 10, 150, 150, 3, 0, 5, 7;%no space no pitch
    10 5 150 150, 3, 0, 5, 7;% no pitch space
    
    %temporally coherent
    10, 10, 150, 170, 3, 0,6,6;
    10 5 150 170, 3, 0, 6, 6;
    10, 10, 150, 150, 3, 0, 6, 6;
    10 5 150 150, 3, 0, 6, 6;
    
    
    %no precursor
    10, 10, 150, 170, 3, 0,0,0;
    10 5 150 170, 3, 0, 0, 0;
    10, 10, 150, 150, 3, 0, 0, 0;
    10 5 150 150, 3, 0, 0, 0];

trials = repmat(trials, 6, 1);
trials = trials(randperm(length(trials)),:);
