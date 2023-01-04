function main(code)% Functions relative to the web application used
    addpath('./apps');
    % Utility functions
    addpath('./utility');
    addpath('./utility/dbs');
    % xml and lqn templates defining the models
    addpath('./res');
    % Redis
    addpath('/root/git/MatlabRedis');       
    
    if (code == 1)
        [model, params] = initializeSockShop('b');
        runExperiment(model, params);
    elseif (code == 2)
        % Initialize application
        server = "localhost";
        port = 27017;
        dbname = "sys";
        conn = mongoc(server, port, dbname);
        if(~isopen(conn))
            error("error whilt connecting to mongodb")
        end

        initSim(conn);
        startSystem(conn);

        [model, params] = initializeAcmeAir();
        runExperiment(model, params);
        %stoppo il sistrema settamndo a 1 il campo toStop
        stopStystem(conn);

        %msData=readData("../data/ICDCS/*.csv");

        %per visualizzare i risultati importo i csv che sono stati esportati dal
        %sisrtema
        close(conn)

    end
end