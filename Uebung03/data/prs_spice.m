%# Copyright (C) 2012  Marco Merlin
%#
%# This file is part of: 
%# OCS - A Circuit Simulator for Octave
%#
%# OCS  is free software; you can redistribute it and/or modify
%# it under the terms of the GNU General Public License as published by
%# the Free Software Foundation; either version 2 of the License, or
%# (at your option) any later version.
%#
%# OCS is distributed in the hope that it will be useful,
%# but WITHOUT ANY WARRANTY; without even the implied warranty of
%# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%# GNU General Public License for more details.
%#
%# You should have received a copy of the GNU General Public License
%# along with OCS; If not, see <http://www.gnu.org/licenses/>.
%#
%# author: Marco Merlin <marcomerli _AT_ gmail.com>
%# based on prs_iff which is (C) Carlo de Falco and Massimiliano Culpo

%# -*- texinfo -*-
%# @deftypefn {Function File} {[@var{stuct}]} = prs_spice (@var{filename})
%#
%# Circuit file parser that can interpret a subset of the spice file format.
%#
%# @code{prs_spice} currently supports the following set of "Element Cards"
%# @itemize @minus
%# @item Capacitors:
%# @example
%# Cname n+ n- cvalue
%# @end example
%#
%# @item Diodes:
%# @example
%# Cname anode knode modelname <parameters>
%# @end example
%#
%# @item MOS:
%# @example
%# Mname gnode dnode snode bnode modelname <parameters>
%# @end example
%# 
%# N.B.: one instance of a MOS element MUST be preceeded (everywhere in the file) by the declaration of the related model.
%# For instance:
%# @example
%# .MODEL mynmos NMOS( k=1e-4 Vth=0.1 rd=1e6)
%# M2 Vgate 0 Vdrain 0 mynmos
%# @end example
%# 
%# @item Resistors:
%# @example
%# Rname n+ n- rvalue
%# @end example
%# 
%# @item Voltage sources:
%# @example
%# Vname n+ n- <dcvalue> <transvalue>
%# @end example
%# 
%# Transvalue specifies a transient voltage source
%# @example
%# SIN(VO  VA  FREQ TD  THETA)
%# @end example
%# where:
%# @itemize @bullet
%# @item VO    (offset)
%# @item VA    (amplitude)
%# @item FREQ  (frequency)
%# @item TD    (delay)
%# @item THETA (damping factor)
%# @end itemize
%#
%# @itemize @bullet
%# @item 0 to TD: V0 
%# @item TD to TSTOP:  
%# VO  + VA*exp(-(time-TD)*THETA)*sine(twopi*FREQ*(time+TD))
%# @end itemize
%# 
%# Currently the damping factor has no effect.
%# 
%# Pulse
%# @example
%# PULSE(V1 V2 TD TR  TF  PW  PER)
%# @end example
%# 
%# parameters meaning
%# @itemize @bullet
%# @item V1         (initial value)
%# @item V2         (pulsed value)
%# @item TD         (delay time)
%# @item TR         (rise  time)
%# @item TF         (fall time)
%# @item PW         (pulse width)
%# @item PER        (period)
%# @end itemize 
%# 
%# Currently rise and fall time are not implemented yet.
%# 
%# @item .MODEL cards
%# Defines a model for semiconductor devices
%# 
%# @example
%# .MODEL MNAME TYPE PNAME1=PVAL1 PNAME2=PVAL2 ... 
%# @end example
%# 
%# TYPE can be:
%# @itemize @bullet
%# @item NMOS N-channel MOSFET model
%# @item PMOS P-channel MOSFET model
%# @item D    diode model
%# @end itemize
%# 
%# The parameter "LEVEL" is currently assigned to the field "section" in the call
%# of the element functions by the solver.
%# Currently supported values for the parameter LEVEL for NMOS and PMOS are:
%# @itemize @bullet
%# @item simple
%# @item lincap
%# @end itemize
%# (see documentation of function Mdiode).
%# 
%# Currently supported values for the parameter LEVEL for D are:
%# @itemize @bullet
%# @item simple
%# @end itemize
%# (see documentation of functions Mnmosfet and Mpmosfet).
%#
%#	@item Subcircuits
%#	Definition:
%#	.SUBCKT subcir_name n+ n-
%#	devices in subcircuit
%#	.ENDS
%#	Usage:
%#	Xname n- n+ subcir_name
%#
%#	@item Stimulus
%#	For loading a stimulus file:
%#	.STIMLIB "...\filename.stl"
%#	Storing a stimulus:
%#	.STIMULUS stim_name stimtype TIME_SCALE_FACTOR = t1 VALUE_SCALE_FACTOR = x1 (x1, y1) (x2, y2) ... (xn, yn)
%#	(Right now only stimtype set to PWL = piecewise linear) 
%#	Adding a stimulus source:
%#	V_name	n+ n- STIMULUS = stim_name
%#	I_name	n+ n- STIMULUS = stim_name
%#
%#	@item Temperature
%#	.TEMP T_value
%#
%#	@item OPTIONS
%#	.OPTION opt1 = val1 ... optn = valn
%#	To define a nominal temperature add TNOM = TNOM_value
%#	The rest of the options will be stored but not used
%# 
%# @end itemize
%# @seealso{prs_iff,Mdiode,Mnmosfet,Mpmosfet}
%# @end deftypefn

function [outstruct, opts] = prs_spice (name)

	%# Check input
	if (nargin ~= 1 || ~ischar (name))
		error ('prs_spice: wrong input.')
	end %if

	%# Initialization

	outstruct = struct ('LCR', [],...
	                    'NLC', [],...
	                    'totextvar', 0);

	global ndsvec;      %# Vector of circuit nodes
	global nodes_list;
	global intvar_list;
	
	global models_list;		%# Array of models information
	global stimulus_list;	%# Array of stimulus
	global options;			%# Array of .OPTIONS parameters
	global temperature;		%# Array storing temperatures
	
	global subcircuits;		%# Array of subcircuits
	global ndsvec_sbckt;	%# Vector of nodes for subcircuits
	global nodes_list_sbckt;
	global intvar_list_sbckt;
	global sbckt_bool;		%# Boolean stating if parser is reading a subcircuit currently

	ndsvec = [];
	outstruct.totintvar = 0; %# Number of internal variables

	count = struct ('NLC', struct ('n', 0,...
                                'list', {''}),...
                  'LCR', struct ('n', 0,...
                                'list', {''}));
	nodes_list = {'0'};
	intvar_list = {};
	models_list = struct ('mname', {''},...
                        'melement', {''},...
                        'msection', {''});
						
	stimulus_list = struct ('len' , 0, 'stimname', {''}, 'stimtype', {''},  'params', []);
	options = {'', ''};
	temperature = struct ('T', 300, 'TNOM', 300);
	
	subcircuits = struct('subcktNum', 0, 'subcktName', {''}, 'subcktNodes', {''}, 'subckts', [], 'subcktUsed', 0);
	subcircuits.subckts = struct ('LCR', [], 'NLC', [],'totextvar', 0, 'totintvar', 0);
	sbckt_bool = 0; %# boolean set to not be in a subcircuit.

	%#Initialize global variables
	ndsvec_sbckt = [];
	nodes_list_sbckt = {'0'};
	intvar_list_sbckt = {};

	%# File parsing

	%#Append extension only if necessary
	if isempty(strfind(name, '.'))
		filename = [name '.spc'];
	else
		filename = name;
	end
  
	%# Open circuit file
	if (exist (filename) ~= 2) %# isempty (file_in_path ('.', filename))
		error (['prs_spice: .spc file not found:' filename]);
	end %if
	fid = fopen (filename, 'r');

	if (fid>-1)
		line = '';
		fullline = '';
		lineCounter = 0;
		while (~feof(fid))
	
			line = fgets (fid);
			line = strtrim (line);
			lineCounter = lineCounter+1;

			%# exclude empty lines
			if length (line)
				%# exclude comments
				if (~strncmpi(line, '*', 1))
					%# lines here aren't comments
					if (strncmpi (line, '+', 1))
						%# this line has to be concatenated to previous one
						line (1) = ' ';
						fullline = [fullline line];
					else
						%# these lines are not a concatenation

						%# line echo for debug
						%# disp (fullline);

						%# compute fullline here!
						%#[outstruct, intvar, count] = lineParse (upper (fullline), outstruct, count, intvar);

						%# NB: case-sensitive because of parameter names
						%#[outstruct, intvar, count] = lineParse (fullline, outstruct, intvar, count);
						[outstruct, count, line] = lineParse (fullline, outstruct, count, fid, line);
						fullline = line;
					end %if (strncmpi (line, '+', 1))
				end %if (~strncmpi (line, '*', 1))
			end % if length (line)
		end % while ~feof (fid)

		%# parse last line
    if length (fullline)
      %# NB: case-sensitive because of parameter names
      %#[outstruct, intvar, count] = lineParse (upper (fullline), outstruct, count, intvar);
      %#[outstruct, intvar, count] = lineParse (fullline, outstruct, intvar, count);
      [outstruct, count, line] = lineParse (fullline, outstruct, count, fid, line);
    end
		fclose (fid);
	else
		error ('Input file not found!');
	end

  %#Add the global temperature parameters (if needed) to devices that use them.
	if (temperature.TNOM ~= 300 || temperature.T ~= 300)
		for (i=1:length(outstruct.NLC))
			if(strcmp(outstruct.NLC(i).func, 'Mdiode')==1 && strcmp(outstruct.NLC(i).section, 'PSpiceModel')==1)
				outstruct.NLC(i).npar = outstruct.NLC(i).npar + 2;
				tmp = ones(size(outstruct.NLC(i).pvmatrix,1), 2);
				tmp(:,1) = temperature.T.*tmp(:,1);
				tmp(:,2) = temperature.TNOM.*tmp(:,2);
				outstruct.NLC(i).pvmatrix = [tmp outstruct.NLC(i).pvmatrix];
				outstruct.NLC(i).nparnames = outstruct.NLC(i).nparnames + 2;
				outstruct.NLC(i).parnames = ['T' 'TNOM' outstruct.NLC(i).parnames];
			end
		end
		clear tmp;
	end

	%# Set the number of internal and external variables
	nnodes = length (unique (ndsvec));
	maxidx = max (ndsvec);

	if  (nnodes <= (maxidx+1))
		%# If the valid file is a subcircuit it may happen
		%# that nnodes == maxidx, otherwise nnodes == (maxidx+1)
		outstruct.totextvar = max (ndsvec);
	else
		error ('prs_spice: hanging nodes in circuit %s', name);
	end %if

	%# set node names as variable names
	for ii = 1:length (nodes_list)
		outstruct.namesn (ii) = ii-1;
	end %for
	outstruct.namess = horzcat (nodes_list, intvar_list);
	%#outstruct.namess
	
	
	%# Clear global variables
	clear -g ndsvec;      
	clear -g nodes_list;
	clear -g intvar_list;
	
	clear -g models_list;
	clear -g stimulus_list;
	clear -g temperature;
	
	opts = options;
	clear -g options;
	
	clear -g subcircuits;
	clear -g ndsvec_sbckt;
	clear -g nodes_list_sbckt;
	clear -g intvar_list_sbckt;
	clear -g sbckt_bool;
