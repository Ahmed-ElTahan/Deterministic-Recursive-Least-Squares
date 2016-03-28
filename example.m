%
%{
        This is an example to show how to use the RecursiveLeastSquares (RLS)
        function. At first, Imagine that I have a transfer function that I
        know its parameters and its orders (na, nb and d). By exciting its output with a certain input
        which is here is a damped sine, I can get the input and output of
        this dynamic system as similar as an experiment. Now I use these
        input and output vectors with the RLS algorithm to estimate the
        parameters
%}
clc; clear all; close all;

% Gathering the input and the output of the original system

%% Input Initialization
Ts = 0.2; % sample time
t = 0:Ts:50;
b = 0.4;
a = 2;
w = 2*pi/2.5; %rad/s
u = a*exp(-b*t).*sin(w*t);
u = u';

%% Transfer function preparation
s = tf('s');
Gs = 0.5/(s^2+s+1);
Gz = c2d(Gs, 0.2, 'zoh');
[num, den] = tfdata(Gz);
num = cell2mat(num);
den = cell2mat(den);

na = length(den) -1;
iodel = get(Gz, 'iodelay'); %input output delay
d = max(find(num ==0))+iodel; % total delay
nb = length(num) - max(find(num ==0)) - 1;
num = num(max(find(num ==0))+1:end); % to remove zeros at the first (comes from delay)
nu = na + nb + 1;

% Calculating A, B of the system
Asys = 1;
for i = 1: na
    Asys(i+1) = den(i+1);
end
        
for i = na+1:nu
    Bsys(i-na) = num(i-na);
end
         


%% Output Initialization
y = zeros(length(t), 1);
for i = 1 : length(t)
    y(i) = outputestimation( Asys, Bsys, d, u, y, i );
end
y = y';





%% Estimation using RecursiveLeastSquares function
%comment what you don't want to estimate
% [ theta, Gz_estm ] = RecursiveLeastSquares( u, y,  1, 1, 1, Ts) % 1st order estimation
[ theta, Gz_estm ] = RecursiveLeastSquares( u, y, 2, 1, 1, Ts) % 2nd order estimation
