%% Question 1

clear;
close all;
clc;

ZL = input("Enter the load impedance: ");
Z0 = input("Enter the line impedance: ");
ZS = input("Enter the characteristic impedance of the stub line: ");
f = input("Enter the matching frequency: ");
n = input("Enter the stub model (1 for SC, 2 for OC): ");

c = 3 * 10^8;
lambda = c / f;
beta = 2 * pi / lambda;

Y0 = 1/Z0;
Y_eq = @(l) 1./Z_eq(Z0, ZL, beta, l);
stub1 = @(l) Y0 - real(Y_eq(l));
L1 = fzero(stub1, [0 lambda/4]);
L2 = fzero(stub1, [lambda/4 lambda/2]);

if n == 1
    Y_sc = @(ls) 1./(1j*ZS*tan(beta.*ls));
    stub2_1 = @(ls) imag(Y_eq(L1)) + imag(Y_sc(ls));
    stub2_2 = @(ls) imag(Y_eq(L2)) + imag(Y_sc(ls)); 
    ls1 = fzero(stub2_1, [lambda/100 lambda/2-lambda/100]);
    ls2 = fzero(stub2_2, [lambda/100 lambda/2-lambda/100]);
elseif n == 2
	Y_oc = @(ls) 1./(-1j.*ZS*cot(beta.*ls));
    stub2_1 = @(ls) imag(Y_eq(L1)) + imag(Y_oc(ls));
    stub2_2 = @(ls) imag(Y_eq(L2)) + imag(Y_oc(ls)); 
    ls1 = fzero(stub2_1, [-lambda/4+lambda/100 lambda/4-lambda/100]);
    ls2 = fzero(stub2_2, [-lambda/4+lambda/100 lambda/4-lambda/100]);
else
    disp("Invalid Input!");
end

if L1 >= 0 && ls1 >= 0
    fprintf("Distance from Load to Stub: %f m", L1);
    fprintf('\n');
    fprintf("Corresponding ls: %f m", ls1);
    fprintf('\n');
end
if L2 >= 0 && ls2 >= 0
    fprintf("Distance from Load to Stub: %f m", L2);
    fprintf('\n');
    fprintf("Corresponding ls: %f m", ls2);
    fprintf('\n');
end
if (L1 < 0 || ls1 < 0) && (L2 <0 || ls2 < 0)
    disp("Matching with these inputs is impossible!");
end

%% Question 2

F = 0 : f/100 : 2*f;
lambda = c ./ F;
beta = 2 * pi ./ lambda;

L = L1;
ls = ls1;
Y = 1./Z_eq(Z0, ZL, beta, L);
Y_sc = 1./(1j*ZS*tan(beta.*ls));
Y_oc = 1./(-1j.*ZS*cot(beta.*ls));

if n == 1
    Y_in = Y + Y_sc;
elseif n == 2
    Y_in = Y + Y_oc;
end
Z_in = 1./Y_in;

gamma = (Z0 - Z_in)./(Z0 + Z_in);

figure;
plot(F, Z_in, 'linewidth', 2);
title('$Z_{in}$', 'interpreter', 'latex');
xlabel('frequency', 'interpreter', 'latex');

figure;
plot(F, abs(gamma), 'linewidth', 2);
title('$\Gamma$', 'interpreter', 'latex');
xlabel('frequency', 'interpreter', 'latex');

%% Function

function Z_eq = Z_eq(Z0, ZL, beta, l)
    Z_eq = Z0 * ((ZL*cos(beta.*l) + 1j*Z0*sin(beta.*l))./(Z0*cos(beta.*l) + 1j*ZL*sin(beta.*l)));
end
