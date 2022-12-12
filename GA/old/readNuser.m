% Read the value of nuser in the lqnx file.
% INPUTS
%   xmlpath : the path of the xml file to read.
% OUTPUTS
%   nuser   : the value of nuser read in the lqnx file.
function nuser = readNuser(xmlpath)
    xdoc = xmlread(xmlpath);
    tasks = xdoc.getElementsByTagName('task');
    nuser = floor(str2double(tasks.item(0).getAttribute('multiplicity')));
end

