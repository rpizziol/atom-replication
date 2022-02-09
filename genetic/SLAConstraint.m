function [c, ceq] = SLAConstraint(x)
    % Best response times possible (calculated with lqsim)
    rt_best = [0.00568904, 0.00210005, 0.00732427, 0.0165358, 0.00378144, ...
    0.00348144, 0.00710729, 0.0197073, 0.00790729];

    SLA = rt_best*1.1;

    %% Obtain response times
    rt = zeros(1, 9);
    entrynames = ["EntryAddress" "EntryHome" "EntryCatalog" ...
    "EntryCarts" "EntryList" "EntryItem" "EntryGet" "EntryAdd" ...
    "EntryDelete"];
    
    for i = 1:9
        rt(i) = str2double(getAttributeByEntry('./out/fittmp.lqxo', ...
            entrynames(i), 'phase1-service-time'));
    end

    disp(rt);

    % The value of c represents nonlinear inequality constraints that the
    % solver attempts to make less than or equal to zero
    c = [x(1) - SLA(1); x(2) - SLA(2)]; %rt - SLA;
    % The value of ceq represents nonlinear equality constraints that the
    % solver attempts to make equal to zero
    ceq = [];
end

