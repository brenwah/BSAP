function [x1,x2] = myRipple(start, finish, rpo)
freq=start:20:finish;
%rpo=1;
mag=abs(sin(2*pi*(rpo/0.6)*(log10(freq)-2)));
semilogx(freq,mag)
hold on
mag1=abs(sin(2*pi*(rpo/0.6)*(log10(freq)-2)+pi/2));
semilogx(freq,mag1)
hold off

x1=10.^(((mag*30)-30)/20);
x2=10.^(((mag1*30)-30)/20);
semilogx(freq,x2);
hold on
semilogx(freq,x1);
hold off
