R = 1:1:100;
%C = zeros(1,100);
##for i = 1 : 100
##  C(1,i) = spherecapacity(R(1,i),1);
##endfor
plot(R,C,'linewidth',3);
axis([1 100]);
xlabel('Innenradius in cm','Fontsize',26);
ylabel('Kapazitaet in F','Fontsize',26);
set(gca,'Fontsize',26);

##Yticks = get(gca,'Ytick');
##YTickLabels = cellstr(num2str(round(log10(Yticks(:))), '10^%d'));
##set(gca,'YTickLabel',YTickLabels);

ytick=get(gca,'ytick');
yticklab = [
"0";
strcat('0.5 \cdot ',num2str(9,'10^-^%d'));
strcat('1 \cdot ',(num2str(9,'10^-^%d')));
strcat('1.5 \cdot',(num2str(9,'10^-^%d')));
strcat('2 \cdot',(num2str(9,'10^-^%d')))];
yticklab = cellstr(yticklab);
%yticklab = cellstr(num2str(round(-log10(ytick(:))), '10^-^%d'));
set(gca,'YTick',ytick,'YTickLabel',yticklab,'TickLabelInterpreter','tex');

print -deps testplot.eps;