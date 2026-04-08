tau=1.8;
t0 = tau+2e-3+10e-3+11e-3+10e-3+2e-3; 
t = t0:TR:(t0+(Nsegs*Nphases-1)*TR);
params.f=1;
params.Deltat=linspace(0.2,2.5,1e4);
Sig = BuxtonCASLModel(t,params.f,params.Deltat,tau,params.T1,T1b);