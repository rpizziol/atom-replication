% Obtain an attribute relative to an entry.
% INPUTS
%   xmlpath   : The path of the xml file.
%   entryname : The name of the entry.
%   attrname  : The identifier of the attribute.
% OUTPUTS
%   rt        : An array with all the values of attributes
function rt = getAttributeByEntry(xmlpath, entryname, attrname)
xdoc = xmlread(xmlpath);
entries = xdoc.getElementsByTagName('entry');
results = xdoc.getElementsByTagName('result-entry');
resultActivity= xdoc.getElementsByTagName('result-activity');
% Initialize variables
searching = true;
i = 0;
while searching
    % If the entry name match
    if strcmp(entryname, entries.item(i).getAttribute('name'))
        if(strcmp(attrname,"throughput"))
            % Pick the relative attribute
            rt = results.item(i).getAttribute(attrname);
            searching = false; % End search
        else
            if(strcmp(attrname,"service-time"))
                % Pick the relative attribute
                rt = resultActivity.item(i).getAttribute(attrname);
                searching = false; % End search
            end
        end
    else
        rt = [];
    end
    i = i + 1;
end
end