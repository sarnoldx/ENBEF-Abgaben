x = 100:0.01:1000000;
R = 100;
L = 0.001;
t = 1
y = R * (R * cos(2*pi * x * t) + 2*pi * L * x * sin(2*pi * x * t))/(R^2 + ( L *2*pi * x )^2);

figure;
plot(x,y);