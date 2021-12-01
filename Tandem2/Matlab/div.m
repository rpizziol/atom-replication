% Divide x by y (handle division by 0 as 0)
function d = div(x,y)
    if(y == 0)
        d = 0;
    else
        d = x/y;
    end
end