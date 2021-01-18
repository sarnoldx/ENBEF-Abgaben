Nx = 21;
Ny = 21;
Nz = 21;
Np = Nx * Ny * Nz;
x = -1;
y = -1;
z = -1;
Phi = zeros(1,Nx*Ny*Nz);
Points = zeros(Nx*Ny*Nz,3);
length = 2;
n = 1;

for i = 1 :  Nz
    for j = 1 :  Ny
        for k = 1 :  Nx
            stepx = calc_steps(Nx,length);
            stepy = calc_steps(Ny,length);
            stepz = calc_steps(Nz,length);
            Phi(1,n) = ((x+stepx*(k-1)))^2*sin(2*pi*(z+stepz*(i-1)));
            
            Points(n,1)=(x+stepx*(k-1));
            Points(n,2)=(y+stepy*(j-1));
            Points(n,3)=(z+stepz*(i-1));
            n = n+1;
        end
    end
end

xmesh = [-1:0.1:1];
ymesh = [-1:0.1:1];
zmesh = [-1:0.1:1];

Ss = fit_dual_div(Nx,Ny,Nz);
e = Ss.'.*Phi;

e = sum(e,2);

%spy(e)
exyz = [ e(1:Np), e(Np+(1:Np)), e(2*Np+(1:Np)) ] ;
fit_write_vtk(xmesh,ymesh,zmesh,'Uebung07.vtr',{'Phi(V)',Phi.';'e(V)',exyz});
