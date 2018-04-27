function xp = GENCLS(t,x)
global GLO
xp = zeros(size(x));

dta = x(1:2:end,1);
omg = x(2:2:end,1);


Exp = cos(dta).*GLO.Ef;
Eyp = sin(dta).*GLO.Ef;

Ei = Exp + 1i*Eyp;
Pe = real(Ei.*conj(GLO.Yi*Ei));
xp(1:2:end,1) = 2*pi*60*omg;
xp(2:2:end,1) = GLO.w0*(GLO.Pm - Pe - GLO.D.*omg/GLO.w0)./(2*GLO.H);
end
