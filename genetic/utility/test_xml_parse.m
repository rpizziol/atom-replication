xdoc = xmlread('./out/output_test.lqxo');
% entry = xdoc.getElementsByTagName('result-entry');
% 
% for i = 1:11
%     disp(str2double(entry.item(i).getAttribute('throughput')));
% end
% 
% disp(entry)


 %% Obtain response times
% entry2 = xdoc.getElementsByTagName('result-entry');
% 
% rt = zeros(11, 1);
% for i = 1:11
%     rt(i) = str2double(entry2.item(i).getAttribute('phase1-service-time'));
% end
% 
% disp(rt)

 %% Obtain response times
entries = xdoc.getElementsByTagName('entry');
results = xdoc.getElementsByTagName('result-entry');

%rt = zeros(11, 1);
for i = 1:11
    entryname = entries.item(i).getAttribute('name');
    if strcmp('EntryAdd', entryname)
        disp(entryname);
        resptime = results.item(i).getAttribute('phase1-service-time');
        disp(resptime);
    end
end
