function eps_r = calc_eps_linear(epsMin,epsMax,Nx,Ny,Nz)
Np = Nx*Ny*Nz;
eps = epsMin;
step = (epsMax-epsMin)/(Nz-1);
eps_r = zeros(Np,1);
for i=1 : Np
    eps_r(i,1) = eps;
    if(mod(i,Nx*Ny) == 0)
        eps = eps + step;
    end
end