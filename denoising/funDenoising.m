function x = funDenoising(y,sizex,mu,maxiter)
%% This function contain actual implementation of the impulse denoising
% method based on split-Bregman technique
%% Initialization
mu1=mu(1) ; mu2=mu(2); mu3=mu(3) ; 
% [m,n]=size(A);
[~,d]=size(y);rows=sizex(1);cols=sizex(2);

B1=zeros(rows*cols,d); B2=B1; B3=B1; B4=B1;   % Bregman Variables
% Create Total variation matrices
[Dh,Dv]=opTV2(rows,cols);         

x=zeros(rows*cols,d);

%% Main iteration
for i=1:maxiter

    P=MySoftTh(Dh*x+B1,1/mu1);     
    Q=MySoftTh(Dv*x+B2,1/mu1); 
    R=NucTh(x+B3,1/mu2);
    S=MySoftTh(y-x+B4,1/mu3);         
    
    bigY=Dh'*(mu1*(P-B1))+Dv'*(mu1*(Q-B2))+mu2*(R-B3)+mu3*(y-S+B4); 
    
    for j=1:d
        [x(:,j),~]=lsqr(@afun,bigY(:,j),1e-6,5,[],[],x(:,j));        
    end
    
    
    % update bregman variables
    B1=B1+Dh*x-P;
    B2=B2+Dv*x-Q;
    B3=B3+x-R;
    B4=B4+y-S-x;
    
       if rem(i,2)==0    
           fprintf(' %d iteration done of %d \n',i, maxiter);
       end
       
end
x=reshape(x,rows,cols,d);

function y = afun(x,str)

tt= mu1*(Dh'*(Dh*x))+ mu1*(Dv'*(Dv*x))+ mu2*x + mu3*x;
        switch str
            case 'transp'
                y = tt;
            case 'notransp'
                y = tt;
        end
  end
 

end
%% This is soft thresholding operation
function X= MySoftTh(B,lambda)

   X=sign(B).*max(0,abs(B)-(lambda/2));
end
%% This is nuclear norm thresholding
function X=NucTh(X,lambda)
if isnan(lambda)
    lambda=0;
end
[u,s,v]= svd(X,0);
s1=MySoftTh(diag(s),lambda);
X=u*diag(s1)*v';
end

%% This is a function to make total variation matrix
function [Dh, Dv]=opTV2(m,n)

Dh = spdiags([-ones(n,1) ones(n,1)],[0 1],n,n);
Dh(n,:) = 0;
Dh = kron(Dh,speye(m));
   
Dv = spdiags([-ones(m,1) ones(m,1)],[0 1],m,m);
Dv(m,:) = 0;
Dv = kron(speye(n),Dv);
end
