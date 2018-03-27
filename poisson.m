  function S = poisson(lambda,n,m);
% -------------------------------------------------------------
% Generate a random sample S of size ns from the (discrete)
% Poisson distribution with parameter lambda.
% Fixed error: changed S(i) = k; to S(i) = k-1;
% Derek O'Connor, 3 May 2012.  derekroconnor@eircom.net
%
  S = zeros(n,m);
  for i = 1:n*m    
      k=1; produ = 1;
      produ = produ*rand;
      while produ >= exp(-lambda)
          produ = produ*rand;
          k = k+1;
      end
      S(i) = k-1;
  end