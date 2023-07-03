function D=h_gnss(X,time0,sigmaL0,sigmaF0,sigma0) 
         H=[ones(size(X,1),1),(X-time0)./365.25,sin(2.*pi.*(X-time0)/365.25),cos(2.*pi.*(X-time0)/365.25)];
         R=gp_kernel(X,X,sigma0,sigmaF0,sigmaL0);
         A=inv(H'*inv(R)*H)*H'*inv(R);
         D=A*R*A';
         %H=[ones(size(X,1),1),(X),sin(2.*pi.*(X)/1),cos(2.*pi.*(X)/1)];
end