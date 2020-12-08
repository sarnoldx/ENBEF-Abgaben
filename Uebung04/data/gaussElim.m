function [x] = gaussElim (A,b)
  n = size(A)
  x = zeros(n,1)
  for j=1:n-1
    for i = j+1:n 
      l = A(i,j) / A(j,j);
      for k = j:n
        A(i,k) = A(i,k)  - l * A(j,k);
      endfor
    b(i) = b(i) - l*b(j);
    endfor
  endfor
  
  for i = n:-1:1
    f = @(k) A(i,k) * x(k);
    x(i)= (1/A(i,i))*(b(i)-sum(f([i+1:n])));
  endfor
  
endfunction
