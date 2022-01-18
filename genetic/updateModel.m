function updateModel(sourcepath, outpath, key, values)
    %% Read the lqn template file
    f = fileread(sourcepath);

    for i = 1:size(values, 2)
        % Find and replace {{key[i]}} with the value values(i)
        placeholder = strcat('{{', key, '[', int2str(i), ']}}');
        value = sprintf('%.6f', values(i));
        f = strrep(f, placeholder, value);        
    end
    %% Write the lqn output file
    fid = fopen(outpath, 'w');
    fprintf(fid, '%s', f);
    fclose(fid);
end

