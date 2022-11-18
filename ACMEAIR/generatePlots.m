clear

MSs = ["Client", "Auth", "ValidateId", ...
    "ViewProfile", "UpdateProfile", "UpdateMiles", ...
    "BookFlights", "CancelBooking", "QueryFlights", ...
    "GetRewardMiles"];

load('./out.mat');
wi = load('./acmeAir.py_full_2b.mat');

boxplot((abs(wi.Tm - Tp)./Tp)*100, MSs);
exportgraphics(gcf, 'validation.pdf');
close all

st = [0.2, 0.15, 0.08, 0.15, 0.2, 0.04, 0.1, 0.087, 0.09, 0.05]; % service time nominale

boxplot((abs(st - RTp)./RTp)*100, MSs);