end %function

%# NLC block intvar count update
function outstruct = NLCintvar (outstruct, NLCcount, name)

	global ndsvec;
	global intvar_list;
  
	global ndsvec_sbckt;
	global intvar_list_sbckt;
	global sbckt_bool;

	%# set node names for NLC subcircuit
	%#for NLCcount = 1:count.NLC.n;
	%#NLCcount = count.NLC.n;
	%# set vnmatrix for NLC subcircuit
	if(~sbckt_bool)
		ndsvec = [ndsvec ;
            outstruct.NLC(NLCcount).vnmatrix(:)];
	else
		ndsvec_sbckt = [ndsvec_sbckt; 
						outstruct.NLC(NLCcount).vnmatrix(:)];
	end
	%# Compute internal variables cycling over each
	%# element in the section
	%#for iel = 1:outstruct.NLC(NLCcount).nrows
	
	iel = outstruct.NLC(NLCcount).nrows;
		[a, b, c] = feval (outstruct.NLC(NLCcount).func,...
					outstruct.NLC(NLCcount).section,...
					outstruct.NLC(NLCcount).pvmatrix(iel, :),...
					outstruct.NLC(NLCcount).parnames,...
					zeros (outstruct.NLC(NLCcount).nextvar, 1),...
					[],...
					0);

	%# FIXME: if all the element in the same section share the
	%# same number of internal variables, the for cycle can be
	%# substituted by only one call
	outstruct.NLC(NLCcount).nintvar(iel)  = size(a,2) - outstruct.NLC(NLCcount).nextvar;
	outstruct.NLC(NLCcount).osintvar(iel) = outstruct.totintvar;

	outstruct.totintvar = outstruct.totintvar + outstruct.NLC(NLCcount).nintvar(iel);
	if (outstruct.NLC(NLCcount).nintvar(iel)>0)
		if(~sbckt_bool)
			intvar_list{outstruct.totintvar} = ['I(' name ')'];
		else
			intvar_list_sbckt{outstruct.totintvar} = ['I(' name ')'];
		end
	end %if
	%#end %for
	%#end %for # NLCcount = 1:count.NLC.n;
end %function

%# LCR block intvar count update
function outstruct = LCRintvar (outstruct, LCRcount, name)
	global ndsvec;
	global intvar_list;
  
	global ndsvec_sbckt;
	global intvar_list_sbckt;
	global sbckt_bool;
	%# set node names for LCR subcircuit
	%#  for LCRcount = 1:count.LCR.n;
	%#   LCRcount = count.LCR.n;
	%# set vnmatrix for LCR subcircuit
	if (~sbckt_bool)
		ndsvec = [ndsvec ; outstruct.LCR(LCRcount).vnmatrix(:)];
	else
		ndsvec_sbckt =  [ndsvec_sbckt; outstruct.LCR(LCRcount).vnmatrix(:)];
	end
	%# Compute internal variables cycling over each
	%# element in the section
	%#for iel = 1:outstruct.LCR(LCRcount).nrows
	
	iel = outstruct.LCR(LCRcount).nrows;
		[a, b, c] = feval (outstruct.LCR(LCRcount).func,...
                   outstruct.LCR(LCRcount).section,...
                   outstruct.LCR(LCRcount).pvmatrix(iel, :),...
                   outstruct.LCR(LCRcount).parnames,...
                   zeros(outstruct.LCR(LCRcount).nextvar, 1),...
                   [],...
                   0);
				   
	%# FIXME: if all the element in the same section share the
	%# same number of internal variables, the for cycle can be
	%# substituted by only one call
	outstruct.LCR(LCRcount).nintvar(iel)  = size(a,2) - outstruct.LCR(LCRcount).nextvar;
	%#outstruct.LCR(LCRcount).osintvar(iel) = intvar;
	outstruct.LCR(LCRcount).osintvar(iel) = outstruct.totintvar;

	%#intvar += outstruct.LCR(LCRcount).nintvar(iel);
	outstruct.totintvar = outstruct.totintvar + outstruct.LCR(LCRcount).nintvar(iel);
	if outstruct.LCR(LCRcount).nintvar(iel)>0
		if(~sbckt_bool)
			intvar_list{outstruct.totintvar} = ['I(' name ')'];
		else
			intvar_list_sbckt{outstruct.totintvar} = ['I(' name ')'];
		end
	end %if
	%#end %for
	%#  end %for # LCRcount = 1:count.LCR.n;
end %function

%# Parses a single line
function [outstruct, count, line2] = lineParse (line, outstruct, count, fid, line2)
	if length (line)
		switch (line (1))
			case 'C'
				[outstruct, count] = prs_spice_C (line, outstruct, count);
			case 'D'
				[outstruct, count] = prs_spice_D (line, outstruct, count);
			case 'I'
				[outstruct, count] = prs_spice_I (line, outstruct, count);
			case 'L'
				[outstruct, count] = prs_spice_L (line, outstruct, count);
			case 'M'
				%# FIXME: just for nMOS devices!
				[outstruct, count] = prs_spice_M (line, outstruct, count);
				%# case 'P'
				%# temporarily assigned to pMOS devices.
				%#[outstruct, count] = prs_spice_P (line, outstruct, count);
			case 'R'
				[outstruct, count] = prs_spice_R (line, outstruct, count);
			case 'V'
				[outstruct, count] = prs_spice_V (line, outstruct, count);
			case 'X'
				[outstruct, count] = prs_spice_X (line, outstruct, count);
			case '.'
				[outstruct, count, line2] = prs_spice_dot (line, outstruct, count, fid, line2);
			otherwise
				err = sprintf (['prs_spice: Unsupported circuit element in line: ' line ]);
				error (err);
		end %	switch (line (1))
	end	%if length (line)

end %function

