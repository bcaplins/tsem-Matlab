function [data, label, sourceClassMean] = generateData(nDims,nPts,nClusters)

% Data is generated using a Mixture of Gaussians.
% 
% -- Input arguments
% nDims     = Dimension of each data point. Each data point is a vector.
% nPts      = # of synthetic data points to generate.
% nClusters = # of Gaussians
% 
% -- Output arguments
% data      = nPts x (nDims + sLabel) matrix. sLabel = {1,2,..nClusters}
% 

% check input arguments
if nargin == 0 || nargin > 3
    error ('Number of input arguments should be <= 3')
elseif nargin < 2
    nPts        = 100;
    nClusters   = 3;
elseif nargin < 3
    nClusters   = 3;
else
end

%
meanScale       = 10;
aBigNum         = 10000;
numOutliers     = ceil (0.4*nPts);
data            = zeros(nPts+numOutliers, nDims);
label           = zeros(nPts+numOutliers, 1);

% set up the class member parameters storage
sourceClassMean = zeros(nClusters, nDims );
sourceClassVar  = zeros(nClusters, nDims, nDims );

% generate mean & covariance
for i=1:nClusters
    sourceClassMean(i,:)  = randn(1,nDims)*meanScale;
    temp_                 = randn(nDims,nDims);
    sourceClassVar(i,:,:) = temp_'*temp_;
end

% generate synthetic data using class memeber parameters
for i=1:nPts
    temp_            = randi(aBigNum, 1, nClusters);
    priorClassPr     = temp_/sum(temp_);                % prior probabilities
    [~,label(i)]     = max(priorClassPr);
    
    sampleMean       = sourceClassMean(label(i),:);
    sampleVar        = squeeze(sourceClassVar (label(i),:,:));
    data(i, 1:nDims) = sampleMean + randn(1,nDims)*chol(sampleVar);
end

% add random outliers to data
for i = nPts+1 : 1 : nPts+numOutliers
    data(i,1:nDims)  = randn(1,nDims)*meanScale;
    label(i)         = 0;    % outlier label
end