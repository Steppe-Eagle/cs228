% CS228 Winter 2011-2012
% File: LearnGraphStructure.m
% Copyright (C) 2012, Stanford University
% Huayan Wang

function [A W] = LearnGraphStructure(dataset)

% Input:
% dataset: N x 10 x 3, N poses represented by 10 parts in (y, x, alpha)
% 
% Output:
% A: maximum spanning tree computed from the weight matrix W
% W: 10 x 10 weight matrix, where W(i,j) is the mutual information between
%    node i and j. 

N = size(dataset, 1);
K = size(dataset, 3);

numparts = size(dataset, 2);
W = zeros(numparts);

% Compute weight matrix W
% set the weights following Eq. (14) in PA description
% you don't have to include M since all entries are scaled by the same M
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE        
%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:numparts
  for j = 1:numparts
    Oi(:,:) = dataset(:, i, :);
    Oj(:,:) = dataset(:, j, :);
    W(i,j) = GaussianMutualInformation(Oi, Oj);
  end
end

% Compute maximum spanning tree
A = MaxSpanningTree(W);
