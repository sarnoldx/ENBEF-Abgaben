
## Author: Lingenberg, Schiller, Arnold
## Created: 2020-11-20

function [M,K,r] = calculate_matrices(filename)
  
  
  [AC,AL,AR,AV,AI,C,L,R,V,I] = circuit_matrices(filename);
  bl = size(L,1);
  bv = size(V,1);
  n = size(AR,1);
  
  M = [AC*C*AC' zeros(n,bl) zeros(n,bv);
       zeros(bl,n) L zeros(bl,bv);
       zeros(bv,n) zeros(bv,bl) zeros(bv,bv)]
  
  K = [AR*R*AR' AL AV;
       -AL' zeros(bl,bl) zeros(bl,bv);
       -AV' zeros(bv,bl) zeros(bv,bv)]
       
  r = [-AI*I; zeros(bl,1); -V]
  
endfunction
