% Get probabilites of the mix relative to the letter code for Sock Shop.
% INPUTS
%   wm  : a character representing the kind of mix
%           'b' - Browsing Mix
%           'o' - Ordering Mix
%           's' - Shopping Mix
% OUTPUTS
%   wmProbs : an array containing the relative probability mix.
function wmProbs = getProbMix(wm)
    if strcmp(wm, 'b')
        wmProbs = [0.63, 0.32, 0.05];
    elseif strcmp(wm, 'o')
        wmProbs = [0.33, 0.17, 0.50];
    elseif strcmp(wm, 's')
        wmProbs = [0.54, 0.26, 0.20];
    end
end

