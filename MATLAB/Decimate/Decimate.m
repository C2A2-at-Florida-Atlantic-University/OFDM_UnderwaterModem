function y=Decimate(x,Factor)
%y=decimate(x,factor,1024,'fir');

idata = x;
r = Factor;
nfilt = 1024;

nd = length(idata);
m = size(idata,1);
nout = ceil(nd/r);

% FIR filter
b = fir1(nfilt,1/r);
% prepend sequence with mirror image of first points so that transients
% can be eliminated. then do same thing at right end of data sequence.
nfilt = nfilt+1;
itemp = 2*idata(1) - idata((nfilt+1):-1:2);
[itemp,zi]=filter(b,1,itemp,[],1); %#ok
[odata,zf] = filter(b,1,idata,zi,1);
if m == 1	% row data
    itemp = zeros(1,2*nfilt);
else	% column data
    itemp = zeros(2*nfilt,1);
end
itemp(:) = 2*idata(nd)-idata((nd-1):-1:(nd-2*nfilt));
itemp = filter(b,1,itemp,zf,1);
% finally, select only every r'th point from the interior of the lowpass
% filtered sequence
gd = grpdelay(b,1,8);
list = round(gd(1)+1.25):r:nd;
odata = odata(list);
lod = length(odata);
nlen = nout - lod;
nbeg = r - (nd - list(length(list)));
if m == 1	% row data
    odata = [odata itemp(nbeg:r:nbeg+nlen*r-1)];
else
    odata = [odata; itemp(nbeg:r:nbeg+nlen*r-1)];
end
y=odata;
end