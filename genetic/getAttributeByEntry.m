% Obtain an attribute relative to an entry.
% INPUTs
%   xmlpath   : the path of the xml file.
%   entryname : the name of the entry.
%   attrname  : the identifier of the attribute.
% OUTPUTS
%   rt        : an array with all the values of attributes 
function rt = getAttributeByEntry(xmlpath, entryname, attrname)
    xdoc = xmlread(xmlpath);
    entries = xdoc.getElementsByTagName('entry');
    results = xdoc.getElementsByTagName('result-entry');
    % Initialize variables
    searching = true;
    i = 0;
    while searching
        % If the entry name match
        if strcmp(entryname, entries.item(i).getAttribute('name'))
            % Pick the relative attribute
            rt = results.item(i).getAttribute(attrname);
            searching = false; % End search
        else
            rt = [];
        end
        i = i + 1;
    end
end