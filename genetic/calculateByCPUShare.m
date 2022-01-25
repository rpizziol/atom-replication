function [np_new, st_new] = calculateByCPUShare(st_old, cpushare)
    np_new = ceil(cpushare);
    fact = np_new ./ cpushare;

    % Update Router entry
    st_new(1) = st_old(1) * fact(1);
    % Update Front-end entries
    st_new(2:4) = st_old(2:4) * fact(2);
    % Update Catalog Svc entries
    st_new(5:6) = st_old(5:6) * fact(3);
    % Update Carts Svc entries
    st_new(7:9) = st_old(7:9) * fact(4);

%     st_new = st_old * fact(2);
%     st_new(1) = st_old(1) * fact(1);
end

