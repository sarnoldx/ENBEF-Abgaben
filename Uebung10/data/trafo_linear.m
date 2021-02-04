% get data
load trafo_linear.mat;

% get mesh data
nx = length(prb.xmesh);
ny = length(prb.ymesh); 
nz = length(prb.zmesh);
np = nx*ny*nz;

% get and shrink conductivity matrix
Msigma = prb.Msigma;
Msigma = Msigma(prb.idxdof,prb.idxdof);
M = Msigma;

% ---- do something here ---- 
% construct curl-matrix
C = fit_operator(nx,ny,nz);
% ---- do something here ---- 

% create and shrink curl-curl matrix
K = C'*spdiags(prb.Nu,0,3*np,3*np)*C;
K = K(prb.idxdof,prb.idxdof);

% get and shrink excitation matrix
X = prb.Qstr;
X = X(prb.idxdof,:);

% time parameters
T0    = 0.00;
Tend  = 0.02;
dt    = 1e-3; % try dt=1e-4 if your computer is fast.... 

% discrete time vector
T    = T0:dt:Tend;

% initialize solution
f     = 50;
a     = zeros(size(M,1),length(T));
i     = @(t) (10*[sin(2*pi*f*t);0*t]);

% construct preconditioner for pcg
% use "pcg(A,b,1e-6,1000,Z,Z)" to solve 
% the linear problem Ax=b for x
Z = sparse(1:size(a,1),1:size(a,1),sqrt(diag(M/dt+K)));

% time loop with equidistant time steps
for jj=2:length(T)

  % ---- do something here ---- 
  % solve M*a'+K*a=X*i with the implicit Euler method 
  h = (1/0.001);
  A = h*M+K;
  b = X*i(T(jj)) + h*M*a(:,jj-1);
  %x = a(:,jj);
  a(:,jj) = pcg(A,b,1e-6,1000,Z,Z);
  %a(:,jj)=a(:,jj);
  % ---- do something here ---- 

end


% Postprocessing 1: plot the current excitation i(t)
% ---- do something here ---- 
plot(i(T(:)));
 % ---- do something here ---- 

 % Postprocessing 2: return the fluxes B!
 A = zeros(length(prb.ds),1);
 B = zeros(length(prb.ds),1);
 for jj=1:length(T)
   A(prb.idxdof) = a(:,jj);
   
   % ---- do something here ---- 
   % compute the facet integrated fluxes b
   B = C*A; 
   % ---- do something here ---- 
     
   % scaling and write to file
   A(prb.idxs) = A(prb.idxs)./prb.ds(prb.idxs); 
   B(prb.idxA) = B(prb.idxA)./prb.dA(prb.idxA); 
   fit_write_vtk (prb.xmesh,prb.ymesh,prb.zmesh,['solution_' num2str(jj,'%03d') '.vtr'],...
                  {'MVP',A;'Flux',B},{'Region',prb.Elem(prb.idxV);});
 end
% visualize the result in Paraview, e.g. onprb a cutplane
