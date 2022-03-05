function outTPS = calculateTPS(oldname, r, s)
    repname = strcat(oldname, '-tps1');
    updateReplication(oldname, repname, r)
    newname = strcat(oldname, '-tps2');
    updateHostDemand(repname, newname, s);
    [status,~] = system("cd LQNFiles; java -jar DiffLQN.jar " + newname + ".lqn");
    outTPS = 0; % Default value assigned in case of error
    if status == 0 % No error
        m = readmatrix(strcat('./LQNFiles/', newname, '.csv'));
        outTPS = m(1,4); % EntryBrowse
    end
end

