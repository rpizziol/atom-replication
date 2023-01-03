% Calculate number of processors and service time given the default values 
% of service time and the CPU share.
% INPUTS
%   st_old      : the default value of the service time.
%   cpushare    : the target CPU share value.
% OUTPUTS
%   np_new  : the newly calculated array of number of processors.
%   st_new  : the newly calculated array of service time.
function [np_new, st_new] = calculateByCPUShare(cpushare, model)
    st_old = model.st;
    %% np_new
    np_new = ceil(cpushare);

    %% st_new
    fact = np_new ./ cpushare;
    if (strcmp('sockshop', model.name))
        % Update Router entry
        st_new(1) = st_old(1) * fact(1);
        % Update Front-end entries
        st_new(2:4) = st_old(2:4) * fact(2);
        % Update Catalog Svc entries
        st_new(5:6) = st_old(5:6) * fact(3);
        % Update Carts Svc entries
        st_new(7:9) = st_old(7:9) * fact(4);
    elseif (strcmp('acmeair', model.name))
        st_new = st_old .* fact;
    end
end

