x = 100:1:1000000;
R = 100;
L = 0.001;
t = 1
y = R .* (R .* cos(2.*pi .* x .* t) + 2.*pi .* L .* x .* sin(2.*pi .* x .* t))./(R^2 + ( L .*2.*pi .* x ).^2);

fileID = fopen('datavonltspice.txt','r');

fileData = fscanf(fileID,'%f %f');
x_data = fileData(1:2:size(fileData,1));
y_data = fileData(2:2:size(fileData,1));

fclose(fileID);


figure;
loglog(x,y);
%loglog(x_data,y_data);
set(gca,'fontsize',20)
xlabel 'Frequenz in Hz';
ylabel ({'Verhältnis', 'Eingangsspannung zu' 'Ausgangsspannung in dB'});
%saveas(gcf,'Plotalsbitmap.jpg')


