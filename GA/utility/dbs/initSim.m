function initSim(conn)
    %INITSIM Summary of this function goes here
    %   Detailed explanation goes here
    collection = "sim";
    try
        dropCollection(conn,collection)
    catch
    end
    createCollection(conn,collection)
    simDoc.started=0;
    simDoc.toStop=0;
    insert(conn,collection,simDoc);
end


