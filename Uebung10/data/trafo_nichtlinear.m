% lese Eingabedaten
load trafo_nichtlinear.mat;

% Gittertopologie
xmesh = prb.xmesh;
ymesh = prb.ymesh;
zmesh = prb.zmesh;
nx = length(xmesh);
ny = length(ymesh); 
nz = length(zmesh);
Np = nx*ny*nz;
material = prb.Elem;

% Gitterabmessungen und Indizes
ddA     = prb.ddA;           % duale Flaecheninhalte
dA      = prb.dA;            % primale Flaecheninhalte
ds      = prb.ds;            % primale Kantenlaengen
idxV    = prb.idxV;          % Indizes der primalen Volumina im Rechengebiet 
idxA    = prb.idxA;          % Indizes der primalen Flaechen im Rechengebiet 
idxs    = prb.idxs;          % Indizes der primalen Kanten im Rechengebiet 
idxdof  = prb.idxdof;        % Indizes der Freiheitsgrade 
idxiron = find(material==6); % Indizes fuer Eisen

% Operatoren
C = prb.C;       % Curl-Matrix

% Anregungsvektor mit 10A Strom pro Spule
jsrc  = prb.Qstr*[1;1];
jdof  = jsrc(idxdof);
 
% Reluktivitaet 
mu0 = 4*pi*10^-7;
murE = 1000;
nu  = ones(Np,1)/mu0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Linear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Loese lineares Problem
nu(idxiron) = 1/(mu0*murE); 
Mnu         = spdiags(nu,0,3*np,3*np);
K           = C'*Mnu*C;
Kdof        = K(idxdof);
Zdof        = sparse(1:size(Kdof,1),1:size(Kdof,2),sqrt(diag(Kdof)));
a           = zeros(3*Np,1);
a(idxdof)   = pcg(Kdof,jdof,1e-7,1000,Zdof,Zdof);

% berechne magnetische Flusse im Volumen
b           = ...;
B           = zeros(3*Np,1);
B(idxA)     = b(idxA)./dA(idxA);
Bc          = fit_pf2pc(xmesh,ymesh,zmesh,B,idxV);

% Ausgabe
fit_write_vtk(xmesh,ymesh,zmesh,['trafo_iter' num2str(0) '.vtr'],{},{'Flussdichte',Bc(idxV,:);'Material',material(idxV)})

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Nichtlinear 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Parameter fuer Brauer's Kurve
k1  = 0.3774;
k2  = 2.970; 
k3  = 388.33;

% Startwerte fuer die Fixpunktiteration 
aold = zeros(3*Np,1);
a    = zeros(3*Np,1);
i    = 0;

% Fixpunkt iteration
while (i<2) | ...
	
	% update der Variablen
	aold=a;
	i=...;
	fprintf('Iteration %d\n',i);
	
	% berechne magnetische Flusse im Volumen
	b       = ...;
	B       = zeros(3*Np,1);
	B(idxA) = b(idxA)./dA(idxA);
	Bc      = fit_pf2pc(xmesh,ymesh,zmesh,B,idxV);
	
	% Auswertung der Materialkurve
	Biron   = sqrt(sum( Bc(idxiron,:).^2, 2) );
	nu(idxiron) = ...;
	
	% Update der Materialmatrix
	Mnu = createMnu(...);

	% create and shrink curl-curl matrix
	K = ...;
	Kdof = K(...);

	% loese GLS
	Zdof = sparse(1:size(Kdof,1),1:size(Kdof,2),sqrt(diag(Kdof)));
	a(idxdof) = pcg(Kdof,jdof,1e-7,1000,Zdof,Zdof,a(idxdof));

	% Ausgabe
	fit_write_vtk(xmesh,ymesh,zmesh,['trafo_iter' num2str(i) '.vtr'],{},{'Flussdichte',Bc(idxV,:);'Material',material(idxV)})

end


