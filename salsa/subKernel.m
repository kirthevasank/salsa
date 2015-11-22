function K = subKernel(X1, X2, coords, bw, scale)
% Each of the small kernels is only affected by a subset of the coordinates.
% So we need to make sure that the output of the kernel only depends on these
% quantities. This is what this function is doing.

  % Sometimes we get the entire X (with all coordinates) sometimes we only get
  % the relevant coordinates. Check for this condition.
  if size(X1, 2) == numel(coords), X1sub = X1;
  else, X1sub = X1(:, coords);
  end
  if size(X2, 2) == numel(coords), X2sub = X2;
  else, X2sub = X2(:, coords);
  end

  D = dist2(X1sub, X2sub);
  K = scale * exp( -0.5*D/bw^2);
end

