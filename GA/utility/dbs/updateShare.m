function updateShare(msname,share)
%UPDATESHARE Summary of this function goes here
%   Detailed explanation goes here
    fprintf("update share of %s to %.3f",msname,share);
    r = Redis("localhost",6379);
    r.set(sprintf("%s_hw",msname),sprintf("%.3f",share));
    %lo lasico solo come esempio per fare una query
    %find(conn,"ms",Query=mongoquery);
end

