## Author: simon <simon@LAPTOP-RFMQ4V4B>
## Created: 2020-12-06

function val = diffquot(f,i, x, h)
  val = 0;
  switch (i)
    case 1
      val = (abFkt(x+h)-abFkt(x))/h;
    case 2  
      val = (abFkt(x+h)-abFkt(x-h))/(2*h);
    case 4 
      val = (abFkt(x+h)-abFkt(x-h)+2*abFkt(x+h/2)-2*abFkt(x-h/2))/(4*h);
  endswitch
  
endfunction
