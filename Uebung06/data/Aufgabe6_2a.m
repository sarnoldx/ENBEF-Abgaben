function C = Aufgabe6_2a (V)
  openfemm;
  newdocument(1);
  ei_probdef('millimeters','axi',1.E-8,0,30);
  
  ei_addmaterial('ZnO', 800, 800, 0);
  ei_addmaterial('Vakuum', 1, 1, 0);
  ei_addmaterial('PEC', 10.E5, 10.E5, 0);
  ei_addmaterial('Porzellan', 6, 6, 0);
  
  ei_addconductorprop('HighVoltage',471000,0,1);
  
  ei_addboundprop('boundary',V,0,0,0,0);
  
  %bottom
  ei_drawrectangle(0,0,140,2000);
  ei_addblocklabel(70,1000);
  ei_selectlabel(70,1000);
  ei_setblockprop('<No Mesh>',0,0,0);
  ei_clearselected;
  
  %white block
  ei_drawrectangle(0,2000,115,2120);
  ei_addblocklabel(57,2060);
  ei_selectlabel(57,2060);
  ei_setblockprop('PEC',0,0,0);
  ei_clearselected;
  
  %three layers
  ei_drawrectangle(0,2120,30,3080);
  ei_addblocklabel(15,2500);
  ei_selectlabel(15,2500);
  ei_setblockprop('ZnO',0,0,0);
  ei_clearselected;
  
  ei_drawrectangle(30,2120,70,3080);
  ei_addblocklabel(50,2500);
  ei_selectlabel(50,2500);
  ei_setblockprop('Vakuum',0,0,0);
  ei_clearselected;
  
  ei_drawrectangle(70,2120,100,3080);
  ei_addblocklabel(85,2500);
  ei_selectlabel(85,2500);
  ei_setblockprop('Porzellan',0,0,0);
  ei_clearselected;
  
  %white blocks
  ei_drawrectangle(0,3080,115,3200);
  ei_addblocklabel(57,3140);
  ei_drawrectangle(0,3200,115,3320);
  ei_addblocklabel(57,3260);
  ei_selectlabel(57,3140);
  ei_selectlabel(57,3260);
  ei_setblockprop('PEC',0,0,0);
  ei_clearselected;
  
  %three layers
  ei_drawrectangle(0,3320,30,4280);
  ei_addblocklabel(15,3700);
  ei_selectlabel(15,3700);
  ei_setblockprop('ZnO',0,0,0);
  ei_clearselected;
  
  ei_drawrectangle(30,3320,70,4280);
  ei_addblocklabel(50,3700);
  ei_selectlabel(50,3700);
  ei_setblockprop('Vakuum',0,0,0);
  ei_clearselected;
  
  ei_drawrectangle(70,3320,100,4280);
  ei_addblocklabel(85,3700);
  ei_selectlabel(85,3700);
  ei_setblockprop('Porzellan',0,0,0);
  ei_clearselected;
  
  %white blocks
  ei_drawrectangle(0,4280,115,4400);
  ei_addblocklabel(57,4340);
  ei_drawrectangle(0,4400,115,4520);
  ei_addblocklabel(57,4460);
  ei_selectlabel(57,4340);
  ei_selectlabel(57,4460);
  ei_setblockprop('PEC',0,0,0);
  ei_clearselected;
  
  %three layers
  ei_drawrectangle(0,4520,30,5480);
  ei_addblocklabel(15,5000);
  ei_selectlabel(15,5000);
  ei_setblockprop('ZnO',0,0,0);
  ei_clearselected;
  
  ei_drawrectangle(30,4520,70,5480);
  ei_addblocklabel(50,5000);
  ei_selectlabel(50,5000);
  ei_setblockprop('Vakuum',0,0,0);
  ei_clearselected;
  
  ei_drawrectangle(70,4520,100,5480);
  ei_addblocklabel(85,5000);
  ei_selectlabel(85,5000);
  ei_setblockprop('Porzellan',0,0,0);
  ei_clearselected;
  
  %white block
  ei_drawrectangle(0,5480,115,5600);
  ei_addblocklabel(57,5540);
  ei_selectlabel(57,5540);
  ei_setblockprop('PEC',0,0,0);
  ei_clearselected;
  ei_selectrectangle(0,5480,115,5600);
  ei_setsegmentprop('None', 0,1,0,0,'HighVoltage');
  ei_clearselected;
  
  %antenna
  ei_drawrectangle(0,5600,20,9000);
  ei_addblocklabel(10,7000);
  ei_selectlabel(10,7000);
  ei_setblockprop('<No Mesh>',0,0,0);
  ei_clearselected;
  ei_selectrectangle(0,5600,20,9000);
  ei_setsegmentprop('None', 0,1,0,0,'HighVoltage');
  ei_clearselected;
  

  %ring
  ei_drawarc(565,4800,565,4870,180,1);
  ei_selectarcsegment(565,4800);
  ei_setarcsegmentprop(10,'None',0,0,'HighVoltage');
  ei_copyrotate2(565,4835,180,1,3);
  ei_clearselected;
  ei_addblocklabel(565,4835);
  ei_selectlabel(565,4835);
  ei_setblockprop('<No Mesh>',0,0,0);
  ei_clearselected;
  
  %boundary
  ei_drawrectangle(0,0,4000,12000);
  ei_addblocklabel(2000,6000);
  ei_selectlabel(2000,6000);
  ei_setblockprop('Vakuum',0,0,0);
  ei_clearselected;
  
  
  
  
 
  %Speichere die Datei ab
  ei_saveas('Aufgabe6_2a.FEE');
  
  %Lade die gepeicherte Datei und erzeuge Simulation
  ei_analyze(0);
  ei_loadsolution;
  
  %Liegenden Vektor erstellen, Ladung / Spannung ergibt Kapazit\"at C
  %G = [0,0];
  %G = eo_getconductorproperties('Rand1');
  %C = G(1,2)/G(1,1);
  
endfunction
