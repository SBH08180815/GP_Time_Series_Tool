function K=gp_kernel(x1,x2,sig_n,theta0,theta1)
%ºËº¯Êý
m=size(x1,1);n=size(x2,1);
dist_matix=zeros(m,n);%¾àÀë¾ØÕó
for i=1:m
    for j=1:n
        dist_matix(i,j)=sqrt(sum((x1(i)-x2(j))^2));    
        if (i==j)
        K(i,j)=theta0^2.*(1+sqrt(3).*dist_matix(i,j)/theta1).*exp(-sqrt(3).*dist_matix(i,j)/theta1)+sig_n^2;
        else
        K(i,j)=theta0^2.*(1+sqrt(3).*dist_matix(i,j)/theta1).*exp(-sqrt(3).*dist_matix(i,j)/theta1);    
        end
    end
end
end