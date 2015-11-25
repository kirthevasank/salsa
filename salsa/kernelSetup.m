function [kernelFunc, decomposition, bandwidths, scales] = ...
  kernelSetup(X, Y, decomposition)
% X, Y: covariates and labels. As is, the Y's aren't really used but passing
%       them here in case we need to design kernels (later on) using Y.
% decomposition: A struct which contains info on how to construct the
%   decomposition. Read obtainDecomposition.
% Here we use the newton-girard trick and elementary symmetric
% polynomials to compute all k^th order interactiosn for k = 1:D

  % Prelims
  n = size(X, 1);
  numDims = size(X, 2);

  if ~isfield(decomposition, 'order') || isempty(decomposition.order)
        order = min(10, ceil(numDims/2));
  else, order = decomposition.order;
  end
  if ~isfield(decomposition, 'bws') || isempty(decomposition.bws)
        bws = 20 * std(X) * n^(-1/5);
  else, bws = decomposition.bws;
  end
  kernelFunc = @(X1, X2) espKernels(X1, X2, bws, order);
  decomposition.M = order;

end

