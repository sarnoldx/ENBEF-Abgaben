clear;
Nx = 2;
Ny = 9;
Nz = 9;
Np = Nx*Ny*Nz;

xmesh = [0:20:20];
ymesh = [0:5:40];
zmesh = [0:2.5:20];

nx = sparse(Np,1);
ny = sparse(Np,1);
nz = sparse(Np,1);

indxOmega1 = sparse(3*Np,1);
indxOmega2 = sparse(3*Np,1);
stepY = calc_steps(Ny,40);
stepZ = calc_steps(Nz,20);
h = calc_steps(Nx,20);


n = 1;
for z = 1 : Nz
    for y = 1 : Ny
        for x = 1 : Nx
            if (z*stepZ >= 7.5 && z*stepZ <= 12.5)
                if (y*stepY >= 10 && y*stepY <= 15)
                    indxOmega1(n) = 1;
                end
                if (y*stepY >= 25 && y*stepY <= 30)
                    indxOmega2(n) = -1;
                end
                
            end
            if (x < Nx) && ((y == 1) || (y == Ny) || (z == 1) || (z == Nz))  
                nx(n) = 1;
            end

            if (y < Ny) && ((x == 1) || (x == Nx) || (z == 1) || (z == Nz))  
                ny(n) = 1;
            end
            
            if (z < Nz) && ((x == 1) || (x == Nx) || (y == 1) || (y == Ny))  
                nz(n) = 1;
            end
            
            n = n+1;
        end
    end
end

indxT = [nx;ny;nz];

j = (h/5)^2*(indxOmega1+indxOmega2);
j = sparse(j);

Mny = createMny(xmesh,ymesh,zmesh,ones(Np,1));
[C,S,Ss] = fit_operator(Nx,Ny,Nz);
K = C'*Mny*C;

%Loesche Rand raus
l = 0;
for i=length(indxT):-1:1
  if indxT(i) == 1
    K(i,:)=[];
    K(:,i)=[];
    j(i,:)=[];
    l = l+1;
  end
end

a = K\j;

%Fuege Rand wieder hinzu
a1 = sparse(length(indxT),1);
counter = 1;
for i=1:length(indxT)
  if indxT(i) == 0
    a1(i) = a(counter);
    counter = counter +1;
  end
end

b = C*a1;

fit_write_vtk(xmesh, ymesh, zmesh, 'harry.vtr', {'j',j;'b',b})




