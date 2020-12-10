%C = zeros(1,20);

%for i=1:20
%  C(1,i)= femmcapacity(30, 30, 1, 2, i);
%endfor

N = 1:1:20;

semilogy(N,C,'linewidth',3);

xlabel('Anzahl Schichten','fontsize',26);
ylabel('Kapazität in F','fontsize',26);
set(gca,'Fontsize',26);
axis([1 20]);
