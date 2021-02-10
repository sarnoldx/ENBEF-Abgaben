function x = fixpunkt_iteration(A,b,maxIter)
  % Loest die Gleichung A(x)x = b
  L = length(b);
  % Startwert x0=1
  x0 = ones(L,1);
  % x1 mit beliebigen Wert fuer den while Bedingung erfuellt ist
  x1 = x0;
  i = 0;
  while(((norm(x1-x0)/norm(x1)) > 10^(-6) || i == 0) && i <= maxIter)
    x0 = x1;
    x1 = A(x0)\b;
    i = i+1;
  endwhile
  if (i>=maxIter)
    disp('fixpunkt_iteration konnte die Gleichung mit gegebener Anzahl an Iterationsschritten nicht loesen')
  endif
  x = x1;
endfunction
