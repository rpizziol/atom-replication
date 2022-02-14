function nuser = readNUser()
    xdoc = xmlread('./res/atom-full_template6.lqnx');
    tasks = xdoc.getElementsByTagName('task');
    nuser = tasks.item(0).getAttribute('multiplicity');
end

