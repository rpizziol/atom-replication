function updateHostDemand(sourcemodel, outmodel, s)
    % Default service rates
    sr_default = [0.0021, 0.0051, 0.0022, 0.0019];
    % New service rates
    sr = sr_default ./ s;
    %% Read the lqn template file
    f = fileread(strcat('./LQNFiles/', sourcemodel,'.lqn'));

    for i = 1:size(sr, 2)
        % Find and replace {{sr[i]}} with the value sr(i)
        old_t = strcat('{{sr[', int2str(i), ']}}');
        %new_t = int2str(sr(i));
        new_t = sprintf('%.4f', sr(i));
        f = strrep(f, old_t, new_t);        
    end
    %% Write the lqn output file
    fid = fopen(strcat('./LQNFiles/', outmodel, '.lqn'), 'w');
    fprintf(fid, '%s', f);
    fclose(fid);
end

