C = 5*10^(-12);
f = @(R1) ((spherecapacity(R1, 1) - C));
a=0.1;
b=1000;
maxn = 8;
x = bisektion(f, a, b, maxn)
fehler = f(x)
