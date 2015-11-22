function [predFunc, addOrder] = salsa(X, Y, params)
% This function implements SALSA: Shrunk Additive Least Squares Approximations.
% Refer the paper for more details.
% Inputs:
%   (X, Y): The training data and labels
%   params: A structure which optionally contain the following hyper-parameters
%     - numPartsKFoldCV: Number of partitions for K-Fold cross validation (CV).
%     - numTrialsKFoldCV: Number of partitions to average the CV error over.
%     - numLambdaCands: Number of candidate values for the penalty parameter lambda.
%     - lambdaRange: A range within which the candidates for lambda will be selected
%         with logarithmic spacing.
%     - orderCands: Candidate values for the additive order.
% Outputs:
%   predFunc: A function handle which can be used to estimate the function for new
%             points.
%   addOrder: The order of the additive model chosen.
% Our implementation sets the kernel bandwidth using the heuristic prescribed in the
% paper. We cross validate to choose the additive order and lambda.

  % prelims
  [n, D] = size(X);

  % shuffle Data
  shuffleOrder = randperm(n);
  X = X(shuffleOrder, :);
  Y = Y(shuffleOrder, :);

  % Params for CV
  if ~exist('params', 'var') | isempty(params)
    params = struct();
  end
  if ~isfield(params, 'numPartsKFoldCV')
    params.numPartsKFoldCV = 5;
  end
  if ~isfield(params, 'numTrialsKFoldCV')
    params.numTrialsKFoldCV = 2;
  end
%   if ~isfield(params, 'numLambdaCands')
%     params.numLambdaCands = 10;
%   end
  if ~isfield(params, 'lambdaRange')
    params.lambdaRange = [1e-4 100] * n;
  end
  if ~isfield(params, 'orderCands')
    params.orderCands = 1:D;
  end
  % Copy over to workspace
%   numLambdaCands = params.numLambdaCands;
  orderCands = params.orderCands;
  numOrderCands = numel(params.orderCands);
  lambdaRange = params.lambdaRange;

  % Set some parameters for the kernels
  decomp.setting = 'espKernel';
  if isfield(params, 'bws'), decomp.bws = params.bws; end

  % Now for each order determine the best Lambda and validation error
  bestValidErr = inf;
  notDecCounter = 0;
  for orderIter = 1:numOrderCands
    currOrder = orderCands(orderIter);
    [currValidErr, currBestLambda] = cvForOrder(X, Y, lambdaRange, currOrder, ...
      decomp, params.numPartsKFoldCV, params.numTrialsKFoldCV);
    if bestValidErr > currValidErr
      notDecCounter = 0;
      bestValidErr = currValidErr;
      bestLambda = currBestLambda;
      addOrder = currOrder;
    else
      notDecCounter = notDecCounter + 1;
      if notDecCounter >= 3, break; end
    end

  end

  % Print out
  fprintf('addKRR: Chosen (lambda, order) = (%.5f, %d)\n', bestLambda, addOrder);

  % Finally optimise over all data
  yScale = getYScale(Y);
  decomp.order = addOrder;
  kernelFunc = kernelSetup(X, Y, decomp);
  scaledKernelFunc = @(X1, X2) yScale * kernelFunc(X1, X2);
  K = scaledKernelFunc(X, X);
  alpha = (K + bestLambda*eye(n))\Y;
  predFunc = @(arg) predictKRR(arg, X, scaledKernelFunc, alpha);

end


function [bestValidErr, bestLambda] = cvForOrder(X, Y, lambdaRange, order, decomp,...
  numPartsKFoldCV, numTrialsKFoldCV)

  fprintf('Order: %d, ', order);
  % First construct the kernel for this order
  yScale = getYScale(Y);
  decomp.order = order;
  kernelFunc = kernelSetup(X, Y, decomp);
  scaledKernelFunc = @(X1, X2) yScale * kernelFunc(X1, X2);
  % compute the entire kernel matrix
  K = scaledKernelFunc(X, X);

  % Now use direct to optimise over lambdaRange
  opts.maxevals = 30;
  func = @(arg) - crossValidate(K, Y, exp(arg), numPartsKFoldCV, numTrialsKFoldCV);
  [negBestErr, bestLogLambda] = diRectWrap(func, log(lambdaRange), opts);
  bestLambda = exp(bestLogLambda);
  bestValidErr = - negBestErr;
  fprintf('Valid-Err: %.4f, lambda=%.4f(%.4f, %.4f)\n', bestValidErr, ...
    bestLambda, lambdaRange(1), lambdaRange(2));

end


% This does the cross validation
function validErr = crossValidate(K, Y, lambda, numPartsKFoldCV, numTrialsKFoldCV)

  validErr = 0;
  n = size(K, 1);

  for cvIter = 1:numTrialsKFoldCV
    testStartIdx = round( (cvIter-1)*n/numPartsKFoldCV + 1);
    testEndIdx = round( cvIter*n/numPartsKFoldCV );
    trainIdxs = [1:(testStartIdx-1), (testEndIdx+1):n]';
    testIdxs = [testStartIdx:testEndIdx]';
    nTe = testEndIdx - testStartIdx + 1;
    nTr = n - nTe;
    Ktrtr = K(trainIdxs, trainIdxs);
    Ktetr = K(testIdxs, trainIdxs);
    Ytr = Y(trainIdxs, :);
    Yte = Y(testIdxs, :);

    alpha = (Ktrtr + lambda*eye(nTr))\Ytr;
    preds = Ktetr * alpha;
    validErr = validErr + norm(preds - Yte).^2/nTe;
  end
end


% Predictions for Kernel Ridge Regression
function preds = predictKRR(Xte, Xtr, kernelFunc, alpha)
  Ktetr = kernelFunc(Xte, Xtr);
  preds = Ktetr * alpha;
end


% get Scale for kernel
function yScale = getYScale(Y)
  yScale = std(Y);
end

