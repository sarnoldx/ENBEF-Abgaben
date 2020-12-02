t = [0:1e-8:2e-3];

% Bestimmung des Gleichungssystems:
[M,K,r] = calculate_matrices('koaxialKabel.net');

%r(5) (Spannungsquelle) wird wohl mit falschem Vorzeichen berechnet
r(5) = -r(5);

%res = @(y, yd,t) (M*yd+K*y-r);
res =@(x,xdot,t)(M*xdot+K*x-r);

% Bestimmung der Anfangswerte:
U_q = 12;
L1 = 0.00025;
R1 = 0.001;
C1 = 0.0000001;
R2 = 1500;
Rf = 1500;

% x0:
% phi_1 = 12
% phi_2 = 12
% phi_3 = 0
% i_L   = 0
% i_V   = 0
x0 = zeros(size(r));
x0(1) = U_q;
x0(2) = U_q

% x0_Strich: 
x0_Strich = zeros(size(r));

% Nummerische Berechnung des Gleichungssystems:
% x = dassl(res, transpose(x0), zeros(size(r)), t);
x1 = daspk(res,x0,x0_Strich,t);


%-----------------------------------------------
% Bestimmung des Gleichungssystems mit 10 Segmenten:
%-----------------------------------------------
[M10,K10,r10] = calculate_matrices('KK10.net');

%Spannungsquelle wird wohl mit falschem Vorzeichen berechnet
r10 = -r10;

%res = @(y, yd,t) (M*yd+K*y-r);
res10 =@(x,xdot,t)(M10*xdot+K10*x-r10);

% Bestimmung der Anfangswerte:
U_q = 12;
L1 = 0.00025;
R1 = 0.001;
C1 = 0.0000001;
R2 = 1500;
Rf = 1500;

% x0:
% phi_1 = 12
% phi_2 = 12
% phi_3 = 0
% i_L   = 0
% i_V   = 0
x0_10 = zeros(size(r10));
x0_10(1) = U_q;
x0_10(2) = U_q

% x0_Strich: 
x0_10_Strich = zeros(size(r10))

% Nummerische Berechnung des Gleichungssystems:
% x = dassl(res, transpose(x0), zeros(size(r)), t);
x10 = daspk(res10,x0_10,x0_10_Strich,t);

%----------------------------------------------------
% Erstellen des Plots:
plot(t,x1(:,3:3));
hold on;
plot(t,x10(:,21:21));
hold off;
xlabel('Zeit t in [s]', 'interpreter', 'tex')
ylabel('Spannung in [V]', 'interpreter', 'tex')
legend('Ausgangsspannung bei n=1', 'Ausgangsspannung bei n=10')
