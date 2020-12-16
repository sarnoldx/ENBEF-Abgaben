
function C = spherecapacity (R1, er)
  R2 = R1 + 7;
  openfemm;
  newdocument(1);
  ei_probdef('centimeters','axi',1.E-8,0,30);
  ei_addmaterial('er',er,er,0);
  %Conductor Props erstellen
  ei_addconductorprop('Rand1',1,0,1);
  ei_addconductorprop('Rand2',0,0,1);
  
  %Draw first arcs
  ei_drawarc(0,-R1,R1,0,90,90);
  ei_drawarc(0,-R2,R2,0,90,90);
  
  %Set segment property and rotate arc once
  ei_selectarcsegment(0,-R1);
  ei_setarcsegmentprop(10,'<None>',0,0,'Rand1');
  ei_copyrotate2(0,0,90,1,3);
  ei_clearselected;
  
  %Set segment property and rotate arc once
  ei_selectarcsegment(0,-R2);
  ei_setarcsegmentprop(10,'<None>',0,0,'Rand2');
  ei_copyrotate2(0,0,90,1,3);
  ei_clearselected;
  
  ei_addblocklabel(R2-(R2-R1)/2,0);
  ei_selectlabel(R2-(R2-R1)/2,0);
  ei_setblockprop('er',1,0,0);
  ei_clearselected;
  
  ei_addblocklabel(0,0);
  ei_selectlabel(0,0);
  ei_setblockprop('<No Mesh>',1,0,0);
  ei_clearselected;
  
  ei_addsegment(0,R2,0,R1);
  ei_addsegment(0,-R2,0,-R1);
  
  
  %Speichere die Datei ab
  ei_saveas('Aufgabe5_3.FEE');
  
  %Lade die gepeicherte Datei und erzeuge Simulation
  ei_analyze(0);
  ei_loadsolution;
  
  %Liegenden Vektor erstellen, Ladung / Spannung ergibt Kapazit\"at C
  G = [0,0];
  G = eo_getconductorproperties('Rand1');
  C = G(1,2)/G(1,1);
  
endfunction
