function [ms,ex] = msLFP(ex);
%%
% function [tA,stim] = stimTrigLFP(ex)
%
% input:    ex (lfp datafile)
% output:   ms n-by-2 cell-array microsaccades on each trial, separately
%           for the left and right eye
%    microsaccades - Column one: Time of onset of microsaccades
%                    Column two: Time at which the microsaccdes terminate
%                    Column three: Peak velocity of microsaccades
%                    Column four: Peak amplitude of microsaccades
%           ex, including field Trials.microsaccade 
%
% history
% 01/27/23  hn: wrote it


tWin        = [50 200]; % looking 50ms before and 150ms after stim-change
fS          = 1000; % LFP sampling frequency
removeOn    = 30; % remove this number of stimulus samples at trial onset
removeOff   = 50; % remove this number of stimulus samples at trial offset

% only completed trials
a          = find([ex.Trials.Reward]==1);
ex.Trials  = ex.Trials(a);

% eye 2 deg
ex = eyeVolt2Deg(ex);

N = length(ex.Trials); % number of trials

% initialize
ms = cell(N,3);

for n = 1:N
    
    % align clocks
    t = ex.Trials(n).Eye.t(1:ex.Trials(n).Eye.n)-ex.Trials(n).TrialStartDatapixx;
    st = ex.Trials(n).Start - ex.Trials(n).TrialStart_remappedGetSecs;            

    % get the timing of start and end of stimulus
    [~,stpos] = min(abs(t-st(1)));
    [~,enpos] = min(abs(t-st(end))); 
    
    % eye positions during stimulus presentation 
    eyeDegR = [ex.Trials(n).Eye.v(1:2,stpos:enpos)'];
    eyeDegL = [ex.Trials(n).Eye.v(4:5,stpos:enpos)'];
    
    % get microsaccades for left and right eye independently
    msR     = micsaccdeg(eyeDegR);
    msL     = micsaccdeg(eyeDegL);
    ms{n,1} = msR;
    ms{n,2} = msL;
    
    % binocular microsaccades: require some temporal overlap
    msB = [];
    for k = 1: size(msR,1)
        mDur                        = zeros(1,enpos-stpos);
        mDur(msR(k,1):msR(k,2))     = deal(1);
        % loop through left eye saccades to check for overlap
        for k2 = 1:size(msL,1)
            mDur(msL(k2,1):msL(k2,2)) = mDur(msL(k2,1):msL(k2,2))+1;
        end
        % only include microsaccades that have temporal overlap
        if sum(mDur==2)>0
            msB = [msB;msR(k,:)];
        end
    end
    ms{n,3} = msB;
    
    ex.Trials(n).microsaccL = msL;
    ex.Trials(n).microsaccR = msR;
    ex.Trials(n).microsacc  = msB;
    
end
    
    
    


