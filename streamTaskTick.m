function rlsiTaskTick

global rlsiDat

switch rlsiDat.status
    case 'PrepareStim'
        
        tt = rlsiDat.tNum;
        
        trialDur = 3;
        % make the audio stimuli
        
        tReps = rlsiDat.trials(tt,7);
        mReps = rlsiDat.trials(tt,8);
        gap = 0.15;
        f0t = rlsiDat.trials(tt,3);
        f0m = rlsiDat.trials(tt,4);
        if isinf(trialDur/tReps)
            tDur = 0.3;
            mDur = 0.3;
        else
            tDur = (trialDur/tReps)-0.15;
            mDur = (trialDur/mReps)-0.15;
        end
        fs=rlsiDat.fs;
        vowel = rlsiDat.trials(tt,6); %1 = u; 2 = e
        SNR = rlsiDat.trials(tt,5);
        %% generate stimuli
        y=clicktrain(tDur,f0t,fs);
        d = fdesign.lowpass('Fp,Fst,Ap,Ast',12000/fs, 14000/fs, 1, 60);
        f = design(d, 'butter');
        yy=filter(f,y);
        yy=envelope(yy,0.01,fs);
        yy=yy./sqrt(mean(yy.^2)); % normalise to unit RMS
        
        
        sgap = zeros(1,gap*fs);
        if vowel == 0
            u = newMakeVowel2009(tDur,fs,f0t,550,1205,3000,4000);
            % u = newMakeVowel2009(tDur,fs,f0t,460,1105,3000,4000);
        else
            u = newMakeVowel2009(tDur,fs,f0t,630,1505,3000,4000);
            %u = newMakeVowel2009(tDur,fs,f0t,730,2058,3000,4000);
        end
        precursor =[];
        for ii=1:tReps
            precursor = [precursor,yy sgap];
        end
        target = [precursor, u];
        
        %soundsc(target,fs)
        
        y=clicktrain(mDur,f0m,fs);
        d = fdesign.lowpass('Fp,Fst,Ap,Ast',12000/fs, 14000/fs, 1, 60);
        f = design(d, 'butter');
        yy=filter(f,y);
        %jennyFFT(yy,fs,1);
        yy=envelope(yy,0.05,fs);
        yy=yy./sqrt(mean(yy.^2)); % normalise to unit RMS
        
        masker = [];
        for ii=1:mReps
            masker = [masker,yy sgap];
        end
        
        masker = [masker,yy];
        if length(masker)>length(target)
            masker = masker(1:length(target));
        elseif length(masker)<length(target)
            target = target(1:length(masker));
        end
        
        target = target.*10^((SNR/20));
        
        fullSound = zeros(24,length(target));
        if rlsiDat.trials(tt,1)==rlsiDat.trials(tt,2)
            fullSound(rlsiDat.trials(tt,1),:) = target + masker;
        else
            fullSound(rlsiDat.trials(tt,1),:) = target;
            fullSound(rlsiDat.trials(tt,2),:) = masker;
        end
 rlsiDat.wavdata = fullSound.*10^((-50/20));
        
        PsychPortAudio('FillBuffer', rlsiDat.pahandle, rlsiDat.wavdata);
        
        
        rlsiDat.status = 'Ready';
        disp('ready')
    case 'Ready'
        repetitions=1;
        
        %set(rlsiDat.h,'userdata','on');
        
        %         %play the sound
        PsychPortAudio('Start', rlsiDat.pahandle, repetitions, 0, 1);
        rlsiDat.startTime=GetSecs;
       %   set(rlsiDat.h.allboxes,'hittest','on');
        
        % soundsc(rlsiDat.wavdata(1:2,:),rlsiDat.fs);
        rlsiDat.status = 'WaitForResponse'
       
    case 'WaitForResponse'
        % wait for the responses
        % enable key press
        
        if length(rlsiDat.response2)>=1
         %   set(rlsiDat.h.allboxes,'hittest','off'); % inactivte the buttons
            rlsiDat.status = 'SaveTrial';
        end
        
    case 'SaveTrial' %save data and increment trials
       
        rlsiDat.response2
        
        rlsiDat.data = [rlsiDat.data; ...
            rlsiDat.tNum,rlsiDat.trials(rlsiDat.tNum,:),rlsiDat.response2];
        
        save(rlsiDat.fileName,'rlsiDat');
        rlsiDat.tNum = rlsiDat.tNum + 1; % advance trial
        rlsiDat.status = 'nextTrial';
        
    case 'nextTrial';
         
        % clear data fields for next trial
        rlsiDat.response2 = [];
       
        rlsiDat.respTime2 = [];
        
        if rlsiDat.tNum > length(rlsiDat.trials)
            
                rlsiDat.status = 'Finished';
                   else
            rlsiDat.status = 'PrepareStim';
        end
        
    case 'Finished' % all done - close and tidy up
        PsychPortAudio('Close' ,rlsiDat.pahandle);
        stop(rlsiDat.tasktimer);
        delete(rlsiDat.tasktimer);
       % rlsiDat=rmfield(rlsiDat,{'wavdata','noise','jpeg','aud'});
        save(rlsiDat.fileName,'rlsiDat');
        clear
        clear all
        clear memory
        close all hidden;
end