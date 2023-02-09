function ex = eyeVolt2Deg(ex)

% convert voltages of eye signals to degrees of visual angle (DVA) using 
% the eye calibration and monitor settings
%
% history
%   02/01/20    hn: wrote it

% degrees per pixel for this session
dpp = atan(ex.setup.monitorWidth/2/ex.setup.viewingDistance)*180/pi/...
    (ex.setup.screenRect(3)/2);

if isempty(ex.eyeCal.Delta(1).TrialNo)
    ex.eyeCal.Delta(1).TrialNo = 1;
end

for n= 1:length(ex.Trials)
    
    % update the offset whenever it was changed by re-centering online
    for nd = 1:length(ex.eyeCal.Delta)
        if n>=ex.eyeCal.Delta(nd).TrialNo
            RX0 = ex.eyeCal.Delta(nd).RX0;
            RY0 = ex.eyeCal.Delta(nd).RY0;
            LX0 = ex.eyeCal.Delta(nd).LX0;
            LY0 = ex.eyeCal.Delta(nd).LY0;
        end
    end
    
    % convert voltages to DVA
    ex.Trials(n).Eye.v(1,:) = (ex.Trials(n).Eye.v(1,:)-ex.eyeCal.RX0 - RX0)...
        *ex.eyeCal.RXGain*dpp;
    ex.Trials(n).Eye.v(2,:) = (ex.Trials(n).Eye.v(2,:)-ex.eyeCal.RY0 - RY0)...
        *ex.eyeCal.RYGain*dpp;
    ex.Trials(n).Eye.v(4,:) = (ex.Trials(n).Eye.v(4,:)-ex.eyeCal.LX0 - LX0)...
        *ex.eyeCal.LXGain*dpp;
    ex.Trials(n).Eye.v(5,:) = (ex.Trials(n).Eye.v(5,:)-ex.eyeCal.LY0 - LY0)...
        *ex.eyeCal.LYGain*dpp;
end