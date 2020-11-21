t = [0:1e-5:0.003];

% Bestimmung des Gleichungssystems:
[M,K,r] = calculate_matrices('oszilator2.1.net');
res = @(y, yd,t) (M*yd+K*y-r);

% Bestimmung der Anfangswerte:

% x0:
% phi_1 = 0
% phi_2 = 12
% i_L   = 0
U_c = 12;
L = 0.00173007;
R = 2;
x0 = zeros(size(r));
x0(2) = U_c

% x0_Strich: 
% phi_1' = 13872,27
% phi_2' = 0
% i_L'   = -6936,16
x0_Strich = zeros(size(r));
x0_Strich(1) = R*U_c/L;
x0_Strich(3) = -U_c/L

% Nummerische Berechnung des Gleichungssystems:
x = dassl(res, transpose(x0), zeros(size(r)), t);
plot(t,x(:,1:3));