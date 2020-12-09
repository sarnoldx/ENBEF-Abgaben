function C = femmcapacity (h, a, e1, e2, N)
 
  openfemm;
  newdocument(1);
  ei_probdef('centimeters','planar',1.E-8,a,30);
  ei_addmaterial('Vakuum',1,1,0);
  %ei_addmaterial('epsilonr1',e1,e1,0);
  %ei_addmaterial('epsilonr2',e2,e2,0);
  if (N==1)
    ei_addmaterial(strcat('epsilonr',num2str(1)),e1,e1,0);
  else
    for i=0:N-1
      ei_addmaterial(strcat('epsilonr',num2str(i+1)),e1+i*(e2-e1)/(N-1),e1+i*(e2-e1)/(N-1), 0);
    endfor 
  endif
  
  %ei_addboundprop('Randbedingung','Vs',0,0,0,0);
  ei_addconductorprop('Linker Rand',1,0,1);
  ei_addconductorprop('Rechter Rand',0,0,1);
  
  %Randpunkte fuer den Kondensator erstellen
  ei_drawrectangle(0,0,h,a);
  
  %Linken und rechten Rand setzen
  ei_selectsegment(0,a/2);
  ei_setsegmentprop('<None>',0,1,0,0,'Linker Rand');
  ei_clearselected;
  ei_selectsegment(h,a/2);
  ei_setsegmentprop('<None>',0,1,0,0,'Rechter Rand');
  ei_clearselected;
  
  %Oberen und unteren Rand setzen
  ei_selectsegment(h/2,0);
  ei_selectsegment(h/2,a);
  ei_setsegmentprop('<None>',0,1,0,0,'<None>');
  ei_clearselected;
  
  ei_addnode(h/N,0);
  ei_addnode(h/N,a);
  ei_addsegment(h/N,0,h/N,a);
  
  ei_selectsegment(h/N,a/2);
  ei_copytranslate2(h/N,0,N-2,1);
  ei_clearselected;
  ei_addblocklabel(h/(2*N),a/2);
  ei_selectlabel(h/(2*N),a/2);
  ei_copytranslate2(h/N,0,N-1,2);
  ei_clearselected;
  
  for i =1:2:2*N
   ei_selectlabel(i*h/(2*N),a/2);
   ei_setblockprop(strcat('epsilonr',num2str(1+(i-1)/2)),1,0,0);
   ei_clearselected;
  endfor 
  
  %Speichere die Datei ab
  ei_saveas('Aufgabe5_2.FEE');
  
  %Lade die gepeicherte Datei und erzeuge Simulation
  ei_analyze(0);
  ei_loadsolution;
  
  %Liegenden Vektor erstellen, Ladung / Spannung ergibt Kapazit\"at C
  G = [0,0];
  G = eo_getconductorproperties('Linker Rand');
  C = G(1,2)/G(1,1);
    
endfunction
