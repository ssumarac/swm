function PsC_score = PsC(template,sig)
%% Psuedo_Correlation
% Computes the Pseudo Correlation , a finer approach than normal
% correlation for template matching. Please review the paper below in order
% to see why it is much more accurate for the pattern recognition
%% Input
% template : template to be searched in the signal
% sig: the signal that we are searching the template in
% lag : does PsC for the lag between -lag : lag, it should be in samples,
% for example half the length of the input signal
%% Output :
% PsC_score : maximum score at best lag
%% Algorithm is based on the following paper :
% H. Sedghamiz and Daniele Santonocito,'Unsupervised Detection and
% Classification of Motor Unit Action Potentials in Intramuscular
% Electromyography Signals', The 5th IEEE International Conference on
% E-Health and Bioengineering - EHB 2015, At Iasi-Romania.
%% Author:
% Hooman Sedghamiz
% June 2015, Linkoping University
% Please cite the paper if any of the methods were helpfull

%% Script Begins here, Do not Change
%%

template = template(:);
sig = sig(:);

m = length(template);
n = length(sig);

if m > n
    error('Length of Template should be equal or smaller than pattern');
end

p4 = zeros(1,m);
normaliz = zeros(1,m);
PsC_score = zeros(1,n);

for i = 1 : m
    p1 = (template(i)*sig(i));
    p2 = abs(template(i) - sig(i));
    p3 = max(abs(template(i)),abs(sig(i)));
    p4(i) = (p1 - p2*p3);
    normaliz(i) = p3^2;
end

PsC_score = max(sum(p4)/sum(normaliz),0);


end