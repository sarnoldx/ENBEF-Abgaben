t = [0:1e-8:1e-3];

x0 = zeros(5,1);
x0(1) = 12;
x0(2) = 12;

M = zeros(5,5);
M(3,3) = 1e-7; 
M(4,4) = 25e-5;

K = [1000 -1000 0 0 1; -1000 1000 0 1 0; 0 0 1/750 -1 0; 0 -1 1 0 0; -1  0 0 0 0];

r = zeros(5,1);
r(5) = -12;

% Funktion ist deutlich langsamer als die zuvor verwendeten Methoden
x = odebwe_simple(t,x0,M,K,r);

plot(t,x(3,:));
xlabel('Zeit t in [s]', 'interpreter', 'tex')
ylabel('Spannung in [V]', 'interpreter', 'tex')
legend('3. Zeile der Lösungsmatrix x')

