function val = diffquot(f,i,x,h)
  val = 0;
  switch (i)
    case 1
      val = (f(x+h)-f(x))/h;
    case 2  
      val = (f(x+h)-f(x-h))/(2*h);
    case 4 
      val = (f(x+h)-f(x-h)+2*f(x+h/2)-2*f(x-h/2))/(4*h);
  endswitch
  
endfunction
