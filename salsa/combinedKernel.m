function [K, allKs] = combinedKernel(X1, X2, groups, bws, scales)
% This computes all sub kernels and the sum Kernel K.
% groups is a numGroups size 

  numGroups = numel(groups);
  n1 = size(X1, 1);
  n2 = size(X2, 1);
  K = zeros(n1, n2);
  allKs = zeros(n1, n2, numGroups);

  for k = 1:numGroups
    coords = groups{k};
    bw = bws(k);
    scale = scales(k);
    allKs(:,:,k) = subKernel(X1, X2, coords, bw, scale);
  end

  % Now sum all the Kernels.
  K = sum(allKs, 3);

end

