% This script is for training salsa on different datasets.
% Unfortunately we cannot release all datasets used in the paper since not all of
% them were publicly available.

close all;
clear all;
clc;
addpath ../salsa/
rng('default');
warning off;

% Select dataset
dataset = 'galaxy';       
% dataset = 'skillcraft';
% dataset = 'airfoil';
% dataset = 'CCPP';
% dataset = 'Insulin';
% dataset = 'speech';              
% dataset = 'forestfires';       
% dataset = 'housing';                  
% dataset = 'blog';       
% dataset = 'music';                    
% dataset = 'telemonitoring-total';
% dataset = 'propulsion';       

% Load data
[Xtr, Ytr, Xte, Yte] = getDataset(dataset);
[nTr, numDims] = size(Xtr);
nTe = size(Xte, 1);

fprintf('Dataset: %s (n, D) = (%d, %d)\n', dataset, nTr, numDims);

% Now run SALSA
fprintf('Training with SALSA\n');
tic,
[predFunc, addOrder] = salsa(Xtr, Ytr);
toc,
YPred = predFunc(Xte);

% Print out results
predError = norm(YPred-Yte).^2/nTe;
fprintf('MSE: %0.5f\nOrder chosen by CV: %d\n', predError, addOrder);

