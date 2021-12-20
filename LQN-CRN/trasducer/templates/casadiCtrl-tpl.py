import numpy as np
import casadi

class {{name}}Ctrl(object):

	#states name
	{% for n in names %}#X({{loop.index0}})={{n}};
	{% endfor %}
	
	#task ordering
	{% for t in task %}#{{loop.index0}}={{t.name}};
	{% endfor %}
	
	model = None
	stateVar = None
	NT = None
	NC = None
	initX = None
	H = None
	
	name =  "{{name}}"
	stoich_matrix =  np.matrix([{% for j in jumps %}[{% for i in j %}{% if loop.last %}{% if i>=0 %}+{{i}}{% else %}{{i}}{% endif %}{% else %}{% if i>=0 %}+{{i}},  {% else %}{{i}},  {% endif %}{% endif %}{% endfor %}],
	          {% endfor %}]);
	
	def __init__(self,H=5):
		self.H = H
		self.model = self.model = casadi.Opti()
		self.stateVar = self.model.variable({{names|length}},H);
		self.initX = self.model.parameter({{names|length}},1)
		self.NC = self.model.variable({{task|length}},1);
		self.NT = self.model.variable({{task|length}},1);
		self.buildOpt()
	
	def buildOpt(self):
		pass
	
	def Solve(self,X0,MU,NC_old=None,NT_old=None):
		pass
		
	
	#def prop_func(self,X,p):
	#	Rate=np.matrix([{% for p in props %}{{p}},
	#			{% endfor %}])
	#	Rate[np.isnan(Rate)]=0;
	#	return Rate.tolist()[0]