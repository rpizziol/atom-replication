function Xt = getXt(model)
    %GETXT Summary of this function goes here
    %   Detailed explanation goes here
    % TODO read by means of xpath queries.
    Xt = zeros(model.N, model.M);
    xmlpath = strcat('./out/', modelName, '.lqxo');
    
    if (strcmp(model.name, 'sockshop'))
        %m = readmatrix(strcat('./out/', modelName, '.csv'));
        % EntryBrowse
        Xt(1,1) = str2double(getAttributeByEntry(xmlpath, 'EntryBrowse', 'throughput'));
        % EntryAddress
        Xt(2,1) = str2double(getAttributeByEntry(xmlpath, 'EntryAddress', 'throughput'));
        % EntryHome EntryCatalog EntryCarts
        Xt(3,1) = str2double(getAttributeByEntry(xmlpath, 'EntryHome', 'throughput'));
        Xt(3,2) = str2double(getAttributeByEntry(xmlpath, 'EntryCatalog', 'throughput'));
        Xt(3,3) = str2double(getAttributeByEntry(xmlpath, 'EntryCarts', 'throughput'));
        % EntryList EntryItem
        Xt(4,1) = str2double(getAttributeByEntry(xmlpath, 'EntryList', 'throughput'));
        Xt(4,2) = str2double(getAttributeByEntry(xmlpath, 'EntryItem', 'throughput'));
        % EntryGet EntryAdd EntryDelete
        Xt(5,1) = str2double(getAttributeByEntry(xmlpath, 'EntryGet', 'throughput'));
        Xt(5,2) = str2double(getAttributeByEntry(xmlpath, 'EntryAdd', 'throughput'));
        Xt(5,3) = str2double(getAttributeByEntry(xmlpath, 'EntryDelete', 'throughput'));
        % EntryQueryCatalog
        Xt(6,1) = str2double(getAttributeByEntry(xmlpath, 'EntryQueryCatalog', 'throughput'));
        % EntryQueryCartsdb
        Xt(7,1) = str2double(getAttributeByEntry(xmlpath, 'EntryQueryCartsdb', 'throughput'));
    else if (strcmp(model.name, 'acmeair'))
        % clientEntry
        Xt(1,1) = str2double(getAttributeByEntry(xmlpath, 'clientEntry', 'throughput'));
        % MSauthEntry
        Xt(2,1) = str2double(getAttributeByEntry(xmlpath, 'MSauthEntry', 'throughput'));
        % MSvalidateidEntry
        Xt(3,1) = str2double(getAttributeByEntry(xmlpath, 'MSvalidateidEntry', 'throughput'));
        % MSviewprofileEntry
        Xt(4,1) = str2double(getAttributeByEntry(xmlpath, 'MSviewprofileEntry', 'throughput'));
        % MSupdateprofileEntry
        Xt(5,1) = str2double(getAttributeByEntry(xmlpath, 'MSupdateprofileEntry', 'throughput'));
        % MSupdateMilesEntry
        Xt(6,1) = str2double(getAttributeByEntry(xmlpath, 'MSupdateMilesEntry', 'throughput'));
        % MSbookflightsEntry
        Xt(7,1) = str2double(getAttributeByEntry(xmlpath, 'MSbookflightsEntry', 'throughput'));
        % MScancelbookingEntry
        Xt(8,1) = str2double(getAttributeByEntry(xmlpath, 'MScancelbookingEntry', 'throughput'));
        % MSqueryflightsEntry
        Xt(9,1) = str2double(getAttributeByEntry(xmlpath, 'MSqueryflightsEntry', 'throughput'));
        % MSgetrewardmilesEntry
        Xt(10,1) = str2double(getAttributeByEntry(xmlpath, 'MSgetrewardmilesEntry', 'throughput'));
    end
end

