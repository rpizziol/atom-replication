uniqueX = -2 * pi : pi/4 : 2*pi;

x = repelem(uniqueX, 3);
y = sin(x) + 0.5 * rand(size(x));
 

%plot(x,y)
cip = confidenceIntervalPlot(x,y);
cip.NumSteps = 10;

% title("95% Confidence Interval Plot, Sine Curve with Random Noise");
% subtitle("Alpha = 0.05");
