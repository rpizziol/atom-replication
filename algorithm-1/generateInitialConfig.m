function configs = generateInitialConfig(Q, s_lb, s_ub, N, K)
    % Configurations' sets
    configs.r = zeros(K, N);
    configs.s = zeros(K, N);

    rt = zeros(1, N); % Number of replicas for each microservice
    st = zeros(1, N); % CPU share for each microservice

    for j = 1:K
        % Generate a new random solution candidate
        for i = 1:N
            rt(i) = randi([1 Q(i)]);
            st(i) = randi([s_lb(i) s_ub(i)])/1000;
        end
        % Update the configurations' sets
        configs.r(j, :) = rt;
        configs.s(j, :) = st;
    end
end

