% CS228 PA9 Winter 2011-2012
% File: EM_HMM.m
% Copyright (C) 2012, Stanford University

function [P loglikelihood ClassProb PairProb] = EM_HMM(actionData, poseData, G, InitialClassProb, InitialPairProb, maxIter)

% INPUTS
% actionData: structure holding the actions as described in the PA
% poseData: N x 10 x 3 matrix, where N is number of poses in all actions
% G: graph parameterization as explained in PA description
% InitialClassProb: N x K matrix, initial allocation of the N poses to the K
%   states. InitialClassProb(i,j) is the probability that example i belongs
%   to state j.
%   This is described in more detail in the PA.
% InitialPairProb: V x K^2 matrix, where V is the total number of pose
%   transitions in all HMM action models, and K is the number of states.
%   This is described in more detail in the PA.
% maxIter: max number of iterations to run EM

% OUTPUTS
% P: structure holding the learned parameters as described in the PA
% loglikelihood: #(iterations run) x 1 vector of loglikelihoods stored for
%   each iteration
% ClassProb: N x K matrix of the conditional class probability of the N examples to the
%   K states in the final iteration. ClassProb(i,j) is the probability that
%   example i belongs to state j. This is described in more detail in the PA.
% PairProb: V x K^2 matrix, where V is the total number of pose transitions
%   in all HMM action models, and K is the number of states. This is
%   described in more detail in the PA.

% Initialize variables
N = size(poseData, 1);
K = size(InitialClassProb, 2);
L = size(actionData, 2); % number of actions
V = size(InitialPairProb, 1);

ClassProb = InitialClassProb;
PairProb = InitialPairProb;

loglikelihood = zeros(maxIter,1);

% EM algorithm
for iter=1:maxIter
  
  % M-STEP to estimate parameters for Gaussians
  % Fill in P.c, the initial state prior probability (NOT the class probability as in PA8 and EM_cluster.m)
  % Fill in P.clg for each body part and each class
  % Make sure to choose the right parameterization based on G(i,1)
  % Hint: This part should be similar to your work from PA8 and EM_cluster.m
  
  P.c = zeros(1,K);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % YOUR CODE HERE
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  
  Mi = zeros(1,L);
  for k=1:K
    for action=1:L
      % numposes = size(actionData(action).marg_ind, 2);
      Mi(action) = sum(ClassProb(actionData(action).marg_ind, k)) / size(actionData(action).marg_ind, 2);
    end
    P.c(k) = sum( Mi ./ sum(Mi) );
  end
  P.c = P.c ./ sum(P.c) % normalize
  
  % might be wrong from here on -- still working on it
  
  for part = 1:numparts

    parentpart = 0;
    U = [];
    if G(part, 1) == 1
      parentpart = G(part, 2);
      U(:, 1) = poseData(:, parentpart, 1);
      U(:, 2) = poseData(:, parentpart, 2);
      U(:, 3) = poseData(:, parentpart, 3);
    end

    for k=1:K

      if parentpart == 0

        [mu, sigma] = FitGaussianParameters(poseData(:, part, 1), ClassProb(:, k));
        P.clg(part).mu_y(k) = mu;
        P.clg(part).sigma_y(k) = sigma;

        [mu, sigma] = FitGaussianParameters(poseData(:, part, 2), ClassProb(:, k));
        P.clg(part).mu_x(k) = mu;
        P.clg(part).sigma_x(k) = sigma;

        [mu, sigma] = FitGaussianParameters(poseData(:, part, 3), ClassProb(:, k));
        P.clg(part).mu_angle(k) = mu;
        P.clg(part).sigma_angle(k) = sigma;

      else

        [Beta, sigma] = FitLinearGaussianParameters(poseData(:, part, 1), U, ClassProb(:, k));
        P.clg(part).theta(k, 1) = Beta(4);
        P.clg(part).theta(k, 2:4) = Beta(1:3);
        P.clg(part).sigma_y(k) = sigma;

        [Beta, sigma] = FitLinearGaussianParameters(poseData(:, part, 2), U, ClassProb(:, k));
        P.clg(part).theta(k, 5) = Beta(4);
        P.clg(part).theta(k, 6:8) = Beta(1:3);
        P.clg(part).sigma_x(k) = sigma;

        [Beta, sigma] = FitLinearGaussianParameters(poseData(:, part, 3), U, ClassProb(:, k));
        P.clg(part).theta(k, 9) = Beta(4);
        P.clg(part).theta(k, 10:12) = Beta(1:3);
        P.clg(part).sigma_angle(k) = sigma;

      end

    end

  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % M-STEP to estimate parameters for transition matrix
  % Fill in P.transMatrix, the transition matrix for states
  % P.transMatrix(i,j) is the probability of transitioning from state i to state j
  P.transMatrix = zeros(K,K);
  
  % Add Dirichlet prior based on size of poseData to avoid 0 probabilities
  P.transMatrix = P.transMatrix + size(PairProb,1) * .05;
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % YOUR CODE HERE
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
    
  % E-STEP preparation: compute the emission model factors (emission probabilities) in log space for each 
  % of the poses in all actions = log( P(Pose | State) )
  % Hint: This part should be similar to (but NOT the same as) your code in EM_cluster.m
  
  logEmissionProb = zeros(N,K);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % YOUR CODE HERE
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
    
  % E-STEP to compute expected sufficient statistics
  % ClassProb contains the conditional class probabilities for each pose in all actions
  % PairProb contains the expected sufficient statistics for the transition CPDs (pairwise transition probabilities)
  % Also compute log likelihood of dataset for this iteration
  % You should do inference and compute everything in log space, only converting to probability space at the end
  % Hint: You should use the logsumexp() function here to do probability normalization in log space to avoid numerical issues
  
  ClassProb = zeros(N,K);
  PairProb = zeros(V,K^2);
  loglikelihood(iter) = 0;
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % YOUR CODE HERE
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Print out loglikelihood
  disp(sprintf('EM iteration %d: log likelihood: %f', ...
    iter, loglikelihood(iter)));
  if exist('OCTAVE_VERSION')
    fflush(stdout);
  end
  
  % Check for overfitting by decreasing loglikelihood
  if iter > 1
    if loglikelihood(iter) < loglikelihood(iter-1)
      break;
    end
  end
  
end

% Remove iterations if we exited early
loglikelihood = loglikelihood(1:iter);
