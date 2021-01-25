function C = SIS (h, a, e1, e2, N)
 
  openfemm;
  newdocument(0);
  mi_probdef(0,'millimeters','planar',1.E-8,3000,30);
  
  mi_addmaterial('Eisenjoch',1000,1000);
  mi_addmaterial('Kupfer',0.9999936,0.9999936);
  mi_addmaterial('Vakuum',1,1);
  
  mi_addcircprop('Stromanregung',6045.76,1);
  
  %Eisenjoch
  mi_drawpolygon([0,124.5; 113,124.5; 165,72.5; 165,0; 82.5,0; 82.5,35; 72.86,35; 69.86,33; 0,33]);
  mi_drawpolyline([0,33; 0,0; 82.5,0]);
  
  %lufteinschluss
  mi_drawline(81,42, 64.36, 42);
  mi_drawline(81,39, 64.36, 39);
  mi_addarc( 64.36, 42, 64.36, 39,180,10);
  mi_addarc( 81, 39, 81, 42,180,10);
  
  mi_addblocklabel(82.5,120);
  mi_selectlabel(82.5,120);
  mi_setblockprop('Eisenjoch',1,10,'<None>',0,0,0);
  mi_clearselected;
  
  mi_addblocklabel(72.68,40.5);
  mi_addblocklabel(42,16);
  mi_selectlabel(72.68,40.5);
  mi_selectlabel(42,16);
  mi_setblockprop('Vakuum',1,10,'<None>',0,0,0);
  mi_clearselected;
  
  
  
  
  %Spule
  mi_drawarc(76.36,1.17,76.36,7.17,180,10);
  mi_drawarc(76.36,7.17,76.36,1.17,180,10);
  
  mi_drawarc(76.36,1.67,76.36,6.67,180,10);
  mi_drawarc(76.36,6.67,76.36,1.67,180,10);
  
  mi_addblocklabel(79.11,4.17);
  mi_selectlabel(79.11,4.17);
  mi_setblockprop('Kupfer',1,10,'Stromanregung',0,0,0);
  mi_copytranslate2(-8.36,0,1,2);
  mi_clearselected;
  
  mi_addblocklabel(76.36,4.17);
  mi_selectlabel(76.36,4.17);
  mi_setblockprop('Vakuum',1,10,'<None>',0,0,0);
  mi_copytranslate2(-8.36,0,1,2);
  mi_clearselected;
  
  mi_selectlabel(76.36,4.17);
  mi_selectlabel(68,4.17);
  mi_selectlabel(79.11,4.17); 
  mi_selectlabel(70.75,4.17);
  mi_copytranslate2(0,8.18,3,2);
  mi_clearselected;
  
  mi_selectarcsegment(79.36,4.17);
  mi_selectarcsegment(73.36,4.17);
  mi_selectarcsegment(78.86,4.17);
  mi_selectarcsegment(73.86,4.17);
  
  mi_copytranslate2(-8.36,0,1,3);
  
  mi_selectarcsegment(79.36,4.17);
  mi_selectarcsegment(73.36,4.17);
  mi_selectarcsegment(78.86,4.17);
  mi_selectarcsegment(73.86,4.17);
  
  mi_selectarcsegment(71,4.17);
  mi_selectarcsegment(65,4.17);
  mi_selectarcsegment(70.5,4.17);
  mi_selectarcsegment(65.5,4.17);
  
  mi_copytranslate2(0,8.18,3,3);
  
  
  
  %Speichere die Datei ab
  mi_saveas('Aufgabe8_3.FEM');
  
  %Lade die gepeicherte Datei und erzeuge Simulation
  mi_analyze(0);
  mi_loadsolution;
  
  
  
end
