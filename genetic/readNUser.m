function nuser = readNUser()
    xdoc = xmlread('./res/atom-full_template6.lqnx');
    tasks = xdoc.getElementsByTagName('task');
    nuser = floor(str2double(tasks.item(0).getAttribute('multiplicity')));
end