%# adds an NLC element to outstruct
function [outstruct, count, idx] = addNLCelement (outstruct, count, element, section, nextvar, npar, nparnames, parnames, vnmatrix, pvmatrix)
	%# check whether the element type already exists in output structure
	%# the search key is (func, section)
	
	if(ischar(element))
		element2 = element;
	else
		%element is function handle
		element2 = func2str(element);
	end %if
	
	if(strcmp(section, 'stimulus'))
		element2 = [element2(59:end-84) '_Stim_' num2str(pvmatrix)];
	end
	
	%[tf, idx] = ismember ({element}, count.NLC.list);
	[tf, idx] = ismember({element2}, count.NLC.list);
	
  
  
	%#Check if element does not exist, section or parameternames are different
	if (~tf)
		%#|| !strcmp(outstruct.NLC(idx).section, section) || !strcmp([outstruct.NLC(idx).parnames{:}] , [parnames{:}])
		%# the element still does not exist
		%# update counters
		idx = count.NLC.n + 1;
		count.NLC.n = idx;
		
		%count.NLC.list{idx}        = element;
		count.NLC.list{idx} 	   = element2;
	
		%# if the element doesn't exists, add it to the output structure
		outstruct.NLC(idx).func    = element;
		outstruct.NLC(idx).section = section;
		outstruct.NLC(idx).nextvar = nextvar;
		outstruct.NLC(idx).npar    = npar;
		outstruct.NLC(idx).nrows   = 1;
		outstruct.NLC(idx).nparnames = nparnames;
		outstruct.NLC(idx).parnames  = parnames;
		outstruct.NLC(idx).vnmatrix  = vnmatrix;
		outstruct.NLC(idx).pvmatrix  = pvmatrix;
	else
  
		%#Search if element with same section, parameternames (not their values) and length of parametermatrix already exists 
		found = 0;
		for (ii= 1:length(idx))
			if (strcmp(outstruct.NLC(idx(ii)).section, section) &&...
				strcmp([outstruct.NLC(idx(ii)).parnames{:}], [parnames{:}]) &&...
				length(outstruct.NLC(idx(ii)).pvmatrix(1,:))==length(pvmatrix))
				found = 1;
				break;
			end %if
		end %for
	
		%#No other element with same section, parnames and length of pvmatrix found
		if(~found)
			%# the element still does not exist
			%# update counters
			idx = count.NLC.n + 1;
			count.NLC.n = idx;
			
			%count.NLC.list{idx}        = element;
			count.NLC.list{idx}       = element2;
			
			%# if the element doesn't exists, add it to the output structure
			outstruct.NLC(idx).func    = element;
			outstruct.NLC(idx).section = section;
			outstruct.NLC(idx).nextvar = nextvar;
			outstruct.NLC(idx).npar    = npar;
			outstruct.NLC(idx).nrows   = 1;
			outstruct.NLC(idx).nparnames = nparnames;
			outstruct.NLC(idx).parnames  = parnames;
			outstruct.NLC(idx).vnmatrix  = vnmatrix;
			outstruct.NLC(idx).pvmatrix  = pvmatrix;
		else
			%# the couple (element, section) already exists, so add a row in the structure
			idx = idx(ii);
			outstruct.NLC(idx).nrows = outstruct.NLC(idx).nrows + 1;
			[outstruct.NLC(idx).vnmatrix] = [outstruct.NLC(idx).vnmatrix; vnmatrix];
			[outstruct.NLC(idx).pvmatrix] = [outstruct.NLC(idx).pvmatrix; pvmatrix];
		end %if
	end %if
end %function

%# adds an LCR element to outstruct
function [outstruct, count, idx] = addLCRelement (outstruct, count, element, section, nextvar, npar, nparnames, parnames, vnmatrix, pvmatrix)
	%# check whether the element type already exists in output structure
	%# the search key is (func, section)
	if(ischar(element))
		element2 = element;
	else
		%element is function handle
		element2 = func2str(element);
	end %if
	
	%[tf, idx] = ismember ({element}, count.LCR.list);
	[tf, idx] = ismember ({element2}, count.LCR.list);
	
  
	%# check if element does not exist, section, parameternames or length of pvmatrix are different
	if (~tf)
		%# the element still does not exist
		%# update counters
		idx = count.LCR.n+1;
		count.LCR.n = idx;
		
	
		%count.LCR.list{idx}        = element;
		count.LCR.list{idx}       = element2;
		
		%# if the element doesn't exists, add it to the output structure
		outstruct.LCR(idx).func    = element;
		outstruct.LCR(idx).section = section;
		outstruct.LCR(idx).nextvar = nextvar;
		outstruct.LCR(idx).npar    = npar;
		outstruct.LCR(idx).nrows   = 1;
		outstruct.LCR(idx).nparnames = nparnames;
		outstruct.LCR(idx).parnames  = parnames;
		outstruct.LCR(idx).vnmatrix  = vnmatrix;
		outstruct.LCR(idx).pvmatrix  = pvmatrix;
	else
		found = 0;
		for (ii = 1:length (idx))
			if (strcmp(outstruct.LCR(idx(ii)).section, section) &&...
				strcmp([outstruct.LCR(idx(ii)).parnames{:}], [parnames{:}]) &&...
				length(outstruct.LCR(idx(ii)).pvmatrix(1,:))==length(pvmatrix))
				found = 1;
				break;
			end %if #!strcmp (outstruct.LCR(idx(ii)).section, section)
		end %for #ii = 1:length (idx)

		if (~ found)
			%# the section does not exist

			%# the element still does not exist
			%# update counters
			idx = count.LCR.n + 1;
			count.LCR.n = idx;
			
			%count.LCR.list{idx}        = element;
			count.LCR.list{idx}       = element2;
			
			%# if the element doesn't exists, add it to the output structure
			outstruct.LCR(idx).func    = element;
			outstruct.LCR(idx).section = section;
			outstruct.LCR(idx).nextvar = nextvar;
			outstruct.LCR(idx).npar    = npar;
			outstruct.LCR(idx).nrows   = 1;
			outstruct.LCR(idx).nparnames = nparnames;
			outstruct.LCR(idx).parnames  = parnames;
			outstruct.LCR(idx).vnmatrix  = vnmatrix;
			outstruct.LCR(idx).pvmatrix  = pvmatrix;

		else
			%# the couple (element, section) already exists, so add a row in the structure
			%# add an element to the structure
			idx = idx(ii);
			outstruct.LCR(idx).nrows = outstruct.LCR(idx).nrows + 1;

			%# update parameter value and connectivity matrix
			[outstruct.LCR(idx).vnmatrix] = [outstruct.LCR(idx).vnmatrix; vnmatrix];
			[outstruct.LCR(idx).pvmatrix] = [outstruct.LCR(idx).pvmatrix; pvmatrix];
		end %if
	end %if
end %function

%# converts a blank separated values string into a cell array
function ca = str2ca (str)
	ca = regexpi (str, '[^ \s=]+', 'match');
end %function

%#function that deletes braces if nodes are between ()
function no = nodeCorrector(str, n)
	no = str;
	aux = str{1};
	if (strcmp(aux(1), '('))
		no{1} = aux(2:end);
		aux = str{n};
		if(strcmp(aux(end), ')'))
			no{end} = aux(1:end-1);
		else
			error(['prs_spice: Non consistent node writing ' str{1} ' ' str{end} '\n']);
		end
	else
		aux = str{n};
		if(strcmp(aux(end), ')'))
			no{end} = aux(1:end-1);
			error(['prs_spice: Non consistent node writing ' str{1} ' ' str{end} '\n']);
		end
	end
end

%# replaces the tokens c_old with c_new in string inString
function outString = strReplace (inString, c_old, c_new)
	outString = inString;
	l = length (c_new);
	for idx = 1:length (c_old)
		if (idx<=l)
			outString = strrep (outString, c_old{idx}, c_new{idx});
		end
	end
end %function

%# returns the numeric value of a string
function num = literal2num (string)
	literals = {'MEG' 'MIL'     'A'    'F'     'P'    'N'   'U'   'M'   'K'  'G'  'T'};
	numerics = {'e6'  '*25.4e-6' 'e-18' 'e-15' 'e-12' 'e-9' 'e-6' 'e-3' 'e3' 'e9' 'e12'};
	newstr = strReplace (upper (string), literals, numerics);
	num = str2num (newstr);
	if(length(num) == 0)
		err = ['prs_spice: Error with numerical interpretation of ' string];
		error(err);
	end
end

function syntaxError (line)
	warnstr = sprintf ('Syntax error in line: %s', line);
	error (warnstr);
