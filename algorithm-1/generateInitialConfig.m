function [rConfigs, sConfigs] = generateInitialConfig(Q, s_lb, s_ub, N, K)
    % Configurations' sets
    rConfigs = zeros(K, N);
    sConfigs = zeros(K, N);

    rt = zeros(1, N); % Number of replicas for each microservice
    st = zeros(1, N); % CPU share for each microservice

    for j = 1:K
        % Generate a new random solution candidate
        for i = 1:N
            rt(i) = randi([1 Q(i)]);
            st(i) = randi([s_lb(i) s_ub(i)])/1000;
        end
        % Update the configurations' sets
        rConfigs(j, :) = rt;
        sConfigs(j, :) = st;
    end
end

