% Solve the LQN model by means of lqns
% INPUTS
%   modelName   : The name of the to the lqnx/lqn file to execute.
%   model       : A structure containing information about the model.
%   params      : A structure containing parameters of the optimization.
%   s           : The CPU share array.
%   nuser       : The number of users in the model.
% OUTPUTS
%   fval        : The value of the objective function given s.
function fval = solveModel(modelName, model, params, s, nuser)
    global countIndividual

    %% Calculate total allocated CPU capacity (to minimize)
    Cmax = sum(params.s_ub); %constraints.Q.*constraints.s_ub);
    Ct = sum(s);  %sum(r.*s); 
    Chat = Ct / Cmax; % Normalized Ct

    [status, ~] = system("lqns --schweitzer  --method-of-layers -x ./out/" + modelName + "." + model.extension);
    
    if countIndividual == 1
        fprintf("countIndividual = %d", countIndividual);
    else
        fprintf(" %d", countIndividual);
    end

    if status == 0 % no error
        Xt = getXt(model, modelName);
    
        %% Calculate revenue (to maximize)
        Bt = Xt(1,1); %sum(sum(params.psi.*Xt));

        

        % TODO think time sockshop 7 / acmeair 0.27538
        %Bmax = sum(sum(params.psi.*repmat(nuser / 0.27538, model.N, model.M))); % nuser (3000) / 7 (think time)
        if (strcmp(model.name, 'sockshop'))
            Bmax = nuser / 7;
        elseif (strcmp(model.name, 'acmeair'))
            Bmax = nuser * 0.5368; %/ 0.27538;
        end
        Bhat = Bt / Bmax; % Normalized Bt
    
        %% Calculate objective function
        fval = (params.tau1 * Bhat - params.tau2 * Chat);

        disp([Bt,Bhat,Bmax,Ct,Chat,fval])
        %% Obtain response times
%         rt = zeros(1, 9);
%         entrynames = ["EntryAddress" "EntryHome" "EntryCatalog" ...
%             "EntryCarts" "EntryList" "EntryItem" "EntryGet" "EntryAdd" ...
%             "EntryDelete"];
% 
%         for i = 1:9
%             rt(i) = str2double(getAttributeByEntry(xmlpath, entrynames(i), 'phase1-service-time'));
%         end
    end
    %% Remove xml files
    deleteXmlFiles(model, modelName);

end