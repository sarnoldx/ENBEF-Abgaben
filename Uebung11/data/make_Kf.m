function [K,f] = make_Kf(x,a,b)
  % Dimension von x muss eins groesser sein als von a,b
  dim = length(x);
  % ci ist die Konstante vor Matrix Ki
  % di ist die Konstante vor Vektor fi
  for i = 1:(dim-1)
    ci(i,1) = a(i)/(x(i+1)-x(i));
    di(i,1) = 1/2*b(i)*(x(i+1)-x(i));
  endfor
  K = zeros(dim,dim);
  f = zeros(dim,1);
  for i = 1:(dim-1);
    Ki = [1,-1;-1,1];
    Ki = ci(i)*Ki;
    % 2x2 Matrix Ki in grosse Matrix K übertragen
    K(i,i) = K(i,i) + Ki(1,1);
    K(i+1,i) = Ki(2,1);
    K(i,i+1) = Ki(1,2);
    K(i+1,i+1) = Ki(2,2);
    % Werte in k eintragen
    f(i) = f(i) + di(i);
    f(i+1) = di(i);
  endfor
endfunction
