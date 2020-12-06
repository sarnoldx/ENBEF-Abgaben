
## Author: simon <simon@LAPTOP-RFMQ4V4B>
## Created: 2020-12-05

function val = sumUp (A,x,i)
  %j = i + 1;
  n = size(A);
  val = 0;
  
  for j = i+1:n
    val = val + A(i,j)*x(j);
  end
  
endfunction
