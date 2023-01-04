function stopSystem(conn)
%STOPSYSTEM Summary of this function goes here
%   Detailed explanation goes here
    disp("stopping system")
    findquery = "{""started"":1}";
    updatequery = "{""$set"":{""toStop"":1}}";
    n = update(conn, "sim", findquery, updatequery);
    
    isStopped = false;
    while(~isStopped)
        try
            simDoc = find(conn,"sim");
        catch
            isStopped = true;
        end
    end
    disp("system stopped")
end

