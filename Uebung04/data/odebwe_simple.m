## Author: Lingenberg, Schiller, Arnold
## Created: 2020-12-20

function x =  odebwe_simple(t,x0,M,K,r)
% initialize solution vector
x = zeros(length(x0),length(t));
x(:,1) = x0;

for i = 2:length(t)
  % time step size
  h = t(i) - t(i-1);
  % system matrix
  A = (1/h)*M + K;
  % right hand side
  b = (1/h)*M*x(:,i-1)+r;
  % solve the linear system Ax=b
  x(:,i) = A\b;
end
x
endfunction
