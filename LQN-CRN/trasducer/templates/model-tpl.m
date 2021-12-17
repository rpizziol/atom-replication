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
if(iscolumn(NT))
    NC = NC';
end

p.MU = MU; 
p.NT = NT;
p.NC = NC;
p.delta = 10^5; % context switch rate (super fast)

%states name
{% for n in names %}%X({{loop.index}})={{n}};
{% endfor %}

%task ordering
{% for t in task %}%{{loop.index}}={{t.name}};
{% endfor %}

% Jump matrix
stoich_matrix=[{% for j in jumps %}{% for i in j %}{% if loop.last %}{% if i>=0 %}+{{i}}{% else %}{{i}}{% endif %}{% else %}{% if i>=0 %}+{{i}},  {% else %}{{i}},  {% endif %}{% endif %}{% endfor %};
               {% endfor %}];
    
tspan = [0, TF];
pfun = @propensities_2state;
 
X = zeros(length(X0), ceil(TF/dt) + 1, rep);
for i = 1:rep
	tic
    [t, x] = directMethod(stoich_matrix, pfun, tspan, X0, p);
    toc
    tic
    tsin = timeseries(x,t);
    tsout = resample(tsin, linspace(0, TF, ceil(TF/dt)+1), 'zoh');
    X(:, :, i) = tsout.Data';
    toc
end

end

% Propensity rate vector (CTMC)
function Rate = propensities_2state(X, p)
    Rate = [{% for p in props %}{{p}};
    		{% endfor %}];
    Rate(isnan(Rate))=0;
end