function D=h_grace(X,sigmaL0,sigmaF0,sigma0)
         H=[ones(size(X,1),1),(X),sin(2.*pi.*(X)/1),cos(2.*pi.*(X)/1)];
         R=gp_kernel(X,X,sigma0,sigmaF0,sigmaL0);
         A=inv(H'*inv(R)*H)*H'*inv(R);
         D=A*R*A';
end