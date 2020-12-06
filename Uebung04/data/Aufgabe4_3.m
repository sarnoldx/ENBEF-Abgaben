load('bfwa398.mat');
%A = Problem.A;
%spy(A);
%c = nnz(A);
%b = ones(size(A),1);

%A1 = inv(A)
%spy(A1)

%A1*b

%gaussElim(A,b)


%[L,U,P,Q] = lu(A);
%spy(R)
%spy(U)

rand('seed',0)
##e = ones (n , 1 );
##A = spdiags ( [ e -2*e e ] , [-10 0 10] , n , n ) ;
%spy(A)
time1 = zeros(10,5);
%b = rand(n,1)
k=0;
##[L,U,P,Q] = lu(A);
n = 500;

##while (n < 8001)
##  k = k + 1;
##  e = ones (n , 1 );
##  A = spdiags ( [ e -2*e e ] , [-10 0 10] , n , n ) ;
##  
##  for i = 1:10
##    b = rand(n,1);
##    tic();
##    [L,U,P,Q] = lu(A);
##    Q*(U\(L\(P*b)));
##    time1(i,k) = toc();
##  end
##  n = n * 2;
##end
##
##InverseTime = zeros(1,5);
##LUPQTime = zeros(1,5);
##BackslashTime = zeros(1,5);
##
##for i = 1:5
##  InverseTime(1,i) = sum(time(:,i))/10;
##  LUPQTime(1,i) = sum(time1(:,i))/10;
##  BackslashTime(1,i) = sum(time2(:,i))/10;
##end

x = [500,1000,2000,4000,8000];


loglog(x,BackslashTime,'LineWidth',2,x,LUPQTime,'LineWidth',2,x,InverseTime,'LineWidth',2);
axis([500 8000]);
h = legend('Backslash-Operator Rechnung','LUPQ-Zerlegung Rechnung','Inverse Matrix Rechnung',"location", "northwest");
set(h,'Fontsize',22,'color','none');
legend boxoff;


xlabel('Anzahl der Zeilen der quadratischen Matrix','FontSize',22);
ylabel('Rechenzeit in Sekunden','FontSize',22);
