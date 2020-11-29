
## Author: D. Schiller, S. Arnold, T. Lingenberg, C. Kramer
## Created: 2020-11-25

function C = femmbuilder (a, h)
 
  openfemm;
  newdocument(1);
  ei_probdef('centimeters','planar',1.E-8,a,30);
  ei_addmaterial('Vakuum',1,1,0);
  %ei_addboundprop('Randbedingung','Vs',0,0,0,0);
  ei_addconductorprop('Linker Rand',1,0,1);
  ei_addconductorprop('Rechter Rand',0,0,1);
  
  %Randpunkte fuer den Kondensator erstellen
  ei_drawrectangle(0,0,h,a);
  
  %Punkt fuer Materialproperty setzen
  ei_addblocklabel(h/2,a/2);
  
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
  
  %Material setzen
  ei_selectlabel(h/2,a/2);
  ei_setblockprop('Vakuum',1,0,0);
  ei_clearselected;
  
  %Speichere die Datei ab
  ei_saveas('Aufgabe3_b.FEE');
  
  %Lade die gepeicherte Datei und erzeuge Simulation
  ei_analyze(0);
  ei_loadsolution;
  
  %Liegenden Vektor erstellen, Ladung / Spannung ergibt Kapazit\"at C
  G = [0,0];
  G = eo_getconductorproperties('Linker Rand');
  C = G(1,2)/G(1,1);
    
endfunction
