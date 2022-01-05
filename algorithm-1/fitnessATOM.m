function value = fitnessATOM(r, s, model, params, Cmax)  
      newModelName = 'fitness-model';
      updateReplication(model.name, newModelName, r)
      [value, ~] = solveModel(newModelName, model.N, model.M, params, Cmax, r, s);
      value = -value; % This is just for optimtool (minimize)

%     %% Calculate total allocated CPU capacity (to minimize)
%     Ct = sum(r.*s); 
%     Chat = Ct / Cmax; % Normalized Ct
% 
%     %% Solve model and calculate Xt
%     % Xt = Number of transactions per unit time for a give period t and a
%     % particular class j of microservice i (TODO calculate with LQNS)
%     
%     updateReplication(r, modelName);
%     % updateCalls(rt); % TODO implement this method
%     % updateHostDemand(st); % TODO implement this method
%     
%     system('./LQN-exec.sh'); % solve model
% 
%     Xt = zeros(model.N, model.M);
%     m = readmatrix(strcat(modelName, '-temp.csv'));
%     Xt(1,1) = m(1,4); % EntryBrowse
%     Xt(2,1) = m(2,4); % EntryAddress
%     % EntryHome EntryCatalog EntryCarts
%     Xt(3,1) = m(3,4);
%     Xt(3,2) = m(4,4);
%     Xt(3,3) = m(5,4);
%     % EntryList EntryItem
%     Xt(4,1) = m(6,4);
%     Xt(4,2) = m(7,4);
% 
%     %% Calculate revenue (to maximize)
%     Bt = sum(sum(params.psi.*Xt));
%     Bmax = sum(sum(psi.*repmat(500, model.N, model.M))); % TODO update max value (500?)
%     Bhat = Bt / Bmax; % Normalized Bt
% 
%     %% Calculate objective function
%     value = (params.tau1 * Bhat - params.tau2 * Chat);
%     value = -value; % This is just for optimtool (minimize)
end
