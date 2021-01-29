function [ddS,dS,ddA,dA] = fit_calc_elements(xmesh,ymesh,zmesh)
Nx = size(xmesh);
Nx = Nx(1,2);
Ny = size(ymesh);
Ny = Ny(1,2);
Nz = size(zmesh);
Nz = Nz(1,2);
Np = Nx*Ny*Nz;

stepx = calc_steps(Nx,xmesh(1,Nx)-xmesh(1,1));
stepy = calc_steps(Ny,ymesh(1,Ny)-ymesh(1,1));
stepz = calc_steps(Nz,zmesh(1,Nz)-zmesh(1,1));

dA = zeros(Np,3);
ddA = zeros(Np,3);
dS = zeros(Np,3);
ddS = zeros(Np,3);
z = 1;

%%%%% Berechnung dS und ddS %%%%%
for i = 1 :  Np
    if mod(i,Nx) ~= 0
        dS(i,1) = stepx;
        ddS(Np+1-i,1) = stepx;
    end
    if i <= z*Nx*Ny-Nx
        dS(i,2) = stepy;
        ddS(Np+1-i,2) = stepy;
    end
    if i <= Nx*Ny*(Nz-1)
        dS(i,3) = stepz;
        ddS(Np+1-i,3) = stepz;
    end
    if i == z*Nx*Ny
        z = z + 1;
    end
end

%%%%% Berechnung dA und ddA %%%%%
for i = 1 :  Np
    dA(i,1) = dS(i,2)*dS(i,3);
    dA(i,2) = dS(i,1)*dS(i,3);
    dA(i,3) = dS(i,2)*dS(i,1);
    
    ddA(Np+1-i,1) = ddS(Np+1-i,2)*ddS(Np+1-i,3);
    ddA(Np+1-i,2) = ddS(Np+1-i,1)*ddS(Np+1-i,3);
    ddA(Np+1-i,3) = ddS(Np+1-i,2)*ddS(Np+1-i,1);
end

end
