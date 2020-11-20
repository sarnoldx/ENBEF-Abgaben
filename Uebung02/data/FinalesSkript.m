t = [0:1e-5:0.003];
[M,K,r] = calculate_matrices('Aufgabe2.2b.net');
res = @(y, yd,t) (M*yd+K*y-r);

x0 = zeros(size(r));
x0(2) = 12

x = dassl(res, transpose(x0), zeros(size(r)), t);
plot(t,x(:,1:3));