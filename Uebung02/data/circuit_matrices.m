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
  C=L=R=V=I=zeros(0,1);

  % Durchlaufe alle Elementtypen (R,L,C,...)
  for i=1:size(cirstruct.LCR,2)
    typ=cirstruct.LCR(i).parnames{1,1};
    sz=size(cirstruct.LCR(i).pvmatrix,1);
    
    % Durchlaufe alle Bauteile eines Typen
    for j=1:size(cirstruct.LCR(i).pvmatrix,1)
      val=cirstruct.LCR(i).pvmatrix(j,:);
      pins=cirstruct.LCR(i).vnmatrix(j,:);
      
      
      % Implementierung fehlt
      if typ == 'R'
        
        %Matrix pro gefundenem R um 1 Spalte vergrößern
        AR=[AR,sparse(n,1)];
        %Diagonalmatrix Elemente einfügen
        R=[R,zeros(sz,1)];
        R(j,j)=1/val;
        %Richtung des Stroms bestimmen
        direction = pins(1) - pins(2);
        
        %Strom fließt von 1 nach 2
        if direction < 0
          %Nur hinzufügen wenn es sich nicht um den Masseknoten handelt
          if pins(1) != 0
            AR(pins(1),j)=1;
          endif
          AR(pins(2),j)=-1;
        %Strom fließt von 2 nach 1
        else
          AR(pins(1),j)=1;
          %Nur hinzufügen wenn es sich nicht um den Masseknoten handelt
          if pins(2) != 0
            AR(pins(2),j)=-1;
          endif
        endif
        
      endif
      
      if typ == 'L'
        AL=[AL,sparse(n,1)]
        %Diagonalmatrix Elemente einfügen
        L=[L,zeros(sz,1)];
        L(j,j)=val;
        %Richtung des Stroms bestimmen
        direction = pins(1) - pins(2);
        
        %Strom fließt von 1 nach 2
        if direction < 0
          %Nur hinzufügen wenn es sich nicht um den Masseknoten handelt
          if pins(1) != 0
            AL(pins(1),j)=1;
          endif
          AL(pins(2),j)=-1;
          
        %Strom fließt von 2 nach 1
        else
          AL(pins(1),j)=1;
          %Nur hinzufügen wenn es sich nicht um den Masseknoten handelt
          if pins(2) != 0
            AL(pins(2),j)=-1;
          endif
        endif
      endif
      
      if typ == 'C'
        AC=[AC,sparse(n,1)]
        %Diagonalmatrix Elemente einfügen
        C=[C,zeros(sz,1)];
        C(j,j)=val;
        %Richtung des Stroms bestimmen
        direction = pins(1) - pins(2);
        
        %Strom fließt von 1 nach 2
        if direction < 0
          %Nur hinzufügen wenn es sich nicht um den Masseknoten handelt
          if pins(1) != 0
            AC(pins(1),j)=1;
          endif
          AC(pins(2),j)=-1;
          
        %Strom fließt von 2 nach 1
        else
          AC(pins(1),j)=1;
          %Nur hinzufügen wenn es sich nicht um den Masseknoten handelt
          if pins(2) != 0
            AC(pins(2),j)=-1;
          endif
        endif
      endif
      
      if typ == 'V'
        AV=[AV,sparse(n,1)]
        
        %Richtung des Stroms bestimmen
        direction = pins(1) - pins(2);
        
        %Strom fließt von 1 nach 2
        if direction < 0
          %Nur hinzufügen wenn es sich nicht um den Masseknoten handelt
          if pins(1) != 0
            AV(pins(1),j)=1;
          endif
          AV(pins(2),j)=-1;
          %Spannungsquelle in Spaltenvektor hinzufügen
          V=[V;-val];
          
        %Strom fließt von 2 nach 1
        else
          AV(pins(1),j)=1;
          %Nur hinzufügen wenn es sich nicht um den Masseknoten handelt
          if pins(2) != 0
            AV(pins(2),j)=-1;
          endif
          %Spannungsquelle in Spaltenvektor hinzufügen
          V=[V;val];
        endif
      endif
      
      if typ == 'I'
        AI=[AI,sparse(n,1)]
        %Richtung des Stroms bestimmen
        direction = pins(1) - pins(2);
        
        %Strom fließt von 1 nach 2
        if direction < 0
          %Nur hinzufügen wenn es sich nicht um den Masseknoten handelt
          if pins(1) != 0
            AI(pins(1),j)=1;
          endif
          AI(pins(2),j)=-1;
          I=[I;val];
        %Strom fließt von 2 nach 1
        else
          AI(pins(1),j)=1;
          %Nur hinzufügen wenn es sich nicht um den Masseknoten handelt
          if pins(2) != 0
            AI(pins(2),j)=-1;
          endif
          I=[I;-val];
        endif
      endif
      
    end
  end

end
