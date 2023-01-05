% Obtain the number of the users using the application.
% OUTPUTS
%   nusers  : the number of users in the application.
function nusers = getCurrentUsers()
    % Obtain the number of users from the Redis database
    % r = Redis("localhost",6379);  
    % nusers = r.get('users');
    
    % Hard-coded number of users for debug
    nusers = 100;
end