end %function

function [outstruct, count] = prs_spice_C (line, outstruct, count)
	element   = 'Mcapacitors';
	section   = 'LIN';
	nextvar   = 2;
	npar      = 1;
	nparnames = 1;
	parnames  = {'C'};
	ca = str2ca (line);
	if (length (ca)>3)
		vnmatrix  = add_nodes (nodeCorrector(ca(2:3),nextvar));
		pvmatrix  = literal2num (ca{4});
		[outstruct, count, idx] = addLCRelement (outstruct, count, element, section, nextvar, npar, nparnames, parnames, vnmatrix, pvmatrix);
		outstruct = LCRintvar(outstruct, idx, ca{1});
	else
		syntaxError (line);
	end %if
end %function

function [outstruct, count] = prs_spice_D (line, outstruct, count)

	global models_list;
	
	element = 'Mdiode';
	ca = str2ca (line);
	%# Check if diode is model
	if (length(ca)>3)
		[tf, idx] = ismember (ca{4}, models_list.mname);
	else
		tf = 0;
	end %if
  
	if(tf) %# Diode is in models_list
		section = models_list.msection{idx};
		nextvar = 2;
		parnames = models_list.plist{idx}.pnames;
		pvmatrix = models_list.plist{idx}.pvalues;
		if(length(ca)>4)
			parnames(length(parnames)+1) = 'AREA';
			pvmatrix(length(pvmatrix)+1) = literal2num(ca{5});
		end %if
		
		npar = length(pvmatrix);
		nparnames = length(parnames);
		if (length(ca) > 5)
			warn = ['prs_spice warning: Extra options after AREA value not considered in\n' line '\n'];
			fprintf(warn);
		end
	else
		warn = ['prs_spice warning: No diode model declaration for line: \n' line '\n Simple Diode model taken.\n'];
		fprintf(warn);
		section = 'simple';
		nextvar = 2;
		npar = 0;
		nparnames = 0;
		parnames = {};
		pvmatrix  = [];
		%# check if parameters are specified
		for (prm_idx = 1:(length (ca)-3)/2)
			%# [tf, str_idx] = ismember (outstruct.NLC(count.NLC.n).parnames{prm_idx}, ca);
			%# TODO: can the loop be executed in a single operation?
			%# [tf, str_idx] = ismember (outstruct.NLC(count.NLC.n).parnames, ca);
			if (length (ca) >= 1+prm_idx*2)
				%# find specified parameter name
				%#if tf
				npar = npar + 1;
				nparnames = nparnames + 1;
				parnames{1, prm_idx} = ca{2*prm_idx+2};
				pvmatrix(1, prm_idx) = literal2num (ca{2*prm_idx+3});
			else
				syntaxError (line);
			end %if
		end %for
	end %if
	
	if (length(ca) > 2)
		vnmatrix  = add_nodes (nodeCorrector(ca(2:3),nextvar));
	else
		syntaxError(line);
	end %if
	
	[outstruct, count, idx] = addNLCelement(outstruct, count, element, section, nextvar, npar, nparnames, parnames, vnmatrix, pvmatrix);
	outstruct = NLCintvar(outstruct, idx, ca{1});
end %function

function [outstruct, count] = prs_spice_M (line, outstruct, count)
	global models_list;
  
	ca = str2ca (line);
	if(length(ca) > 5)
		[tf, idx] = ismember (ca{6}, models_list.mname);
	else
		tf = 0;
	end %if
  
	nextvar = 4;
	npar = 0;
	nrows = 1;
	nparnames = 0;
	parnames = {};
	pvmatrix = [];
	if (length(ca)>4)
		vnmatrix = add_nodes(nodeCorrector(ca(2:5),nextvar));
	else
		syntaxError (line);
	end %if
  
	if (tf)
		element = models_list.melement{idx};
		section = models_list.msection{idx};
	
		%# check if parameters are specified
		for (prm_idx = 1:(length (ca)-6)/2)
			if (length (ca)>=4+prm_idx*2)
				npar = npar + 1;
				nparnames = nparnames + 1;
				parnames{1, prm_idx} = ca{2*prm_idx+5};
				pvmatrix(1, prm_idx) = literal2num (ca{2*prm_idx+6});
			else
				syntaxError (line);
			end %if
		end %for
		prm_idx = npar;
		len = length(models_list.plist{idx}.pnames);
		for mpidx = 1:len
			parnames{prm_idx + mpidx} = models_list.plist{idx}.pnames{mpidx};
			pvmatrix(1, prm_idx+mpidx) = models_list.plist{idx}.pvalues(mpidx);
		end %for
		npar = npar + len;
		nparnames = nparnames + len;
		[outstruct, count, idx] = addNLCelement(outstruct, count, element, section, nextvar, npar, nparnames, parnames, vnmatrix, pvmatrix);
		outstruct = NLCintvar(outstruct, idx, ca{1});
	else
		syntaxError (line);
	end %if
end %function

function [outstruct, count]= prs_spice_P (line, outstruct, count)
	element = 'Mpmosfet';
  
	section = 'simple';
	nextvar = 4;
	npar = 0;
	nrows = 1;
	nparnames = 0;
	parnames = {};
	pvmatrix = [];
	ca = str2ca (line);
	if(length(ca)>4)
		vnmatrix = add_nodes(nodeCorrector(ca(2:5),nextvar));
	else
		syntaxError(line);
	end %if

	%# check if parameters are specified
	for prm_idx = 1:(length (ca)-5)/2
		%# [tf, str_idx] = ismember (outstruct.NLC(count.NLC.n).parnames{prm_idx}, ca);
		%# TODO: can the loop be executed in a single operation?
		%# [tf, str_idx] = ismember (outstruct.NLC(count.NLC.n).parnames, ca);
		if (length (ca) >= 3+prm_idx*2)
			%# find specified parameter name
			%#if tf

			npar = npar + 1;
			nparnames = nparameters + 1;
			parnames{1, prm_idx} = ca{2*prm_idx+4};
			pvmatrix(1, prm_idx) = literal2num (ca{2*prm_idx+5});
			%#else
			%# TODO: set to a default value undefined parameters, instead of rising an error?
			%#        errstr=sprintf('Undefined parameter %s in line: %s', outstruct.NLC(count.NLC.n).parnames{prm_idx}, line);
			%#        error(errstr);
			%#end %if
		else
			syntaxError (line);
		end %if
	end %for
  
	[outstruct, count, idx] = addNLCelement(outstruct, count, element, section, nextvar, npar, nparnames, parnames, vnmatrix, pvmatrix);
	outstruct = NLCintvar(outstruct, idx, ca{1});
end %function

function [outstruct, count]= prs_spice_L (line, outstruct, count)
	element = 'Minductors';
    section = 'LIN';
    nextvar = 2;
    npar    = 1;
    nparnames = 1;
    parnames  = {'L'};
    ca = str2ca (line);
	if (length(ca) > 3)
		vnmatrix  = add_nodes (nodeCorrector(ca(2:3),nextvar));
		pvmatrix  = literal2num (ca{4});
	else
		syntaxError(line);
	end
    [outstruct, count, idx] = addLCRelement (outstruct, count, element, section, nextvar, npar, nparnames, parnames, vnmatrix, pvmatrix);
    outstruct = LCRintvar(outstruct, idx, ca{1});
end %function

function [outstruct, count]= prs_spice_R (line, outstruct, count)
	element   = 'Mresistors';
	section   = 'LIN';
	nextvar   = 2;
	npar      = 1;
	nparnames = 1;
	parnames  = {'R'};
	ca = str2ca (line);
	if(length(ca) > 3)
		vnmatrix  = add_nodes (nodeCorrector(ca(2:3),nextvar));
		pvmatrix  = literal2num (ca{4});
	else
		syntaxError(line);
	end %if
	[outstruct, count, idx] = addLCRelement (outstruct, count, element, section, nextvar, npar, nparnames, parnames, vnmatrix, pvmatrix);
	outstruct = LCRintvar(outstruct, idx, ca{1});
end %function

