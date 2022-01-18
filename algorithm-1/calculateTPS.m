function outTPS = calculateTPS(oldname, r) % TODO add s
    newname = strcat(oldname, '-temp-tps');
    updateReplication(oldname, newname, r)
    [status,~] = system("cd LQNFiles; java -jar DiffLQN.jar " + newname + ".lqn");
    outTPS = 0; % Default value assigned in case of error
    if status == 0 % No error
        m = readmatrix(strcat('./LQNFiles/', newname, '.csv'));
        outTPS = m(1,4); % EntryBrowse
    end
end

