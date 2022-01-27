function updateModel(sourcepath, outpath, key, values)
    %% Read the lqn template file
    f = fileread(sourcepath);
    if strcmp(key, 'nuser')
        value = int2str(values(1));
        f = strrep(f, '{{nuser}}', value);        
    else
        for i = 1:size(values, 2)
            % Find and replace {{key[i]}} with the value values(i)
            placeholder = strcat('{{', key, '[', int2str(i), ']}}');
            if (floor(values(i)) == ceil(values(i)))
                value = int2str(values(i));
            else
                value = sprintf('%.4f', values(i));
            end
            f = strrep(f, placeholder, value);        
        end
    end
    %% Write the lqn output file
    fid = fopen(outpath, 'w');
    fprintf(fid, '%s', f);
    fclose(fid);
end

