function updateReplication(r, model)
    %% Read the lqn template file
    f = fileread('./LQNFiles/atom.lqn');
    %% Update the string 'f'
    for i = 1:size(r, 2)
        % Find and replace {{ri}} with the value r(i)
        old = strcat('{{r', int2str(i), '}}');
        new = int2str(r(i));
        f = strrep(f, old, new);
    end
    %% Write the lqn output file
    fid = fopen(strcat('./LQNFiles/', model, '-temp.lqn'), 'w');
    fprintf(fid, '%s', f);
    fclose(fid);
end

