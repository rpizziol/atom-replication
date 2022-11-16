function wmProbs = getProbMix(wm)
%GETPROBMIX Get probabilites of the mix relative to the letter code.
% 'b' - Browsing Mix
% 'o' - Ordering Mix
% 's' - Shopping Mix
    if strcmp(wm, 'b')
        wmProbs = [0.63, 0.32, 0.05];
    elseif strcmp(wm, 'o')
        wmProbs = [0.33, 0.17, 0.50];
    elseif strcmp(wm, 's')
        wmProbs = [0.54, 0.26, 0.20];
    end
end

