function outTPS = calculateTPS(r) % TODO add s
    modelName = 'modelTPS';
    updateReplication(r, modelName);
    [status,~] = system("cd LQNFiles; java -jar DiffLQN.jar " + modelName + "-temp.lqn");
    if status == 0 % No error
        m = readmatrix(strcat('./LQNFiles/', modelName, '-temp.csv'));
        outTPS = m(1,4); % EntryBrowse
    end
end

