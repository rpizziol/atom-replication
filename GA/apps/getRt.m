function RT = getRt(model, modelName)
    RT = zeros(model.N, model.M);
    xmlpath = strcat('./out/', modelName, '.lqxo');
    
    if (strcmp(model.name, 'sockshop'))
%         %m = readmatrix(strcat('./out/', modelName, '.csv'));
%         % EntryBrowse
%         Xt(1,1) = str2double(getAttributeByEntry(xmlpath, 'EntryBrowse', 'throughput'));
%         % EntryAddress
%         Xt(2,1) = str2double(getAttributeByEntry(xmlpath, 'EntryAddress', 'throughput'));
%         % EntryHome EntryCatalog EntryCarts
%         Xt(3,1) = str2double(getAttributeByEntry(xmlpath, 'EntryHome', 'throughput'));
%         Xt(3,2) = str2double(getAttributeByEntry(xmlpath, 'EntryCatalog', 'throughput'));
%         Xt(3,3) = str2double(getAttributeByEntry(xmlpath, 'EntryCarts', 'throughput'));
%         % EntryList EntryItem
%         Xt(4,1) = str2double(getAttributeByEntry(xmlpath, 'EntryList', 'throughput'));
%         Xt(4,2) = str2double(getAttributeByEntry(xmlpath, 'EntryItem', 'throughput'));
%         % EntryGet EntryAdd EntryDelete
%         Xt(5,1) = str2double(getAttributeByEntry(xmlpath, 'EntryGet', 'throughput'));
%         Xt(5,2) = str2double(getAttributeByEntry(xmlpath, 'EntryAdd', 'throughput'));
%         Xt(5,3) = str2double(getAttributeByEntry(xmlpath, 'EntryDelete', 'throughput'));
%         % EntryQueryCatalog
%         Xt(6,1) = str2double(getAttributeByEntry(xmlpath, 'EntryQueryCatalog', 'throughput'));
%         % EntryQueryCartsdb
%         Xt(7,1) = str2double(getAttributeByEntry(xmlpath, 'EntryQueryCartsdb', 'throughput'));
    elseif (strcmp(model.name, 'acmeair'))
        % clientEntry
        RT(1,1) = str2double(getAttributeByEntry(xmlpath, 'clientEntry', 'service-time'));

        for i=1:length(model.ms)
            % MSauthEntry
            RT(i+1,1) = str2double(getAttributeByEntry(xmlpath, sprintf('%sEntry',model.ms(i)), 'service-time'));
        end
    end
end

