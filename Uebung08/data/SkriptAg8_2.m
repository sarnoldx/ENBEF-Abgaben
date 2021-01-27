Nx = 5;
Ny = 5;
Nz = 5;
Np = Nx*Ny*Nz;
xmesh = [-1:0.5:1];
ymesh = [-1:0.5:1];
zmesh = [-1:0.5:1];


eps_r = calc_eps_linear(1,2,Nx,Ny,Nz);
length = 2;

Meps = createMeps(xmesh,ymesh,zmesh,eps_r);
Ss = fit_dual_div(Nx,Ny,Nz);
A = Ss*Meps*Ss';

spy(A);
Phi0 = zeros(Nx*Ny,1);
Phi1 = ones(Nx*Ny,1);

A12 = A([Nx*Ny+1:(Nz-1)*Nx*Ny],[1:Nx*Ny ((Nz-1)*Nx*Ny)+1:Np]);
A11 = A([Nx*Ny+1:(Nz-1)*Nx*Ny],[Nx*Ny+1:(Nz-1)*Nx*Ny]);
Phi01 = [Phi0;Phi1];

x1 = A11\(-A12*Phi01);
x = [Phi0;x1;Phi1];

e = Ss'*x;
E = [ e(1:Np), e(Np+(1:Np)), e(2*Np+(1:Np)) ] ;

%fit_write_vtk(xmesh,ymesh,zmesh,'kondensator.vtr',{'Phi(V)',x;'E',E});
n = 1;
index = 1;
idxV = zeros((Nx-1)*(Ny-1)*(Nz-1),1);
 for i = 1 :  Nz-1
     for j = 1 :  Ny-1
         for k = 1 :  Nx-1
             idxV(index,1) = n;
             index = index+1;
             n = n+1;
         end
         n = n+1;
     end
     n = n+Nx;
 end
 
ebar=fit_pe2pc(xmesh,ymesh,zmesh,e,idxV);
%fit_write_vtk(xmesh,ymesh,zmesh,'kondensator10.vtr',{'Phi (V)',x},{'ebar (V/m)',ebar(idxV,1:3)});

