function [ddS,dS,ddA,dA] = fit_calc_elements(xmesh,ymesh,zmesh)
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


stepx = calc_steps(Nx,xmesh(1,Nx)-xmesh(1,1));
stepy = calc_steps(Ny,ymesh(1,Ny)-ymesh(1,1));
stepz = calc_steps(Nz,zmesh(1,Nz)-zmesh(1,1));

dA = sparse(Np,3);
ddA = sparse(Np,3);
dS = sparse(Np,3);
ddS = sparse(Np,3);

dx = sparse(Np,1);
dy = sparse(Np,1);
dz = sparse(Np,1);

%%%%% Berechnung dS und ddS %%%%%
n = 1;

for nz = 1 : Nz
    for ny = 1 : Ny
        for nx = 1 : Nx
            if nx < Nx
                dx(n) = stepx;
            end
            if ny < Ny
                dy(n) = stepy;
            end
            if nz < Nz
                dz(n) = stepz;
            end
            n = n+1;
        end
    end
end

dS = [dx dy dz];

ddx = sparse(Np,1);
ddy = sparse(Np,1);
ddz = sparse(Np,1);

z = 1;
for i = 1 : Np
    
    if (i <= Nx*Ny*z-Nx) && (z < Nz)
        if mod(i,Nx) == 0  
            ddx(i) = dx(i-1)/2;
        elseif mod(i,Nx) == 1 
            ddx(i) = dx(i)/2;
        else
            ddx(i) = dx(i)/2+dx(i-Mx)/2;
        end
    end
    
    if (z < Nz)
        if i < Nx*z
            ddy(i) = dy(i)/2;
        elseif (i < Nx*Ny*z) && (i > (Nx*Ny*z-Nx)) 
            ddy(i) = dy(i-My)/2;
        elseif mod(i,Nx) == 0
            ddy(i) = 0;
        else
            ddy(i) = dy(i)/2+dy(i-My)/2;
        end
    end
    
    if (z <= Nz)
        if (mod(i,Nx) ~= 0) && (i < Nx*(Ny-1))
            ddz(i) = dz(i)/2;
        elseif (mod(i,Nx) ~= 0) && (i < Nx*Ny*z-Nx) && (z < Nz)
            ddz(i) = dz(i)/2+dz(i-Mz)/2;
        elseif (mod(i,Nx) ~= 0) && (i < Nx*Ny*z-Nx)
            ddz(i) = dz(i-Mz)/2;
        else
            ddz(i) = 0;
        end
    end
    
    if mod(i,Nx*Ny) == 0
        z = z+1;
    end
    
end

ddS = [ddx ddy ddz];


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
