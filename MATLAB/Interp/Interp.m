function y=Interp(x,factor)
cutoff = double(1);
n = double(10);
idata = x;
r = double(factor);
%[~,coeff]=interp(x,factor,10,1);
% y=upsample(x,factor);
% y = filter(coeff,1,y);
% calculate AP and AM matrices for inversion
s1 = toeplitz(0:n-1) + eps;
s2 = hankel(2*n-1:-1:n);
s2p = hankel([1:n-1 0]);
s2 = s2 + eps + s2p(n:-1:1,n:-1:1);
s1 = sin(cutoff*pi*s1)./(cutoff*pi*s1);
s2 = sin(cutoff*pi*s2)./(cutoff*pi*s2);
ap = s1 + s2;
am = s1 - s2;

% Compute matrix inverses using Cholesky decomposition for more robustness
U = chol(ap);
ap = inv(U)*inv(U).';
U = chol(am);
am = inv(U)*inv(U).';

cName = 'double';
% now calculate D based on INV(AM) and INV(AP)
d = zeros(2*n,n,cName);
%d = zeros(2*n,n,cName);
d(1:2:2*n-1,:) = ap + am;
d(2:2:2*n,:) = ap - am;

% set up arrays to calculate interpolating filter B
x = (0:r-1)/r;
%y = zeros(2*n,1,cName);
y = zeros(2*n,1,cName);
y(1:2:2*n-1) = (n:-1:1);
y(2:2:2*n) = (n-1:-1:0);
X = ones(2*n,1,cName);
X(1:2:2*n-1) = -ones(n,1,cName);
XX = eps + y*ones(1,r,cName) + X*x;
y = X + y + eps;
h = .5*d'*(sin(pi*cutoff*XX)./(cutoff*pi*XX));
b = zeros(2*n*r+1,1,cName);
b(1:n*r) = h';
b(n*r+1) = .5*d(:,n)'*(sin(pi*cutoff*y)./(pi*cutoff*y));
b(n*r+2:2*n*r+1) = b(n*r:-1:1);

% use the filter B to perform the interpolation
[mm,mn] = size(idata);
nn = max([mm mn]);
if nn == mm
   odata = complex(zeros(1,r*nn,cName),zeros(r*nn,1,cName));
else
   odata = complex(zeros(1,r*nn,cName),zeros(1,r*nn,cName));
end
%odata = complex(zeros(1,length(idata)*r,zeros(1,length(idata)*r)));
odata(1:r:nn*r) = idata;
% Filter a fabricated section of data first (match initial values and first derivatives by
% rotating the first data points by 180 degrees) to get guess of good initial conditions
% Filter length is 2*l*r+1 so need that many points; can't duplicate first point or
% guarantee a zero slope at beginning of sequence
od = complex(zeros(2*n*r,1,cName),zeros(2*n*r,1,cName));
od(1:r:(2*n*r)) = 2*idata(1)-idata((2*n+1):-1:2);
[od,zi] = filter(b,1,od); %#ok
[odata,zf] = filter(b,1,odata,zi);
odata(1:(nn-n)*r) = odata(n*r+1:nn*r);

% make sure right hand points of data have been correctly interpolated and get rid of
% transients by again matching end values and derivatives of the original data
if nn == mm
	od = zeros(2*n*r,1,cName);
else
	od = zeros(1,2*n*r,cName);
end
od(1:r:(2*n)*r) = 2*idata(nn)-(idata((nn-1):-1:(nn-2*n)));
od = filter(b,1,od,zf,1);
odata(nn*r-n*r+1:nn*r) = od(1:n*r);
y = odata;
end