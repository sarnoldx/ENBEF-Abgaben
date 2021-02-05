%# Copyright (C) 2006-2009 Sebastian Schoeps 
%#
%# This file is part of:
%# FIDES - Field Device Simulator
%#
%# FIDES is free software; you can redistribute it and/or modify
%# it under the terms of the GNU General Public License as published by
%# the Free Software Foundation.
%#
%# This program is distributed in the hope that it will be useful,
%# but WITHOUT ANY WARRANTY; without even the implied warranty of
%# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%# GNU General Public License for more details.
%#
%# You should have received a copy of the GNU General Public License
%# along with this program (see the file LICENSE); if not,
%# see <http://www.gnu.org/licenses/>.
%#
%# modified-by: schoeps@math.uni-wuppertal.de

%# -*- texinfo -*- 
%# @deftypefn {Function File} {[pc] =} @
%# fit_pf2pc (@var{xmesh}, @var{ymesh}, @var{zmesh}, @var{pf}, @var{idxV})
%#
%# averages the vector data @var{pf} located at primary facets to@
%# the data @var{pc} located in the center points of primary cells
%# (i.e. dual point)
%# 
%# Input:
%# @itemize
%#  @item @var{xmesh} = FIT mesh in x-direction [m]
%#  @item @var{ymesh} = FIT mesh in y-direction [m]
%#  @item @var{zmesh} = FIT mesh in z-direction [m]
%#  @item  @var{pf} = vector data at facets (3np-by-1 or np-by-3)
%#  @item  @var{idxV} = indeces of existing cells (e.g. from @code{fit_dof}) 
%# @end itemize
%#
%# Output:
%# @itemize
%#  @item  @var{pc} = vector data at primary cell centers (np x 1)
%# @end itemize
%#
%# @seealso{ fit_dof, fit_pf2pc, fit_pp2pc }
%#
%# @end deftypefn

function pc=fit_pf2pc(xmesh,ymesh,zmesh,pf,idxV)

  %# number of points in each direction
  nx = length(xmesh);
  ny = length(ymesh);
  nz = length(zmesh);

  %# problem size
  np=nx*ny*nz;
  
  % reshape integrated quantities from 3np-by-1 to np-by-3 
  if size(pf,2)==1
    pf = reshape(pf,[],3);
  end

  %# averaging
  pc=zeros(np,3);
  pc(idxV,1)=(pf(idxV,1)+pf(idxV+1,1))/2;
  pc(idxV,2)=(pf(idxV,2)+pf(idxV+nx,2))/2;
  pc(idxV,3)=(pf(idxV,3)+pf(idxV+nx*ny,3))/2;

end %function

%!
%!# Shared variables
%!shared prb
%!  prb.X=1:2; prb.Y=1:2; prb.Z=1:2;
%!  
%!# comparison with a one volume example (3np-by-1 input)
%!test
%!  [pc]=fit_pf2pc(prb.X,prb.Y,prb.Z,ones(24,1),1);
%!  assert (pc(1,:),[1 1 1]);
%!  assert (pc(2:end,:),zeros(7,3));
%!
%!# same example (np-by-3 input)
%!test
%!  [pc]=fit_pf2pc(prb.X,prb.Y,prb.Z,ones(8,3),1);
%!  assert (pc(1,:),[1 1 1]);
%!  assert (pc(2:end,:),zeros(7,3));