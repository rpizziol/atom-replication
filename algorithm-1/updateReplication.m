function updateReplication(sourcemodel, outmodel, r)
    %% Read the lqn template file
    f = fileread(strcat('./LQNFiles/', sourcemodel,'.lqn'));

    for i = 1:size(r, 2)
        % Find and replace {{nt[i]}} with the value r(i)
        old_t = strcat('{{nt[', int2str(i), ']}}');
        new_t = int2str(r(i));
        f = strrep(f, old_t, new_t);        
    end
    %% Write the lqn output file
    fid = fopen(strcat('./LQNFiles/', outmodel, '.lqn'), 'w');
    fprintf(fid, '%s', f);
    fclose(fid);
end

