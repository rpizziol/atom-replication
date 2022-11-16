clear

sourcefile = 'acmeair.lqn';
tempfile = 'acmeair-2.lqn';
outfile = 'acmeair-2.lqxo';

% Load data and what if
data = load('./acmeAir.py_full_data_out.mat');
wi = load('./acmeAir.py_full_10b.mat');

Tp = zeros(size(wi.Tm));
RTp = zeros(size(wi.RTm));

entries = ["clientEntry", "MSauthEntry", "MSvalidateidEntry", ...
    "MSviewprofileEntry", "MSupdateprofileEntry", "MSupdateMilesEntry", ...
    "MSbookflightsEntry", "MScancelbookingEntry", "MSqueryflightsEntry", ...
    "MSgetrewardmilesEntry"];

for i = 1:25
    % Update model with number of users and cores
    updateModel(sourcefile, tempfile, 'W', [wi.Cli(i)]);
    updateModel(tempfile, tempfile, 'nc', wi.NC(i,:));
    % Solve the model
    [status, ~] = system("lqns -x " + tempfile);
    % Obtain output throughput and service time
    if status == 0
        for j = 1:size(entries, 2)
            thr = getAttributeByEntry(outfile, entries(j), 'throughput');
            Tp(i, j) = thr(1);
            %disp(thr);
            %disp(thr(1));
        end
        delete(outfile);
    end
end

