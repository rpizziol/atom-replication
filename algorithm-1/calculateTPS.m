function outTPS = calculateTPS(r) % TODO add s
    modelName = 'modelTPS';
    updateReplication(r, modelName);
    system("cd LQNFiles; java -jar DiffLQN.jar " + modelName + "-temp.lqn");
    m = readmatrix(strcat('./LQNFiles/', modelName, '-temp.csv'));
    outTPS = m(1,4); % EntryBrowse
end

