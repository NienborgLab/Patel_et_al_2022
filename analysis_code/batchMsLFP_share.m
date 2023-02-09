% path =======================================
path = mfilename( 'fullpath' );

if ispc    % Windows file system
    parts = strsplit(path, '\');
else
    parts = strsplit(path, '/');
end

rootpath = strjoin(parts(1:end-2), '/');

addpath(genpath([rootpath '/helper_code/']))
addpath(genpath([rootpath '/external_libraries/']))

loadpath = [rootpath, '/resources/Data/microsaccades/']; % Same as savepath
datapath = [rootpath, '/resources/Data/LFPprepro/'];


fnm1 = '/lists/used_files.txt';
fnm2 = '/lists/used_files_drugs.txt';

list1 = textread([loadpath, fnm1],'%s');
list2 = textread([loadpath, fnm2],'%s');

res = struct();
for n = 1:length(list1)
    
    % control condition ============================================
    
    ifl = list1{n};
    if ~exist([datapath, ifl],'file')
         ifl=strrep(ifl,'sortHN','sortLH');
    end

    load([datapath, ifl]);
    sFn = ifl(1:7);
    
    % get microsaccades for left, right eye separately, and both eyes
    [ms]             = msLFP(ex);
    
    N               = size(ms,1);
    msB             = cell2mat(ms(:,3));
    msR             = cell2mat(ms(:,1)); % right eye ms
    msL             = cell2mat(ms(:,2)); % left eye ms
    
    avMsFrequency   = size(msB,1)/N/2; % 2 sec durations/trial
    avMsAmplitude   = mean(msB(:,4));

    avMsFrequencyR   = size(msR,1)/N/2; % 2 sec durations/trial
    avMsAmplitudeR   = mean(msR(:,4));

    avMsFrequencyL   = size(msL,1)/N/2; % 2 sec durations/trial
    avMsAmplitudeL   = mean(msL(:,4));
 
    % summary results
    animal = true;
    if contains(sFn,'ma') % Ka = 1, ma = 0
        animal = false;
    end
    res(n).msFreq_control = avMsFrequency;
    res(n).msAmp_control  = avMsAmplitude;
    res(n).msFreq_controlR = avMsFrequencyR;
    res(n).msAmp_controlR  = avMsAmplitudeR;
    res(n).msFreq_controlL = avMsFrequencyL;
    res(n).msAmp_controlL  = avMsAmplitudeL;
    res(n).animal          = animal;
    res(n).session        = sFn;    
    
    
    % drug condition ================================================
    % ifl = strrep(strrep(list2{n},'_c1_','_lfp_'),'_c2_','_lfp_');
    
    ifl = list2{n};
    if ~exist([datapath, ifl],'file')
        ifl=strrep(ifl,'sortHN','sortLH');
    end

    load([datapath, ifl]);
    
    sFn_drug = ifl(1:7);
    
    % get microsaccades for left, right eye separately, and both eyes
    [ms]             = msLFP(ex);
    
    N               = size(ms,1);
    msB             = cell2mat(ms(:,3)); % binocular ms
    msR             = cell2mat(ms(:,1)); % right eye ms
    msL             = cell2mat(ms(:,2)); % left eye ms

    
    avMsFrequency   = size(msB,1)/N/2; % 2 sec durations/trial
    avMsAmplitude   = mean(msB(:,4));
    
    avMsFrequencyR   = size(msR,1)/N/2; % 2 sec durations/trial
    avMsAmplitudeR   = mean(msR(:,4));

    avMsFrequencyL   = size(msL,1)/N/2; % 2 sec durations/trial
    avMsAmplitudeL   = mean(msL(:,4));

    drugCnd = false;
    if contains(ifl,'5HT')
        drug = '5HT';
        drugCnd = true;
    else
        drug = 'NaCl';
    end
    
    % summary results
    res(n).msFreq_drug    = avMsFrequency;
    res(n).msAmp_drug     = avMsAmplitude;
    res(n).msFreq_drugR    = avMsFrequencyR;
    res(n).msAmp_drugR     = avMsAmplitudeR;
    res(n).msFreq_drugL    = avMsFrequencyL;
    res(n).msAmp_drugL     = avMsAmplitudeL;

    res(n).session_drug   = sFn_drug;    % just double checking
    res(n).serotonin      = drugCnd;
    
    % document whether session was unique 
    res(n).uniqueSession = true;
    out = arrayfun(@(x) contains(x.session,sFn),res(1:n-1));
    if sum(out) >0 
        idx = find(out==1);
        if sum([res(idx).serotonin] == drugCnd)>0
            res(n).uniqueSession = false;
        end
    end
        
end

%save summary results
save([loadpath, 'summary_microsaccades'], 'res')