% Function for detecting microsaccades from a time series of eye movements.
%
% Inputs:
%    EyeDeg   - Time series of vert/hor eye positions(n-by-2 array) in dva
%    fS       - The sampling rate of the time series of eye movements.
%               default = 500
%    thresh   - velocity threshold
%    minSmp   - minimum number of samples to exceed velocity threshold:
%               default: 3 (as in Engbert & Kliegl, 2003)
%    maxSmp   - maximum number of samples (default: 150, i.e. 300ms at 500Hz)
%    minGap   - minimum gap between microsaccades (default: 3, i.e. 6ms)
%
% Outputs:
%    microsaccades - Column one: Time of onset of microsaccades
%                    Column two: Time at which the microsaccdes terminate
%                    Column three: Peak velocity of microsaccades
%                    Column four: Peak amplitude of microsaccades
%                    
% Haider Riaz - haider.riaz@mail.mcgill.ca
% McIntyre Medical Building Room 1225
% Department of Physiology, McGill University
%
% Created by Haider Riaz Khan 2013, after algorithm by Engbert & Kliegl
% (2003)
% modified by HN
%
% history



function microsaccades = micsaccdeg(EyeDeg,fS, thresh,minSmp,maxSmp,minGap)
if nargin <2
    fS  = 500;
end
if nargin <3
    thresh = 12;  % default velocity threshold
end
if nargin <4
    %minSmp = 4;% minimal number of samples to exceed velocity threshold 
    minSmp = 3;% minimal number of samples to exceed velocity threshold (as in Engbert &Kliegl)
end
if nargin <5
    maxSmp = 150;% max number of samples to exceed velocity threshold
end
if nargin <6
    %minGap = 5;% min number of samples between consecutive saccades
    minGap = 3;% min number of samples between consecutive saccades
end

% format
if size(EyeDeg,2)>size(EyeDeg,1)
    EyeDeg = EyeDeg';
end
N       = length(EyeDeg);
v       = zeros(N,2);



% for k=1:N
%     
%     v(k,1)= EyeDeg(k,1);
%     
% end

for k=2:N-1
        
    if k>=3 & k<=N-2
        % moving h/v velocity average to suppress noise, after Engbert &
        % Kliegl (2003)
        v(k,1:2) = fS/6*[EyeDeg(k+2,1)+EyeDeg(k+1,1)-EyeDeg(k-1,1)-EyeDeg(k-2,1) ...
            EyeDeg(k+2,2)+EyeDeg(k+1,2)-EyeDeg(k-1,2)-EyeDeg(k-2,2)];
    end
end

vel = sqrt(v(:,1).^2 + v(:,2).^2);

i=1;
onset = [];
finish = [];
vpeak = [];
ampl = [];
while(i<=N)
    j=1;
    
    
    if vel(i) >=thresh
        
        while(vel(i+j) >= thresh)
            
            j = j + 1;
            
        end
        j = j-1;
        
        if j>=maxSmp
            disp('max saccade duration reached');
        end
        
        if j>=minSmp && j<=maxSmp
            onset = vertcat(onset,i);
            finish = vertcat(finish , (j+i));
            vpeak = vertcat(vpeak, max(vel(i: (j+i))));% peak velocity
            ampl = vertcat(ampl,sqrt( (EyeDeg(i,1)-EyeDeg(i+j,1))^2 + (EyeDeg(i,2)-EyeDeg(j+i,2))^2 ));  % amplitude
            i = i + j + minGap;
        else
            
            i = i + j + 1;
            
        end
    else
        i = i + 1;
    end
    
    
end


microsaccades = [onset , finish , vpeak , ampl];

end