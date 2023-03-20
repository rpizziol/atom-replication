function obj = computObj(tr,core,w)
maxcpu=60*9;
maxT=w * 0.77;

obj=1/2*(tr./maxT)-1/2*core/maxcpu;
end

%gaT(:,1), sum(ctrlGA(:,3:end,1),2),ctrlGA(:,2,1)