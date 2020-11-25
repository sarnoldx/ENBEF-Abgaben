t = [0:1e-8:1e-3];

% Bestimmung des Gleichungssystems:
[M,K,r] = calculate_matrices('koaxialKabel.net');

% !!!!! r(5) (Spannungsquelle) wird wohl mit falschem Vorzeichen berechnet
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
% phi_1' = 0
% phi_2' = -48
% phi_3' = 0
% i_L'   = 48000
% i_V'   = -48000
x0_Strich = zeros(size(r));
x0_Strich(2) = -R1*U_q/L1;
x0_Strich(4) = 0;
x0_Strich(5) = -U_q/L1


% Nummerische Berechnung des Gleichungssystems:
% x = dassl(res, transpose(x0), zeros(size(r)), t);
x = dassl(res,x0,x0_Strich,t);

% Erstellen des Plots:
plot(t,x(:,1:5));
xlabel('Zeit t in [s]', 'interpreter', 'tex')
ylabel('Strom in [A], Spannung in [V]', 'interpreter', 'tex')
legend('\phi_1', '\phi_2', '\phi_3', 'i_L', 'i_V')
