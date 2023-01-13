function [traceS] = parseRep(resPath)
    file=dir(sprintf("%s/*#.mat",resPath));
    maxT=inf;
    for i=1:size(file,1)
        repData=load(sprintf("%s/%s",file(i).folder,file(i).name));
        if(repData.bestTimeStamps(end)<=maxT)
            maxT=repData.bestTimeStamps(end)-repData.bestTimeStamps(1);
        end
    end
    
    traceS=zeros(10,round(maxT)+1,size(file,1));
    
    
    for i=1:size(file,1)
        repData=load(sprintf("%s/%s",file(i).folder,file(i).name));
        
        tsin = timeseries(repData.bestIndividuals,repData.bestTimeStamps-repData.bestTimeStamps(1));
        tsout = resample(tsin, linspace(0, round(maxT), ceil(round(maxT))+1), 'zoh');
        traceS(1:9, :, i) = tsout.Data';

        tsin = timeseries(repData.bestThroughputs,repData.bestTimeStamps-repData.bestTimeStamps(1));
        tsout = resample(tsin, linspace(0, round(maxT), ceil(round(maxT))+1), 'zoh');
        traceS(10, :, i) = tsout.Data';
    end
end

