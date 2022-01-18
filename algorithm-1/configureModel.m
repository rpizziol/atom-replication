function newname = configureModel(sourcemodel, nuser, nc, nt)
    %% Read the lqn template file
    f = fileread(strcat('./LQNFiles/', sourcemodel,'.lqn'));
    %% Update the string 'f'
    f = strrep(f, '{{nuser}}', int2str(nuser));

    for i = 1:size(nc, 2)
        % Find and replace {{nc[i]}} with the value nc(i)
        old_c = strcat('{{nc[', int2str(i), ']}}');
        new_c = int2str(nc(i));
        f = strrep(f, old_c, new_c);
    end

    for i = 1:size(nt, 2)
        % Find and replace {{nt[i]}} with the value nt(i)
        old_t = strcat('{{nt[', int2str(i), ']}}');
        new_t = int2str(nt(i));
        f = strrep(f, old_t, new_t);
    end

    %% Write the lqn output file
    newname = strcat(sourcemodel, int2str(nuser));
    fid = fopen(strcat('./LQNFiles/', newname, '.lqn'), 'w');
    fprintf(fid, '%s', f);
    fclose(fid);
    disp(strcat("Model ", newname, " configured."))
end

