% Obtain the number of the users using the application.
% OUTPUTS
%   nusers  : the number of users in the application.
function nusers = getCurrentUsers(redisConn)
    % Obtain the number of users from the Redis database
    % r = Redis("localhost",6379);

    nusers = 1;
    if(~isnan(str2double(redisConn.get("users"))))
        nusers=str2double(redisConn.get("users"));
    else
        disp("nuser not found")
    end
    
    % Hard-coded number of users for debug
    %nusers = 100;
end

