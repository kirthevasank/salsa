function [K, allKs] = espKernels(X, Y, bws, order)
% Computes Kernels using elementary symmetric polynomials.
% Each "base" kernel acts on one dimension and has bandwidth bws(i).

  % prelims
  [n, D] = size(X);
  m = size(Y, 1);

  if nargin < 4
    order = D;
  end

  % create base kernels
  baseKernels = zeros(n, m, D);
  for i = 1:D
    Dists = dist2(X(:,i), Y(:,i));
    baseKernels(:,:,i) = exp( -0.5 * Dists/ bws(i)^2 ); 
  end

  % Now construct the ESP kernels
  allKs = elemSymPoly(baseKernels, order);
  allKs = allKs(:,:,2:end);

  % Compute the final kernel
  K = allKs(:,:,end); % just pass this for now.
%   K = sum(allKs, 3); % pass the sum.

end


% This computes elementary symmetric polynomials using the Newton Girard
% formulae.
function E = elemSymPoly(X, order)
% X is an nxmxD matrix.
% The function returns an nxmx(order+1) matrix of the computed esp values.

  [n, m, D] = size(X);
  order = min(order, D);

  % First create the power sums
  P = zeros(n, m, order);
  S = ones(n, m, D);
  for k = 1:order
    S = S .* X;
    P(:,:,k) = sum(S, 3);
  end

  % Now obtain the ESPs.
  E = zeros(n, m, order+1);
  E(:,:,1) = 1;

  for k = 1:order

    Ek = zeros(n, m);
    for i = 1:k
      Ek = Ek + (-1)^(i-1) * E(:,:,k-i+1) .* P(:,:,i);
    end
    Ek = Ek/k;

    % Finally save the result
    E(:,:,k+1) = Ek;

  end

end

