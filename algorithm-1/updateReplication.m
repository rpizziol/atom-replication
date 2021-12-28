function updateReplication(r, model)
    %% Open the lqn template file
    fid = fopen('./LQNFiles/atom.lqn', 'r');
    f = fread(fid);
    fclose(fid);
    %% Update the string 'f'
    for i = 1:size(r, 2)
        % Find and replace {{ri}} with the value r(i)
        f = strrep(f, strcat('{{r', int2str(i), '}}'), int2str(r(i)));
    end
    %% Write the lqn output file
    fid = fopen(strcat('./LQNFiles/', model, '-temp.lqn'), 'w');
    fprintf(fid, '%s', f);
    fclose(fid);
end

