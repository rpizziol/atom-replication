clear
load("data/muopt_sin_paper.mat");

x=[0:30:600];

stairs(x,w);

% w=@(t)sin(t/(600/(2*pi)))*1500+1510;