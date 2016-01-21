function [Xtr, Ytr, Xte, Yte] = getDataset(dataset)

  rng('default');

  switch dataset

    case 'speech'
      L = load('datasets/parkinson21.txt');
      L = shuffleData(L);
      attrs = [1:14, 20:26]; label = 15;
      trIdxs = (1:520)';
      teIdxs = (521:1040)';
      [Xtr, Ytr, Xte, Yte] = partitionData(L, attrs, label, trIdxs, teIdxs);

    case 'propulsion'
      L = load('datasets/propulsion.txt');
        L = shuffleData(L); L(:,2) = log(L(:,2));
        L = L(1:400, :); trIdxs = (1:200)'; teIdxs = (201:400)';
      attrs = [3:8 10:18]; label = 2;
      [Xtr, Ytr, Xte, Yte] = partitionData(L, attrs, label, trIdxs, teIdxs);

    case 'housing'
      L = load('datasets/housing.txt');
      L = shuffleData(L);
      attrs = [2:3 5:14];  label = 1;
      trIdxs = (1:256)'; teIdxs = (257:506)';
      [Xtr, Ytr, Xte, Yte] = partitionData(L, attrs, label, trIdxs, teIdxs);

    case 'music'
      L = load('datasets/music.txt');
      L = shuffleData(L);
      attrs = (2:91)'; label = 1;
      trIdxs = (1:1000)'; teIdxs = (1001:2000)';
      [Xtr, Ytr, Xte, Yte] = partitionData(L, attrs, label, trIdxs, teIdxs);

    case 'telemonitoring-total'
      L = load('datasets/telemonitoring.txt');
      L = L( L(:,3) == 0, :); % only select female candidates
      L = shuffleData(L);
      attrs = [2 4:5 7:22]; label = 6;
      trIdxs = (1:1000)'; teIdxs = (1001:1867)';
      [Xtr, Ytr, Xte, Yte] = partitionData(L, attrs, label, trIdxs, teIdxs);

    case 'forestfires'
      L = load('datasets/forestfires.txt');
      L = shuffleData(L);
      L(:,11) = log(L(:,11) + 1);
      trIdxs = (140:350)';
      teIdxs = (351:517)';
      label = 7; attrs = setdiff([1:11], label);
      [Xtr, Ytr, Xte, Yte] = partitionData(L, attrs, label, trIdxs, teIdxs);
      
    case 'blog'
      L = load('datasets/blog.txt');
      L = shuffleData(L);
      trIdxs = (1:700)'; teIdxs = (701:1388)';
      Xstd = std(L(:,1:280));
      Xmean = mean(L(:,1:280)); 
      rmIdxs = isnan(Xstd) | isnan(Xmean) | (Xstd<0.1);
      L = L(:,~rmIdxs);
      label = size(L,2); attrs = (51:100)';
      [Xtr, Ytr, Xte, Yte] = partitionData(L, attrs, label, trIdxs, teIdxs);

%       L = load('datasets/blog.txt');
%       L = shuffleData(L);
%       rmIdxs = (mean(abs(L)) < .11)';
%       L = L(:, ~rmIdxs);
%       trIdxs = (1:700)'; teIdxs = (701:1388)';
%       label = 92; attrs = (1:91)';
%       [Xtr, Ytr, Xte, Yte] = partitionData(L, attrs, label, trIdxs, teIdxs);
    
    case 'galaxy'
      load('datasets/lrgReg.mat');
      Y = Y / std(Y);
      trLabels = 1:2000;
      teLabels = 2001:4000;
      Xtr = X(trLabels, :);
      Ytr = Y(trLabels, :);
      Xte = X(teLabels, :);
      Yte = Y(teLabels, :);

    case 'skillcraft'
      L = load('datasets/skillcraft.txt');
      L = shuffleData(L);
      attrs = [2:15 17:20]; label = 16;
      trIdxs = (1:1700)'; teIdxs = (1701:3330)';
      [Xtr, Ytr, Xte, Yte] = partitionData(L, attrs, label, trIdxs, teIdxs);

    case 'airfoil'
      L = load('datasets/airfoil.txt');
      L = shuffleData(L);
      attrs = [1:5]; label = 6;
      trIdxs = (1:750)'; teIdxs = (751:1500)';
      [Xtr, Ytr, Xte, Yte] = partitionData(L, attrs, label, trIdxs, teIdxs);
      numAddDims = 36; % *
      Xtr = [Xtr, randn(size(Xtr,1), numAddDims)];
      Xte = [Xte, randn(size(Xte,1), numAddDims)];

    case 'CCPP'
      load('datasets/ccpp.mat');
      L = [XTrain YTrain];
      L = shuffleData(L);
      attrs = [1:4]; label = 5;
      trIdxs = (1:2000)'; teIdxs = (2001:4000)';
      [Xtr, Ytr, Xte, Yte] = partitionData(L, attrs, label, trIdxs, teIdxs);
      numAddDims = 55; % *
      Xtr = [Xtr, randn(size(Xtr,1), numAddDims)];
      Xte = [Xte, randn(size(Xte,1), numAddDims)];
      
    case 'Insulin'
      load('datasets/epidata.mat');
      L = [insulin_data snp_data];
      L = shuffleData(L);
      attrs = [2:51]; label =1;
      trIdxs = (1:256)'; teIdxs = (257:506)';
      [Xtr, Ytr, Xte, Yte] = partitionData(L, attrs, label, trIdxs, teIdxs);
      

    otherwise
      error('Unknown Dataset');

  end

end


% Another utility function
function [Xtr, Ytr, Xte, Yte] = ...
  partitionData(L, attrs, label, trainIdxs, testIdxs)
  Xtr = L(trainIdxs, attrs);
  Ytr = L(trainIdxs, label);
  Xte = L(testIdxs, attrs);
  Yte = L(testIdxs, label);

  % Now normalize the dataset to have unit variance in input axis
  meanXtr = mean(Xtr);
  stdXtr = std(Xtr);
  meanYtr = mean(Ytr);
  stdYtr = std(Ytr);

  % process files
  function X = normalizeX(X)
    X = bsxfun(@rdivide, bsxfun(@minus, X, meanXtr), stdXtr); 
  end
  function Y = normalizeY(Y)
    Y = (Y - meanYtr)/stdYtr;
  end

  Xtr = normalizeX(Xtr);
  Xte = normalizeX(Xte);
  Ytr = normalizeY(Ytr);
  Yte = normalizeY(Yte);
end


% Shuffles the data
function [X, Y] = shuffleData(X, Y)
  n = size(X, 1);
  shuffleOrder = randperm(n);
  X = X(shuffleOrder, :);
  if nargin > 1
    Y = Y(shuffleOrder, :);
  end
end

