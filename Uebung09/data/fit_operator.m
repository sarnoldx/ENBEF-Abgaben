function [C,S,Ss] = fit_operator(Nx,Ny,Nz)
Mx = 1;
My = Nx;
Mz = Ny * Nx;
Np = Nx * Ny * Nz;

Px = sparse(Np,Np);
Py = sparse(Np,Np);
Pz = sparse(Np,Np);

for p = 1 : Np
    for q = 1 : Np
        if (q==p)
            Px(p,q) = -1;
            Py(p,q) = -1;
            Pz(p,q) = -1;
        end
         if (q==p+Mx)
             Px(p,q) = 1;
         end
         if (q==p+My)
             Py(p,q) = 1;
         end
         if (q==p+Mz)
             Pz(p,q) = 1;
         end
    end
end

C = [sparse(Np,Np) -Pz Py; Pz sparse(Np,Np) -Px; -Py Px sparse(Np,Np)];
C = sparse(C);
S = [Px Py Pz];
S = sparse(S);
Ss = [-Px' -Py' -Pz'];
Ss = sparse(Ss);


