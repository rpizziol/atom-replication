clear

sourcefile = 'acmeair.lqn';
tempfile = 'acmeair-2.lqn';
outfile = 'acmeair-2.lqxo';

% Load data and what if
data = load('./acmeAir.py_full_data_out.mat');
wi = load('./acmeAir.py_full_10b.mat');

for i = 1:25
    % Update model with number of users and cores
    updateModel(sourcefile, tempfile, 'W', [wi.Cli(i)]);
    updateModel(tempfile, tempfile, 'nc', wi.NC(i,:));
    % Solve the model
    [status, ~] = system("lqns -x" + tempfile);
    % Obtain output throughput and service time
    disp(getAttributeByEntry(outfile, 'clientEntry', 'throughput'));
end

