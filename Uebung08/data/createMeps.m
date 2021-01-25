function [ meps ] = createMeps(xmesh,ymesh,zmesh,eps_r)
	mesh = cartMesh(xmesh, ymesh, zmesh);
	[DS, DSt] = createDS (mesh);
	DA = createDA (DS);
	DAt = createDA (DSt);
	eps_r = repmat(eps_r(:),1,3);
	Deps = createDeps(mesh, DA, DAt, eps_r);
	meps = DAt*Deps*nullInv(DS);
end

function [ Deps ] = createDeps( mesh, DA, DAt, eps_r )
	Mx = mesh.Mx;My = mesh.My;Mz = mesh.Mz;np = mesh.np;
	eps0 = 8.854187817*10^-12;
	eps = eps0 * eps_r;
	At = diag(DAt);
	A  = diag(DA);
	Atx = At(1:np);
	Aty = At(np+1:2*np);
	Atz = At(2*np+1:3*np);
	Ax = A(1:np);
	Ay = A(np+1:2*np);
	Az = A(2*np+1:3*np);
	meanEpsX = zeros(1, np);
	meanEpsY = zeros(1, np);
	meanEpsZ = zeros(1, np);
	for n = 1:np
		temp = eps(n,1)*Ax(n); 
		if n - My - Mz > 0
				temp = temp + eps(n-My-Mz,1)*Ax(n-My-Mz);
		end;
		if n - Mz > 0
				temp = temp + eps(n-Mz,1)*Ax(n-Mz); 
		end;
		if n - My > 0
				temp = temp + eps(n-My,1)*Ax(n-My); 
		end;
		meanEpsX(n) =  temp / (4*Atx(n));
	
		temp = eps(n,2)*Ay(n); 
		if n - Mx - Mz > 0
				temp = temp + eps(n-Mx-Mz,2)*Ay(n-Mx-Mz); 
		end;
		if n - Mz > 0
				temp = temp + eps(n-Mz,2)*Ay(n-Mz); 
		end;
		if n - Mx > 0
				temp = temp + eps(n-Mx,2)*Ay(n-Mx); 
		end;
		meanEpsY(n) =  temp / (4*Aty(n));
	
		temp = eps(n,3)*Az(n); 
		if n - My - Mx > 0
				temp = temp + eps(n-My-Mx,3)*Az(n-My-Mx); 
		end;
		if n - Mx > 0
				temp = temp + eps(n-Mx,3)*Az(n-Mx); 
		end;
		if n - My > 0
				temp = temp + eps(n-My,3)*Az(n-My); 
		end;
		meanEpsZ(n) =  temp / (4*Atz(n));
	end
	Deps = spdiags([meanEpsX, meanEpsY, meanEpsZ]', 0, 3*np, 3*np);
end

function [ DA ] = createDA( DS )
	np = length(DS)/3;
	DSdiag = diag(DS);
	DSx = DSdiag(1:np);
	DSy = DSdiag(np+1:2*np);
	DSz = DSdiag(2*np+1:3*np);
	Ax = DSz .* DSy;
	Ay = DSz .* DSx;
	Az = DSy .* DSx;
	DA = spdiags( [Ax; Ay; Az], 0, 3*np, 3*np);
end

function [ DS, DSt ] = createDS( mesh )
	nx = mesh.nx;
	ny = mesh.ny;
	nz = mesh.nz;
	np = mesh.np;
	dx = [diff(mesh.xmesh) 0];
	dy = [diff(mesh.ymesh) 0];
	dz = [diff(mesh.zmesh) 0];
	DSdiag = [repmat(dx, 1, ny*nz), ...
			repmat(reshape(repmat(dy, nx, 1), 1, nx*ny), 1, nz),...
			reshape(repmat(dz, nx*ny, 1), 1, np)];
	DS = spdiags(DSdiag',0,3*np,3*np);
	dxt = diff(mesh.xmesh);
	dxt = [dxt dxt(nx-1)/2]; 
	dxt(1) = dxt(1)/2;
	dyt = diff(mesh.ymesh);
	dyt = [dyt dyt(ny-1)/2];
	dyt(1) = dyt(1)/2;
	dzt = diff(mesh.zmesh);
	dzt = [dzt dzt(nz-1)/2];
	dzt(1) = dzt(1)/2;
	DStdiag = [repmat(dxt, 1, ny*nz), ...
			repmat(reshape(repmat(dyt, nx, 1), 1, nx*ny), 1, nz),...
			reshape(repmat(dzt, nx*ny, 1), 1, np)];
	DSt = spdiags(DStdiag',0,3*np,3*np);
end

function A = nullInv(A)
	[indm, indn, values] = find(A);
	A = sparse(indm, indn, 1./values, size(A,1), size(A,2));
end

function [ mesh ] = cartMesh( xmesh, ymesh, zmesh )
	nx = length(xmesh);
	ny = length(ymesh);
	nz = length(zmesh);
	np = nx*ny*nz;
	mesh.Mx = 1;
	mesh.My = nx;
	mesh.Mz = nx*ny;
		points = zeros(np, 3);
		for z=1:nz
			for y=1:ny
				for x=1:nx
					n = 1+(x-1)*mesh.Mx+(y-1)*mesh.My+(z - 1)* mesh.Mz;
					points(n,:)=[xmesh(x),ymesh(y),zmesh(z)];
				end
			end
		end
	mesh.points = points;
	mesh.nx = nx;
	mesh.ny = ny;
	mesh.nz = nz;
	mesh.np = np;
	mesh.xmesh = xmesh;
	mesh.ymesh = ymesh;
	mesh.zmesh = zmesh;
end
