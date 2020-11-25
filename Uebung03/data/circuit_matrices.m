## Author: Lingenberg, Schiller, Arnold
## Created: 2020-11-20

function [AC,AL,AR,AV,AI,C,L,R,V,I] = circuit_matrices(filename)
% PEMCE Uebung 2: Routine um Schaltunsmatrizen zu erzeugen:
%  [AC,AL,AR,AV,AI,C,L,R,V,I] = circuit_matrices(filename)
%
% Eingabe:
%  filename  - Dateiname der Netzliste
%
% Ausgaben:
%  AC,...,AI - reduzierte Inzidenzmatrizen fuer Kapazitaten, ..., Stromquellen
%  C,...,I   - Matrizen der Parameter (Kapazitaten, ..., Stromquellen)

  %# lese Schaltung aus netzliste
  cirstruct = prs_spice (filename);

  %# initialisiere variablen
  n = cirstruct.totextvar;
  AC=AL=AR=AV=AI=sparse(n,0);
  C=L=R = zeros(0,0);
  V=I= zeros(0,1);

  % Durchlaufe alle Elementtypen (R,L,C,...)
  for i=1:size(cirstruct.LCR,2)
    typ=cirstruct.LCR(i).parnames{1,1};
    sz=size(cirstruct.LCR(i).pvmatrix,1);
    
    % Durchlaufe alle Bauteile eines Typen
    for j=1:size(cirstruct.LCR(i).pvmatrix,1)
      val=cirstruct.LCR(i).pvmatrix(j,:);
      pins=cirstruct.LCR(i).vnmatrix(j,:);
      
      if typ == 'L'
        matrix = AL;
        diagonal = L;
      endif 
      if typ == 'R'
        matrix = AR;
        diagonal = R;
      endif 
      if typ == 'C'
        matrix = AC;
        diagonal = C;
      endif 
      if typ == 'V'
        matrix = AV;
        diagonal = V;
      endif  
      if typ == 'I'
        matrix = AI;
        diagonal = I;  
      endif
      
      is_voltage_or_current = typ == 'V' || typ == 'I';
      
      matrix = [matrix,sparse(n,1)]
      %Diagonalmatrix Elemente einf�gen
      
      if is_voltage_or_current == false
        diagonal = [diagonal,zeros(sz,1)];
        
        if typ == 'R'
          val = 1/val;
        endif
        
        diagonal(j,j) = val;
      endif
            
      %Richtung des Stroms bestimmen
      direction = pins(1) - pins(2);
      
      %Strom flie�t von 1 nach 2
      if direction < 0
        %Nur hinzuf�gen wenn es sich nicht um den Masseknoten handelt
        if pins(1) != 0
          matrix(pins(1),j)=1;
        endif
        matrix(pins(2),j)=-1;
        
        if is_voltage_or_current == true
          diagonal = [diagonal;val];
        endif
        
      %Strom flie�t von 2 nach 1
      else
        matrix(pins(1),j)=1;
        %Nur hinzuf�gen wenn es sich nicht um den Masseknoten handelt
        if pins(2) != 0
          matrix(pins(2),j)=-1;
        endif
        
        if is_voltage_or_current == true
          diagonal = [diagonal;-val];
        endif
      endif
      
      if typ == 'L'
        AL = matrix;
        L = diagonal;
      endif 
      if typ == 'R'
        AR = matrix;
        R = diagonal;
      endif  
      if typ == 'C'
        AC = matrix;
        C = diagonal;
      endif  
      if typ == 'V'
        AV = matrix;
        V = diagonal;
      endif 
      if typ == 'I'
        AI = matrix;
        I = diagonal;  
      endif
      
    endfor
  endfor
endfunction
