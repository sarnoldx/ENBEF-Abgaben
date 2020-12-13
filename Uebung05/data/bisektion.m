function x = bisektion(f, a, b, maxn)
  if(sign(f(a))*sign(f(b)) != -1)
    %Error
    x = -24324;
    return;
  else
     c = (a+b)/2;
     for n = 1:maxn
          c = (a+b)/2;
          if(f(c) == 0)
             x = c;
             return;
          end
          if(sign(f(a))*sign(f(c)) == -1)
              b = c;
          else
              a = c;
          end
     end
      x = c;
    end
end