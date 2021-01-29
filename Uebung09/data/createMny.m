function Mnu = createMny(xmesh,ymesh,zmesh,ny)
Nx = size(xmesh);
Nx = Nx(1,2);
Ny = size(ymesh);
Ny = Ny(1,2);
Nz = size(zmesh);
Nz = Nz(1,2);
Np = Nx*Ny*Nz;
Mx = 1;
My = Nx;
Mz = Nx*Ny;

Mnu = zeros(3*Np,3*Np);
[ddS, dS, ddA, dA] = fit_calc_elements2(xmesh,ymesh,zmesh);

for n = 1 : Np
    if n-Mx>=1
        avgny = fit_calc_avgny(dS(n,1),dS(n-Mx,1),ddS(n,1),ny(n,1),ny(n-Mx,1));
    else
        avgny = fit_calc_avgny(dS(n,1),0,ddS(n,1),ny(n,1),0);
    end
    Mnu(n,n) = (avgny*ddS(n,1))/dA(n,1);
end

for n = 1 : Np
    if n-My>=1
        avgny = fit_calc_avgny(dS(n,2),dS(n-My,1),ddS(n,2),ny(n,1),ny(n-My,1));
    else
        avgny = fit_calc_avgny(dS(n,2),0,ddS(n,2),ny(n,1),0);
    end
    Mnu(Np+n,Np+n) = (avgny*ddS(n,2))/dA(n,2);
end

for n = 1 : Np
    if n-Mz  >= 1
        avgny = fit_calc_avgny(dS(n,3),dS(n-Mz,3),ddS(n,3),ny(n,1),ny(n-Mz,1));
    else
        avgny = fit_calc_avgny(dS(n,3),0,ddS(n,3),ny(n,1),0);
    end
    Mnu(2*Np+n,2*Np+n) = (avgny*ddS(n,3))/dA(n,3);
end

end