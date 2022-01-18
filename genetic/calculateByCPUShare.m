function [np_new, st_new] = calculateByCPUShare(st_old, cpushare)
    np_new = ceil(cpushare);
    fact = np_new ./ cpushare;
    st_new = st_old * fact(2); % Update frontend entries
    st_new(1) = st_old(1) * fact(1); % Update router entry
end