function [outstruct, count] = prs_spice_V (line, outstruct, count)
	%# Sine
	%# SIN(VO  VA  FREQ TD  THETA)
	%#
	%# VO    (offset)
	%# VA    (amplitude)
	%# FREQ  (frequency)
	%# TD    (delay)
	%# THETA (damping factor)
	%#
	%# 0 to TD: V0
	%# TD to TSTOP:  VO  + VA*exp(-(time-TD)*THETA)*sine(twopi*FREQ*(time+TD)

	%# check if it is a sinwave generator
	[ind, sine] = regexp (line, '(?<stim>SIN)[\s]*\((?<prms>.+)\)', 'start', 'names');

	%# Pulse
	%# PULSE(V1 V2 TD TR  TF  PW  PER)
	%#
	%# parameters  default values  units
	%# V1  (initial value) Volts or Amps
	%# V2  (pulsed value) Volts or Amps
	%# TD  (delay time)  0.0  seconds
	%# TR  (rise  time)  TSTEP  seconds
	%# TF  (fall time)  TSTEP  seconds
	%# PW  (pulse width)  TSTOP  seconds
	%# PER (period)  TSTOP  seconds

	%# check if it is a pulse generator
	[ind1, pulse] = regexp (line, '(?<stim>PULSE)[\s]*\((?<prms>.+)\)', 'start', 'names');

	if (~isempty(ind))	%# sinwave generator
		ca = str2ca (sine.prms);
		if (length (ca) == 5)
			vo = literal2num (ca{1});
			va = literal2num (ca{2});
			freq = literal2num (ca{3});
			td = literal2num (ca{4});
			theta = literal2num (ca{5});

			pvmatrix = [va freq td vo];

			element = 'Mvoltagesources';
			section = 'sinwave';

			nextvar = 2;
			npar    = 4;
			nparnames = 4;
			parnames  = {'Ampl', 'f', 'delay', 'shift'};
			%# convert input line string into cell array
			ca = str2ca (line);
			vnmatrix  = add_nodes (nodeCorrector(ca(2:3), nextvar));
			[outstruct, count, idx] = addNLCelement (outstruct, count, element, section, nextvar, npar, nparnames, parnames, vnmatrix, pvmatrix);
			outstruct = NLCintvar(outstruct, idx, ca{1});
		else %#length(ca) == 5
			syntaxError (line);
		end %if #length (ca) == 5
	elseif (~isempty(ind1))		%# pulse generator
		ca = str2ca (pulse.prms);
		if length (ca) == 7
			low = literal2num (ca{1});
			high = literal2num (ca{2});
			delay = literal2num (ca{3});
			%# TODO: add rise and fall times!
			%# tr = literal2num (ca{4});
			%# tf = literal2num (ca{5});
			thigh = literal2num (ca{6});
			period = literal2num (ca{7})
			tlow = period-thigh;

			pvmatrix = [low high tlow thigh delay];

			element = 'Mvoltagesources';
			section = 'squarewave';

			nextvar = 2;
			npar    = 5;
			nparnames = 5;
			parnames  = {'low', 'high', 'tlow', 'thigh', 'delay'};
			%# convert input line string into cell array
			ca = str2ca (line);
			vnmatrix  = add_nodes (nodeCorrector(ca(2:3),nextvar));
			[outstruct, count, idx] = addNLCelement (outstruct, count, element, section, nextvar, npar, nparnames, parnames, vnmatrix, pvmatrix);
			outstruct = NLCintvar(outstruct, idx, ca{1});
		else %#length (ca) == 7
			syntaxError (line);
		end %if ##length (ca) == 7
	elseif(any(strfind(line,'STIMULUS')>0) || any(strfind(line, 'stimulus')>0))	%# check if source is a defined stimulus
		ca = str2ca(line);
		
		if (length(ca) > 4)
			token = ca{5};
		else
			syntaxError(line);
		end %if
		aux = 0;
		
		global stimulus_list;
		for (i = 1:stimulus_list(1).len)
			if(strcmp(token, stimulus_list(i).stimname))
				aux = i;
				element = 'Mvoltagesources';
				section = 'stimulus';
				nextvar = 2;
				parnames = {'StimNum'};
				nparnames = 1;
				pvmatrix = [i stimulus_list(i).params];
				npar = length(pvmatrix);
				vnmatrix  = add_nodes (nodeCorrector(ca(2:3),nextvar));
				[outstruct, count, idx] = addNLCelement (outstruct, count, element, section, nextvar, npar, nparnames, parnames, vnmatrix, pvmatrix);
				outstruct = NLCintvar(outstruct, idx, ca{1});
				break
			end %if	
		end %for
		if(aux==0)
			err = ['prs_spice: Stimulus ' token ' not found. Remember that all stimuli must be defined before being used.\n'];
			error(err);
		end %if
	else	%# DC generator
		element = 'Mvoltagesources';
		section = 'DC';

		nextvar = 2;
		npar    = 1;
		nparnames = 1;
		parnames  = {'V'};
		%# convert input line string into cell array
		ca = str2ca (line);
		if (length(ca)>3)
			vnmatrix  = add_nodes (nodeCorrector(ca(2:3),nextvar));
			pvmatrix  = literal2num (ca{4});
		else
			syntaxError(line);
		end %if
		[outstruct, count, idx] = addLCRelement (outstruct, count, element, section, nextvar, npar, nparnames, parnames, vnmatrix, pvmatrix);
		outstruct = LCRintvar(outstruct, idx, ca{1});
	end %if #~isempty(tran.stim)
end %function

function [outstruct, count] = prs_spice_I (line, outstruct, count)
	element = 'Mcurrentsources';
	nextvar = 2;
	
	if(any(strfind(line,'STIMULUS')>0) || any(strfind(line, 'stimulus')>0)) %# Check if source is a defined stimulus
		ca = str2ca(line);
		if (length(ca) > 4)
			token = ca{5};
		else
			syntaxError(line);
		end %if
		aux = 0;
		global stimulus_list;
		for (i = 1:stimulus_list(1).len)
			if(strcmp(token, stimulus_list(i).stimname))
				aux = i;
				section = 'stimulus';
				parnames = {'StimNum'};
				nparnames = 1;
				
				pvmatrix = [i stimulus_list(i).params];
				element = 'Mcurrentsources';
				npar = length(pvmatrix);
				vnmatrix  = add_nodes (nodeCorrector(ca(2:3),nextvar));
				[outstruct, count,idx] = addNLCelement (outstruct, count, element, section, nextvar, npar, nparnames, parnames, vnmatrix, pvmatrix);
				outstruct = NLCintvar(outstruct, idx, ca{1});
				break
			end %if	
		end %for
		if(aux==0)
			err = ['prs_spice: Stimulus ' token ' not found. Remember that all stimuli must be defined before being used.\n'];
			error(err);
		end %if
	else
		%# DC generator
		section = 'DC';
		npar    = 1;
		nparnames = 1;
		parnames  = {'I'};
		%# convert input line string into cell array
		ca = str2ca (line);
		if (length(ca)>3)
			vnmatrix  = add_nodes (nodeCorrector(ca(2:3),nextvar));
			pvmatrix  = literal2num (ca{4});
		else
			syntaxError(line);
		end %if
		[outstruct, count, idx] = addLCRelement (outstruct, count, element, section, nextvar, npar, nparnames, parnames, vnmatrix, pvmatrix);
		outstruct = LCRintvar(outstruct, idx, ca{1});
	end %if #~isempty(tran.stim)
end %function

