clear
load('/home/robb/MEGA/IMT/Research/Autoscalers/ACMEAIR/nodejsMicro/data/acmeAir.py_full_data_out.mat')

updateModel('acmeair.lqn', 'acmeair-2.lqn', 'W', [Cli(end)]);
updateModel('acmeair-2.lqn', 'acmeair-2.lqn', 'nc', NCopt(end,:));
