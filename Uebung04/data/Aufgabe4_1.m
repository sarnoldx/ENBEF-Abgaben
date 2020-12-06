h = [10e-11,10e-10,10e-9,10e-8,10e-7,10e-6,10e-5,10e-4,10e-3,10e-2,10e-1];
err1 = zeros(1,11);
err2 = zeros(1,11)
err4 = zeros(1,11)
f = @(x) x
for i = 1 : 11
  err1(1,i) = abs(12-diffquot(f,1,1,h(1,i)));
  err2(1,i) = abs(12-diffquot(f,2,1,h(1,i)));
  err4(1,i) = abs(12-diffquot(f,4,1,h(1,i)));
endfor

loglog(h,err1,'Linewidth',2,h,err2,'Linewidth',2,h,err4,'Linewidth',2);
l = legend('Differenzenquotient 1. Ordnung','Differenzenquotient 2. Ordnung','Differenzenquotient 4. Ordnung',"location", "northwest");
set(l,'Fontsize',22,'color','none');
legend boxoff;
xlabel('Schrittweite h','fontsize',22)
ylabel('Absoluter Fehler','fontsize',22)
set(gca,'Fontsize',20);