function [outstruct,count] = prs_spice_X (line, outstruct, count)
	%# device is a subcircuit
	global subcircuits;
	
	ca = str2ca(line);
	dev_name = ca{1};
	subcir_name = ca{end};
	
	subcir_ind = 0;
	for (i = 1:subcircuits.subcktNum) %# Check which defined subcircuit it is
		if (strcmp(subcircuits.subcktName{i}, subcir_name))
			subcir_ind = i;
		end
	end
	if(subcir_ind == 0)
		err = ['prs_spice: Error, subcircuit ' subcir_name ' not found. Please make sure that all subcircuits are defined before being used'];
		error(err);
	end
	
	subcir_nodes_num = length(subcircuits.subcktNodes(:,subcir_ind));
	if(subcir_nodes_num ~= length(ca(2:end-1)))
		err = ['prs_spice: Wrong number of input nodes for subcircuit ' subcir_name ' in ' dev_name];
		error(err);
	end
	cir_nodes = nodeCorrector(ca(2:end-1), subcir_nodes_num);
	subcir_nodes = subcircuits.subcktNodes(:,subcir_ind);
	
	%#Pass LCR devices of subcircuit to main circuit
	for(i = 1:length(subcircuits.subckts(subcir_ind).LCR))
		element = subcircuits.subckts(subcir_ind).LCR(i).func;
		section = subcircuits.subckts(subcir_ind).LCR(i).section;
		nextvar = subcircuits.subckts(subcir_ind).LCR(i).nextvar;
		npar = subcircuits.subckts(subcir_ind).LCR(i).npar;
		nparnames = subcircuits.subckts(subcir_ind).LCR(i).nparnames;
		parnames = subcircuits.subckts(subcir_ind).LCR(i).parnames;
		for (l=1:size(subcircuits.subckts(subcir_ind).LCR(i).vnmatrix,1))
			nodes = cell(1,nextvar);
			for (k=1:nextvar)
				aux = find(subcircuits.subckts(subcir_ind).namesn == subcircuits.subckts(subcir_ind).LCR(i).vnmatrix(l,k));
				nodes{1,k} = subcircuits.subckts(subcir_ind).namess{aux};
				idx = strcmp(subcir_nodes, nodes{1,k});
				idx = find(idx);
				if(idx)
					nodes{1,k} = cir_nodes{idx};
				else
					nodes{1,k} = [nodes{1,k} '-' dev_name '-' num2str(subcircuits.subcktUsed)];
				end %if
			end %for (k=1:nextvar)
			vnmatrix = add_nodes(nodeCorrector(nodes, nextvar));
			pvmatrix = subcircuits.subckts(subcir_ind).LCR(i).pvmatrix(l,:);
			[outstruct, count, idx] = addLCRelement(outstruct, count, element,...
									section, nextvar, npar, nparnames, parnames, vnmatrix, pvmatrix);
			ind = subcircuits.subckts(subcir_ind).totextvar + 1 + subcircuits.subckts(subcir_ind).LCR(i).osintvar(l) + subcircuits.subckts(subcir_ind).LCR(i).nintvar(l);
			aux = subcircuits.subckts(subcir_ind).namess(ind);
			int_name = [aux{1}(3:end-1) '-' dev_name '-' num2str(subcircuits.subcktUsed)];
			outstruct = LCRintvar(outstruct, idx, int_name);
		end %for
	end %for
	
	%#Pass NLC devices of subcircuit to main circuit
	for(i = 1:length(subcircuits.subckts(subcir_ind).NLC))
		element = subcircuits.subckts(subcir_ind).NLC(i).func;
		section = subcircuits.subckts(subcir_ind).NLC(i).section;
		nextvar = subcircuits.subckts(subcir_ind).NLC(i).nextvar;
		npar = subcircuits.subckts(subcir_ind).NLC(i).npar;
		nparnames = subcircuits.subckts(subcir_ind).NLC(i).nparnames;
		parnames = subcircuits.subckts(subcir_ind).NLC(i).parnames;
		for (l=1:size(subcircuits.subckts(subcir_ind).NLC(i).vnmatrix,1))
			nodes = cell(1,nextvar);
			for (k=1:nextvar)
				aux = find(subcircuits.subckts(subcir_ind).namesn == subcircuits.subckts(subcir_ind).NLC(i).vnmatrix(l,k));
				nodes{1,k} = subcircuits.subckts(subcir_ind).namess{aux};
				idx = strcmp(subcir_nodes, nodes{1,k});
				idx = find(idx);
				if(idx)
					nodes{1,k} = cir_nodes{idx};
				else
					nodes{1,k} = [nodes{1,k} '-' dev_name '-' num2str(subcircuits.subcktUsed)];
				end %if
			end %for (k=1:nextvar)
			vnmatrix = add_nodes(nodeCorrector(nodes, nextvar));
			pvmatrix = subcircuits.subckts(subcir_ind).NLC(i).pvmatrix(l,:);
			[outstruct, count, idx] = addNLCelement(outstruct, count, element,...
									section, nextvar, npar, nparnames, parnames, vnmatrix, pvmatrix);
			ind = subcircuits.subckts(subcir_ind).totextvar + 1 + subcircuits.subckts(subcir_ind).LCR(i).osintvar(l) + subcircuits.subckts(subcir_ind).LCR(i).nintvar(l);
			aux = subcircuits.subckts(subcir_ind).namess(ind);
			int_name = [aux{1}(3:end-1) '-' dev_name '-' num2str(subcircuits.subcktUsed)];
			outstruct = NLCintvar(outstruct, idx, int_name);
		end %for
	end %for
	
	subcircuits.subcktUsed = subcircuits.subcktUsed + 1;
	
end %function

function [outstruct, count, line2] = prs_spice_dot (line, outstruct, count, fid, line2)
	%# .MODEL MNAME TYPE(PNAMEl = PVALl PNAME2 = PVAL2 ... )

	%# TYPE can be:
	%# R    resistor model
	%# C    capacitor model
	%# URC  Uniform Distributed RC model
	%# D    diode model
	%# NPN  NPN BIT model
	%# PNP  PNP BJT model
	%# NJF  N-channel JFET model
	%# PJF  P-channel lFET model
	%# NMOS N-channel MOSFET model
	%# PMOS P-channel MOSFET model
	%# NMF  N-channel MESFET model
	%# PMF  P-channel MESFET model
	%# SW   voltage controlled switch
	%# CSW  current controlled switch
	%# D    diode model	
  
	global models_list;
	global options;
	global temperature;

	[ind, model] = regexp (line, '.(MODEL|model)[\s]+(?<mname>[\S]+)[\s]+(?<mtype>[\S]+)[\s]+(?<prms>.+)', 'start', 'names');
	%model = regexp (line, '.MODEL[\s]+(?<mname>[\S]+)[\s]+(?<mtype>R|C|URC|D|NPN|PNP|NJF|PJF|NMOS|PMOS|NMF|PMF|SW|CSW)[\s]*\([\s]*(?<prms>.+)[\s]*\)', 'names');
	if (~isempty(ind))
		switch (model.mtype)
		case 'D'
			element = 'Mdiode';
		%%case 'NMOS'
		%%	element = 'Mnmosfet';
		otherwise
			syntaxError (line);
		end %switch

		if (strcmp(element, 'Mdiode'))
			section = 'PSpiceModel';
		else
			%# get model level (=section)
			[ind, level] = regexp (model.prms, 'LEVEL=(?<level>[\S]+)[\s]+(?<prms>.+)', 'start', 'names');
			if isempty (ind)
				section = 'simple';
			else
				section = level.level;
				model.prms = level.prms;
			end %if
		end %if

		midx = length (models_list.mname)+1;

		models_list.mname{midx} = model.mname;
		models_list.melement{midx} = element;
		models_list.msection{midx} = section;

		%# set model parameters
		ca = str2ca (model.prms);

		models_list.plist{midx} = struct ('pnames', {''}, 'pvalues', []);

		for prm_idx = 1:length (ca)/2
			%# save parameter name
			models_list.plist{midx}.pnames{prm_idx} = ca{2*prm_idx-1};
			%# save parameter value
			models_list.plist{midx}.pvalues = [models_list.plist{midx}.pvalues literal2num(ca{2*prm_idx})];
		end %for
	elseif (any(strfind(line, '.temp')>0) || any(strfind(line, '.TEMP')>0))
		%# Store temperature set
		[token, line] = strtok(line,' ');
		[token, line] = strtok(line,' ');
		temperature.T = literal2num(token) + 273.15; 
		if(~isempty(line))
			warn  = 'prs_spice: rest of given temperatures not considered:';
			fprintf([warn line '\n']);
		end
	elseif (any(strfind(line, '.OPTION')>0) || any(strfind(line, '.OPTION')>0))
		%# Store .OPTIONS line settings
		[s,e] = regexp(line, '(\S+\s*=\s*\S+\s*\s*)');
		n = size(options,1);
		for (i = n:length(s))
			tmp = regexp(line(s(i):e(i)),'\s*(\S+)\s*=\s*(\S+)\s*', 'tokens');
			options{i,1} = tmp{1}{1};
			options{i,2} = tmp{1}{2};
			%If nominal temperature is in .options, then: 
			if strcmp(tmp{1}{1}, 'TNOM')
				temperature.TNOM = literal2num(tmp{1}{2}) + 273.15;
			end %if
		end %for
		clear tmp;
	%#warn if .TRAN was found
	elseif (any(strfind(line,'.tran')>0) || any(strfind(line,'.TRAN')>0))
		[token, line] = strtok(line,' ');
		[token, line] = strtok(line,' ');
		if(~isempty(token))
			i = size(options,1) + 1;
			options{i,1} = 't1';
			options{i,2} = token;
			%options.values{i} = token;
		else
			error('prs_spice: No .TRAN values given\n');
		end %if
		[token, line] = strtok(line,' ');
		if(~isempty(token))
			options{i+1,1} = 't2';
			options{i+1,2} = token;
		else
			error('prs_spice: Invalid .TRAN values given\n');
		end %if
		if(~isempty(line))
			warn = ['prs_spice: rest of .TRAN line not considered:' line '.\n'];
			fprintf(warn);
		end  %if
		return
	elseif (any(strfind(line, '.stmlib')>0) || any(strfind(line, '.STMLIB')>0))
		%# Open and read file defining stimulus
		readStimFile(line);
	elseif (any(strfind(line, '.stimulus')>0) || any(strfind(line, '.STIMULUS')>0))
		%# Store stimulus values
		storeStimulus(line);
	%#warn if .backanno was found
	elseif (any(strfind(line, '.subckt')>0) || any(strfind(line, '.SUBCKT')>0))
		%# Store subcircuit in array
		line2 = addSbckt(line, outstruct, fid, line2); 
	elseif (any(strfind(line,'.backanno')>0) || any(strfind(line,'.BACKANNO')>0))
		warn = ['prs_spice: backannotation direction found.\n'];
		fprintf(warn)
		return
	%#warn if .ic was found
	elseif (any(strfind(line,'.ic')>0) || any(strfind(line, '.IC')>0))
		warn = ['prs_spice: initial condition found:' line(4:end) '.\n'];
		fprintf(warn)
		return
	elseif (any(strfind(line,'.end')>0) || any(strfind(line, '.END')>0))
		warn = ['prs_spice: End line found: ' line '\n'];
		fprintf(warn);
	else
		warn = ['prs_spice: line not considered:' line '\n'];
		fprintf(warn)
		return
	end %if #!isempty (model)
