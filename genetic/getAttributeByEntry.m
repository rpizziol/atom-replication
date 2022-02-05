function rt = getAttributeByEntry(xmlpath, entryname, attrname)
    xdoc = xmlread(xmlpath);
    %xdoc = xmlread('./out/output_test.lqxo');
    entries = xdoc.getElementsByTagName('entry');
    results = xdoc.getElementsByTagName('result-entry');
    searching = true;
    i = 0;
    while searching
        if strcmp(entryname, entries.item(i).getAttribute('name'))
            rt = results.item(i).getAttribute(attrname);
            searching = false;
        else
            rt = Inf;
        end
        i = i + 1;
    end
end

