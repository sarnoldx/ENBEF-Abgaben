h = 1e-1;
t = 0:h:5;
k = 1/5;
xana =@(t) (2*exp(-k*t));
% function x =  odebwe_simple(t,x0,M,K,r)
xnum = odebwe_simple(t,2,1,k,0);
plot(t,xana(t),t,xnum,'+');
legend('analytisch','numerisch');
xlabel('t-Achse');
ylabel('x-Achse');