end %function

%# adds nodes to nodes_list and returns the indexes of the added nodes
function indexes = add_nodes (nodes)
	global nodes_list;
  
	global nodes_list_sbckt;
	global sbckt_bool;
  
	if(~sbckt_bool)
		for ii = 1:length (nodes)
			[tf, idx] = ismember (nodes(ii), nodes_list);
			if (tf)
				indexes(ii) = idx-1;
			else
				indexes(ii) = length (nodes_list);
				nodes_list{length (nodes_list)+1} = nodes{ii};
			end %if
		end %for
	else 
		for ii = 1:length (nodes)
			[tf, idx] = ismember (nodes(ii), nodes_list_sbckt);
			if (tf)
				indexes(ii) = idx-1;
			else
				indexes(ii) = length (nodes_list_sbckt);
				nodes_list_sbckt{length (nodes_list_sbckt)+1} = nodes{ii};
			end %if
		end %for
	end %if
	
end %function

function readStimFile(line)
	%# Read file containing stimulus and store them in array
	[token, line] = strtok(line, ' ');
	[token, line] = strtok(line, ' ');
	if (strcmp(token(1), '"') && strcmp(token(end), '"'))
		token = token(2:end-1);
	end
	stimfile = fopen(token, 'r');
	if(stimfile<=-1)
		error('prs_spice.m: Could not open Stimulus file!\n')
	end
	line = '';
    fullline = '';
    lineCounter = 0;
	
    while (~ feof (stimfile))
		line = fgets (stimfile);
		line = strtrim (line);

		%# exclude empty lines
		if length (line)
			%# exclude comments
			if (~ strncmpi (line, '*', 1))
			%# lines here aren't comments
				if (strncmpi (line, '+', 1))
					%# this line has to be concatenated to previous one
					line (1) = ' ';
					fullline = [fullline line];
				else
					%# these lines are not a concatenation
					if (length(fullline)>0)
						storeStimulus (fullline);
					end
					fullline = line;
				end %if (strncmpi (line, '+', 1))
			end %if (~strncmpi (line, '*', 1))
		end % if length (line)
    end % while ~feof (fid)

    %# parse last line
    if (length (fullline))
      storeStimulus(fullline);
    end
    fclose (stimfile);
end

function storeStimulus(line);
	%# Store read stimulus in array
	global stimulus_list;
	
	m = stimulus_list(1).len + 1;
	stimulus_list(1).len = m;
	stimulus = regexpi(line, '\.STIMULUS\s+(?<name>\S+)\s+(?<type>[^\s+]+)(?<parameters>(?:[\s\+]*\S*\s*=\s*\S*)+)[\s\+]*(?<funvalues>\(.*\))','names');
  
	stimulus_list(m).stimname = stimulus.name;
	stimulus_list(m).stimtype = stimulus.type;
  
	n = length(strfind(stimulus.parameters, '='));
	sep = '[\s\+]*(\S+)[\s=]*(\S)*';
	for i = 1:n-1
		sep = [sep sep];
	end
	stimulus.parameters = regexpi(stimulus.parameters, sep, 'tokens');
	TIME_SCALE_FACTOR = 1;
	VALUE_SCALE_FACTOR = 1;
	stimulus.parameters = stimulus.parameters{1};
	for i=1:n
		eval([stimulus.parameters{2*(i-1)+1} '=' stimulus.parameters{2*i} ';']);	
	end %for
  
	n = length(strfind(stimulus.funvalues,',')); 
	line = stimulus.funvalues;
	stimulus_list(m).params = zeros(1,2*n);
	for i = 1:n
		[token, line] = strtok(line,'+sAV(), \n'); 
		stimulus_list(m).params(i) = str2double(token)*TIME_SCALE_FACTOR;
		[token, line] = strtok(line,'+sAV(), \n');
		stimulus_list(m).params(n+i) = str2double(token)*VALUE_SCALE_FACTOR;
	end
     
end

function line2 = addSbckt(line, outstruct, fid, line2)
	%# Reads and stores subcircuit in array
	%#line: Contains the first line which starts with .subckt
	global subcircuits;
	global ndsvec_sbckt;
	global nodes_list_sbckt;
	global intvar_list_sbckt;
	global sbckt_bool;
	
	%#Set boolean to be inside a subcircuit.
	sbckt_bool = 1;
	
	count_sbckt = struct ('NLC', struct ('n', 0,...
                                'list', {''}),...
                  'LCR', struct ('n', 0,...
                                'list', {''}));
	
	n = subcircuits.subcktNum + 1;
	subcircuits.subcktNum = n;
	
	subcircuits.subckts(n).totextvar = 0;
	subcircuits.subckts(n).totintvar = 0;
	
	ca = str2ca(line);
	
	if(length(ca)>2)
		subcircuits.subcktName{n} = ca{2};
	else
		syntaxError(line);
	end
	for (ii=3:length(ca))
		subcircuits.subcktNodes{ii-2,n} = ca{ii};
	end
	
	lin = '';
	fullline = line2;
	fullline = strtrim(fullline);
	lineCounter = 0;
	%# Read all lines containing the subcircuit
	while (~feof(fid) && ~strcmp(fullline, '.ends') && ~strcmp(fullline, '.ENDS'))
			%# exclude empty lines
			if length (lin)
				%# exclude comments
				if (~strncmpi (lin, '*', 1))
					%# lines here aren't comments
					if (strncmpi (lin, '+', 1))
						%# this line has to be concatenated to previous one
						lin (1) = ' ';
						fullline = [fullline lin];
					else
						%# these lines are not a concatenation

						%# line echo for debug
						%# disp (fullline);

						%# compute fullline here!
						%#[outstruct, intvar, count] = lineParse (upper (fullline), outstruct, count, intvar);

						%# NB: case-sensitive because of parameter names
						%#[outstruct, intvar, count] = lineParse (fullline, outstruct, intvar, count);
						[subcircuits.subckts(n), count_sbckt, lin] = lineParse (fullline, subcircuits.subckts(n), count_sbckt, fid, lin);
						fullline = lin;
					end %if (strncmpi (line, '+', 1))
				end %if (~strncmpi (line, '*', 1))
			end % if length (line)
			lin = fgets (fid);
			lin = strtrim (lin);
			lineCounter = lineCounter+1;
	end % while ~feof (fid)

		%# parse last line
	if (length (fullline)  && ~strcmpi(fullline, '.ends'))
      %# NB: case-sensitive because of parameter names
      %#[outstruct, intvar, count] = lineParse (upper (fullline), outstruct, count, intvar);
      %#[outstruct, intvar, count] = lineParse (fullline, outstruct, intvar, count);
      [subcircuits.subckts(n), count_sbckt, lin] = lineParse (fullline, subcircuits.subckts(n), count_sbckt, fid, lin);
    end
	
	nnodes = length (unique (ndsvec_sbckt));
	maxidx = max (ndsvec_sbckt);

	if  (nnodes <= (maxidx+1))
		%# If the valid file is a subcircuit it may happen
		%# that nnodes == maxidx, otherwise nnodes == (maxidx+1)
		subcircuits.subckts(n).totextvar = max (ndsvec_sbckt);
	else
		error ('prs_spice: hanging nodes in circuit %s', subcircuits.subcktName{n});
	end %if

	%# set node names as variable names
	for ii = 1:length (nodes_list_sbckt)
		subcircuits.subckts(n).namesn (ii) = ii-1;
	end %for
	subcircuits.subckts(n).namess = horzcat (nodes_list_sbckt, intvar_list_sbckt);
	
	%#boolean return to not being in subcircuit
	sbckt_bool = 0;
	%#Return global variables to original state.
	ndsvec_sbckt = [];
	nodes_list_sbckt = {'0'};
	intvar_list_sbckt = {};
	
	if(~feof(fid))
		line2 = lin;
		while(~feof(fid) && (~length(line2) || strncmpi(line2,'*',1)))
			line2 = fgets(fid);
			line2 = strtrim(line2);
		end %while
	end %if
	
