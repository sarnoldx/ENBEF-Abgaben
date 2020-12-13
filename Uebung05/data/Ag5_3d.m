C = 5*10^(-12);
f = @(R1) ((spherecapacity(R1, 1) - C));
a=1;
b=10;
maxn = 20;
x = bisektion(f, a, b, maxn)
l = f(3.1130)
