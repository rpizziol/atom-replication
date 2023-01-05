function deleteXmlFiles(model, modelName)
    delete(strcat('./out/', modelName, '.', model.extension));
    delete(strcat('./out/', modelName, '.out'));
    delete(strcat('./out/', modelName, '.lqxo'));
end

