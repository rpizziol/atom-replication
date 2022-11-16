clear
filenames = dir('./muOpt/*.mat');
for k = 1:size(filenames, 1)
    filename = filenames(k).name;
    wm = filename(end-4); % either 'b', 'o', or 's'
    nuser = str2double(filename(7:10));
    load(strcat('./muOpt/', filename));   
    if size(NC,2) == 3
        % Add missing column
        NC = [NC ones(size(NC, 1), 1)];
    end
    cpushare = NC(end, :);
    %thr = getThrByCPUShare(cpushare, nuser, wm);
    fprintf('%s - thr = %d\n', filename, thr);
    %fprintf('%s - time = %d\n', filename, stimes(end));
end


