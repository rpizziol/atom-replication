function startSystem(conn)
%STARTSYSTEM Summary of this function goes here
%   Detailed explanation goes here
    [status,cmdout] = system("python3 acmeAir_ICDCS.py &");
    %aspetto che il sistema sia partito completamnte
    simDoc = find(conn,"sim");
    while(simDoc.started~=1)
        disp("waiting system to start")
        pause(0.5)
        try
            simDoc = find(conn,"sim");
        catch
        end
    end
    disp("system started")
end

