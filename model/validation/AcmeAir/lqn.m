function X = lqn(X0,MU,NT,NC,TF,rep,dt)
import Gillespie.*

% Make sure vector components are doubles
X0 = double(X0);
MU = double(MU);

% Make sure all vectors are row vectors
if(iscolumn(X0))
    X0 = X0';
end
if(iscolumn(MU))
    MU = MU';
end
if(iscolumn(NT))
    NT = NT';
end
if(iscolumn(NC))
    NC = NC';
end

p.MU = MU;
p.NT = NT;
p.NC = NC;
p.delta = 10^3; % context switch rate (super fast)

%states name
%X(1)=XBrowse_2Login;
%X(2)=XLogin_a;
%X(3)=XLogin_2Validate;
%X(4)=XValidate_a;
%X(5)=XValidate_e;
%X(6)=XLogin_e;
%X(7)=XBrowse_2View;
%X(8)=XViewProfile_a;
%X(9)=XViewProfile_e;
%X(10)=XBrowse_2UpdateProfile;
%X(11)=XUpdateProfile_a;
%X(12)=XUpdateProfile_e;
%X(13)=XBrowse_2Query;
%X(14)=XQuery_a;
%X(15)=XQuery_e;
%X(16)=XBrowse_2Book;
%X(17)=XBook_a;
%X(18)=XBook_2UpdateMiles;
%X(19)=XUpdateMiles_a;
%X(20)=XUpdateMiles_e;
%X(21)=XBook_2GetReward;
%X(22)=XGetReward_a;
%X(23)=XGetReward_e;
%X(24)=XBook_e;
%X(25)=XBrowse_2Cancel;
%X(26)=XCancel_a;
%X(27)=XCancel_2UpdateMilesCancel;
%X(28)=XCancel_2GetRewardCancel;
%X(29)=XCancel_e;
%X(30)=XBrowse_e;


%task ordering
%1=Client;
%2=Auth;
%3=ValidateId;
%4=BookFlight;
%5=UpdateMiles;
%6=CancelBooking;
%7=GetRewardsMiles;
%8=QueryFlight;
%9=ViewProfile;
%10=UpdateProfile;


stoich_matrix=[+1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1;
    +0,  -1,  +1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
    +0,  +0,  +0,  -1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
    +0,  +0,  -1,  +0,  -1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
    -1,  +0,  +0,  +0,  +0,  -1,  +1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
    +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
    +0,  +0,  +0,  +0,  +0,  +0,  -1,  +0,  -1,  +1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
    +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
    +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +0,  -1,  +1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
    +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
    +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +0,  -1,  +1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
    +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
    +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
    +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +0,  -1,  +1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
    +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  +0;
    +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +0,  -1,  +1,  +0,  +0,  +0,  +0,  +0,  +0;
    +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +1,  +1,  +0,  +0,  +0,  +0;
    +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +1,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +1,  +0,  +0,  +0;
    +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +0,  +1,  +0,  +0,  +0,  +0,  -1,  +1,  +0,  +0;
    +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +0,  +0,  +0,  +0,  -1,  +1,  +0;
    +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  -1,  +0,  +0,  +0,  -1,  +1;
    +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +0,  +1,  +0,  +0,  -1,  +0;
    ];

tspan = [0, TF];
pfun = @propensities_2state;

X = zeros(length(X0), ceil(TF/dt) + 1, rep);
for i = 1:rep
    [t, x] = firstReactionMethod(stoich_matrix, pfun, tspan, X0, p,[],10000000);
    tsin = timeseries(x,t);
    tsout = resample(tsin, linspace(0, TF, ceil(TF/dt)+1), 'zoh');
    X(:, :, i) = tsout.Data';
end

end

% Propensity rate vector (CTMC)
function Rate = propensities_2state(X, p)
Rate = [p.MU(30)*X(30);%Tclient
    p.delta*min(X(2),p.NT(2)-(X(3)+X(6)));
    p.delta*min(X(4),p.NT(3)-(X(5)));
    min(X(5),p.NC(3))*p.MU(5); %Tvalidateid
    min(X(6),p.NC(2))*p.MU(6); %Tauth
    p.delta*min(X(8),p.NT(9)-(X(9)));
    0.5*min(X(9),p.NC(9))*p.MU(9); %Tviewprofile
    p.delta*min(X(11),p.NT(10)-(X(12)));
    min(X(12),p.NC(10))*p.MU(12);%TupdateProfile
    p.delta*min(X(14),p.NT(8)-(X(15)));
    min(X(15),p.NC(8))*p.MU(15);%Tquery
    p.delta*min(X(17),p.NT(4)-(X(18)+X(21)+X(24)));
    p.delta*min(X(19),p.NT(5)-(X(20)));
    0.5*X(18)/(X(18)+X(27))*min(X(20),p.NC(5))*p.MU(20); %TUpdateMiles
    p.delta*min(X(22),p.NT(7)-(X(23)));
    0.5*X(21)/(X(21)+X(28))*min(X(23),p.NC(7))*p.MU(23); %TGetReward
    min(X(24),p.NC(4))*p.MU(24); %Tbook
    p.delta*min(X(26),p.NT(6)-(X(27)+X(28)+X(29)));
    X(27)/(X(18)+X(27))*min(X(20),p.NC(5))*p.MU(20); %TUpdateMiles
    X(28)/(X(21)+X(28))*min(X(23),p.NC(7))*p.MU(23); %TGetReward
    1/2*min(X(29),p.NC(6))*p.MU(29); %Tcancel_end
    1/2*min(X(29),p.NC(6))*p.MU(29); %Tcancel_loop
    ];
Rate(isnan(Rate))=0;
end