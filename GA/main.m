function main(code)% Functions relative to the web application used
    addpath('./apps/');
    % Utility functions
    addpath('./utility/');
    % xml and lqn templates defining the models
    addpath('./res/');
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
    end
end