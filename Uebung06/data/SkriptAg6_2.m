%  A = zeros(3601,60);
%    B = zeros(3601,20);
%    R = zeros(3601,1);
%     counter = 1;
% %   
%    for i = 0.1  : -0.001 : 0.08
%      R = Aufgabe6_2a(1200,4800,i);
%      for j = 1 : 1 : 3601
%        B(j,counter) = R(j,1);
%      end
%      counter = counter + 1;
%     end
% 
% plot(A(:,1));
% title('Combine Plots');
% 
% hold on
% 
% for i = 1 : 64
%   plot(A(:,i));
% endfor
% 
% %axis([3400 3500]);
% xlabel("Hoehe des Messpunktes in mm","Fontsize",24);
% ylabel("Staerke des elektrostatischen Felds in V/m","Fontsize",24);
% hold off
% 
% 
% %R = Aufgabe6_2a(1200,4800,4);
% 
% hold on
% 
% plot(A(:,60));
% plot(R);
% 
% legend("Feld ohne Randbedingung","Feld mit Randbedingung Potential 0V");
% h = legend('Feld ohne Randbedingung','Feld mit Randbedingung', "location", "northwest");
% set(h,'Fontsize',20,'color','none');
% legend boxoff;
% xlabel("Hoehe des Messpunktes in mm","Fontsize",18);
% ylabel("Staerke des elektrostatischen Felds in V/m","Fontsize",18);
% set(gca,"fontsize",18);
% hold off

% for d = 600 : 25 : 2000
%   R = Aufgabe6_2a(d,4800,1000);
%   for j = 1 : 1 : 3601
%     A(j,counter) = R(j,1);
%   endfor
%    counter += 1; 
% endfor

A = dlmread('C:\Users\simon\OneDrive\Desktop\Uni\ENBEF\Git\ENBEF Abgaben\Uebung06\data\A60.txt');
surf(600:25:2000,2000:5600,A(:,1:57));
% hold on
% plot(C(2600,:))
% hold off
ylabel("Hoehe des Messpunktes","Fontsize",20);
zlabel("Staerke des elektrischen Felds in V/m","Fontsize",20);
%l = legend('Elektrisches Feld ohne Randbedinung','Elektrisches Feld mit Randbedingung',"location", "northwest");
%set(l,'Fontsize',18,'color','none');
%set(gca,'Fontsize',18);

%legend boxoff;
xlabel("Aussendurchmesser des Rings in mm","Fontsize",20);
