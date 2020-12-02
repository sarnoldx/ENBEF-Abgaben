t = [0:1e-8:1e-3];

% Bestimmung des Gleichungssystems:
[M,K,r] = calculate_matrices('koaxialKabel.net');

% r(5) (Spannungsquelle) wird wohl mit falschem Vorzeichen berechnet, diese Korrektur führt nun zum richtigen Ergebnis
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
x = daspk(res,x0,x0_Strich,t);

% Erstellen des Plots:
plot(t,x(:,3:3));
xlabel('Zeit t in [s]', 'interpreter', 'tex')
ylabel('Spannung in [V]', 'interpreter', 'tex')
legend('\phi_3 entspricht Spannung an Rf')
