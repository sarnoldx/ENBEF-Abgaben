function [pc]=fit_pe2pc(xmesh,ymesh,zmesh,pe,idxV)
  nx = length(xmesh);
  ny = length(ymesh);
  nz = length(zmesh);
  np=nx*ny*nz;
  pc=zeros(np,3);
  pc(idxV,1)=(pe(     idxV)+pe(     idxV+nx)+pe(    idxV+nx*ny)+pe(     idxV+nx*ny+nx))/4;
  pc(idxV,2)=(pe(  np+idxV)+pe(  np+idxV+1)+pe(  np+idxV+nx*ny)+pe(  np+idxV+nx*ny+1))/4;
  pc(idxV,3)=(pe(2*np+idxV)+pe(2*np+idxV+1)+pe(2*np+idxV+nx)   +pe(2*np+idxV+nx+1))/4;
end