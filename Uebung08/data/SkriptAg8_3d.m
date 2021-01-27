%result = zeros(150,1);
counter = 1;
%for i = 0:100:15000
  %  result(counter,1) = SIS(i);
 %   counter = counter + 1;
%end  
plot(result);
ylabel('Induktivitaet in H');
xlabel('Strom in A');
xtick=get(gca,'xtick');
xTickLabels = cellstr(num2str(100*xtick(:)));
set(gca,'fontsize' ,20,'XTick',xtick,'XTickLabel',xTickLabels);