end

% dummy functions such that ocs is not needed
function [a,b,c] = Minductors (varargin)
  a = zeros(4);
  b = zeros(4);
  c = zeros(4);
end%function
function [a,b,c] = Mcapacitors (varargin)
  a = zeros(3);
  b = zeros(3);
  c = zeros(3);
end%function
function [a,b,c] = Mresistors (varargin)
  a = zeros(2);
  b = zeros(2);
  c = zeros(2);
end%function
function [a,b,c] = Mvoltagesources (varargin)
  a = zeros(3);
  b = zeros(3);
  c = zeros(3);
end%function
function [a,b,c] = Mcurrentsources (varargin)
  a = zeros(2);
  b = zeros(2);
  c = zeros(2);
end%function


%!demo
%! outstruct = prs_spice ("rlc");
%! vin = linspace (0, 10, 10);
%! x = zeros (outstruct.totextvar+outstruct.totintvar, 1);
%!
%! for idx = 1:length (vin)
%!   outstruct.NLC(1).pvmatrix(1) = vin(idx);
%!   out = nls_stationary (outstruct, x, 1e-15, 100);
%!   vout(idx) = out(2);
%! end
%!
%! plot (vin, vout);
%! grid on;

%!demo
%! ## Circuit
%! 
%! cir = menu ("Chose the circuit to analyze:",
%! 	       "AND (Simple algebraic MOS-FET model)",
%! 	       "AND (Simple MOS-FET model with parasitic capacitances)",
%! 	       "Diode clamper (Simple exponential diode model)",
%! 	       "CMOS-inverter circuit (Simple algebraic MOS-FET model)",
%! 	       "n-MOS analog amplifier (Simple algebraic MOS-FET model)",
%! 	       "Linear RC circuit",
%! 	       "Diode bridge rectifier",
%!             "RLC circuit");
%! 
%! switch cir
%!   case 1
%!     outstruct = prs_spice ("and");
%!     x         = [.5 .5 .33 .66 .5 1 0 0 1 ]';
%!     t         = linspace (0, .5, 100);
%!     pltvars   = {"Va", "Vb", "Va_and_b"};
%!     dmp       = .2;
%!     tol       = 1e-15;
%!     maxit     = 100;
%!   case 2
%!     outstruct = prs_spice ("and2");
%!     x         = [.8;.8;0.00232;0.00465;.8;
%! 		 .8;0.00232;0.00465;0.00000;
%! 		 0.0;0.0;0.0;0.00232;0.0;
%! 		 0.0;0.0;0.0;1.0;0.0;-0.0;
%! 		 0.0;1.0;0.00465;0.0;0.0;
%! 		 -0.0;1.0;0.00465;0.0;
%! 		 0.0;0.0;1.0;1.0;0.0;0.0;0.0;
%! 		 0.0;0.0;0.0];
%!     t       = linspace (.25e-6, .5e-6, 100);
%!     dmp     = .1;
%!     pltvars = {"Va", "Vb", "Va_and_b"};
%!     tol     = 1e-15;
%!     maxit   = 100;
%!   case 3
%!     outstruct = prs_spice ("diode");
%!     x   = [0 0 0 0 0]';
%!     t   = linspace (0, 3e-10, 200);
%!     dmp = .1;
%!     pltvars = {"Vin", "Vout", "V2"};
%!     tol   = 1e-15;
%!     maxit = 100;
%!   case 4
%!     outstruct = prs_spice ("inverter");
%!     x   = [.5  .5   1   0   0]';
%!     t   = linspace (0, 1, 100);
%!     dmp = .1;
%!     pltvars={"Vgate", "Vdrain"};
%!     tol   = 1e-15;
%!     maxit = 100;
%!   case 5
%!     outstruct = prs_spice ("nmos");
%!     x         = [1 .03 1 0 0]';
%!     t         = linspace (0, 1, 50);
%!     dmp       = .1;
%!     pltvars   = {"Vgate", "Vdrain"};
%!     tol   = 1e-15;
%!     maxit = 100;
%!   case 6
%!     outstruct = prs_spice ("rcs");
%!     x         = [0 0 0 0]';
%!     t         = linspace (0, 2e-5, 100);
%!     dmp       = 1;
%!     pltvars   = {"Vout"};
%!     tol   = 1e-15;
%!     maxit = 100;
%!   case 7
%!     outstruct = prs_spice ("rect");
%!     x         = [0 0 0 0 ]';
%!     t         = linspace (0, 3e-10, 60);
%!     dmp       = .1;
%!     pltvars   = {"Vin", "Voutlow", "Vouthigh"};
%!     tol   = 1e-15;
%!     maxit = 100;
%!   case 8
%!     outstruct = prs_spice ("rlc")
%!     #x         = [0 0 0 0 0]';
%!     #x         = [0 0 0 ]';
%!     #x         = [0 0 0 0]';
%!     x         = [0 0 0 0 0 0 ]';
%!     t         = linspace (0, 2e-5, 200);
%!     dmp       = 1;
%!     #pltvars   = {"Vin", "Vout"};
%!     pltvars   = {"I(C3)"};
%!     #pltvars   = {"Vout"};
%!     tol   = 1e-15;
%!     maxit = 100;
%!   otherwise
%!     error ("unknown circuit");
%! end %switch
%! 
%! clc;
%! slv = menu("Chose the solver to use:",
%! 	   "BWEULER", # 1
%! 	   "DASPK",   # 2
%! 	   "THETA",   # 3
%! 	   "ODERS",   # 4
%! 	   "ODESX",   # 5
%! 	   "ODE2R",   # 6
%! 	   "ODE5R"    # 7
%! 	   );
%! 
%! out   = zeros (rows (x), columns (t));
%! 
%! switch slv
%!   case 1
%!     out = tst_backward_euler (outstruct, x, t, tol, maxit, pltvars);
%!     # out = TSTbweuler (outstruct, x, t, tol, maxit, pltvars);
%!   case 2
%!     out = tst_daspk (outstruct, x, t, tol, maxit, pltvars);
%!     # out = TSTdaspk (outstruct, x, t, tol, maxit, pltvars);
%!   case 3
%!     out = tst_theta_method (outstruct, x, t, tol, maxit, .5, pltvars, [0 0]);
%!     # out = TSTthetamethod (outstruct, x, t, tol, maxit, .5, pltvars, [0 0]);
%!   case 4
%!     out = tst_odepkg (outstruct, x, t, tol, maxit, pltvars, "oders", [0, 1]);
%!     # out = TSTodepkg (outstruct, x, t, tol, maxit, pltvars, "oders", [0, 1]);
%!   case 5
%!     out = tst_odepkg (outstruct, x, t, tol, maxit, pltvars, "odesx", [0, 1]);
%!     # out = TSTodepkg (outstruct, x, t, tol, maxit, pltvars, "odesx", [0, 1]);
%!   case 6
%!     out = tst_odepkg (outstruct, x, t, tol, maxit, pltvars, "ode2r", [0, 1]);
%!     # out = TSTodepkg (outstruct, x, t, tol, maxit, pltvars, "ode2r", [0, 1]);
%!   case 7
%!     out = tst_odepkg (outstruct, x, t, tol, maxit, pltvars, "ode5r", [0, 1])
%!     # out = TSTodepkg (outstruct, x, t, tol, maxit, pltvars, "ode5r", [0, 1])
%!   otherwise
%!     error ("unknown solver");
%! end %switch
%! 
%! #utl_plot_by_name (t, out, outstruct, pltvars);
%! utl_plot_by_name (t, out, outstruct, pltvars);
%! axis ("tight");
