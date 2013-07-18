function [ Besselsig BesselsigNorm eta x u t] = BesselGenerator( n,m, alpha )%Root, power of bay, slope of bay

tic
lambda_S=0;
lambda_E=80;
xmax=4000;


x=-[0:.001:10 10.001:.1:xmax];
g=9.81;
[eta,u,etat]=eta_0(x);
sigma=2*sqrt((etat*eta-x*alpha)*g*(m+1)/m);
Sigma_L=max(sigma);
lambda=(lambda_S:.1:lambda_E);
Zeros_of_bessel=[0 besselzero((1/m)+1,n-1,1)'];


Lambda_n=-(Zeros_of_bessel(n)/Sigma_L).^2;% build the eigenvalues from zeros of bessel


besselpart=besselj(1/m,sqrt(-1*Lambda_n)*sigma)./sigma.^(1/m);
%fix the zero point
besselpart(1)=besseljo(1/m,Lambda_n,0);
    
    
A=trapz(sigma,(sqrt(-1*Lambda_n)*2*g*eta.*besselpart));
B=u*trapz(sigma(2:end),(besselpart(2:end).*cumsimps(sigma(2:end),m/(m+1).*sigma(2:end).*eta_0(-sigma(2:end)).*sqrt(g./(alpha*-x(2:end))))));

Besselsig=besselj(1/m,sqrt(-1*Lambda_n)*sigma)./sigma.^(1/m);
%fix the zero point
Besselsig(1)=besseljo(1/m,Lambda_n,0);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

BesselsigP1=besselj(1/m+1,sqrt(-1*Lambda_n)*sigma)./sigma.^(1/m);
%fix the zero point
BesselsigP1(1)=0*besseljo((1/m)+1,Lambda_n,0);

BesselsigP1OverSigma=besselj(1/m+1,sqrt(-1*Lambda_n)*sigma)./sigma.^((1/m)+1);
%fix the zero point
BesselsigP1OverSigma(1)=besseljoOverX(1/m,Lambda_n,0);


BesselsigNorm=Besselsig/Besselsig(1);
figure(1)
plot(sigma,Besselsig)
figure(2)
plot(sigma,BesselsigNorm)




% Go to X dim
psi=zeros(length(sigma),length(lambda));
phi=psi;
u=phi;

for i=1:length(lambda)
    psi(:,i)=-BesselsigP1.*(A*sin(sqrt(-1*Lambda_n)*lambda(i))+B*cos(sqrt(-1*Lambda_n)*lambda(i)));
    phi(:,i)=sqrt(-1*Lambda_n)*Besselsig.*(A*cos(sqrt(-1*Lambda_n)*lambda(i))-B*sin(sqrt(-1*Lambda_n)*lambda(i)));
    
    
    u(:,i)=-(m+1)/m*BesselsigP1OverSigma*(A*sin(sqrt(-1*Lambda_n)*lambda(i))+B*cos(sqrt(-1*Lambda_n)*lambda(i)));
end

eta=1/(2*g)*(phi-u.^2);
t=(ones(length(u(:,1)),1)*lambda-u)/(alpha*g);
x=1/(2*g*alpha)*(phi-(ones(length(u(1,:)),1)*sigma.^2)'*2*g*m./(4*g*(m+1))-u.^2);
x=eta-(ones(length(u(1,:)),1)*sigma.^2)'*2*g*m./(4*g*(m+1));
Changedsign=0;
plotto=length(lambda);
for i=3:size(u,2)
    if (sign(u(:,i))~=sign(u(:,i-1)))
        if Changedsign==1;
            plotto=i;
            break;
        end
        Changedsign=1;
    end
end
toc
disp(['A=' num2str(A) ', B=' num2str(B)])
%plot(x(:,3),eta(:,3))



% for i=1:length(lambda)
%         plot(sigma,phi(:,i))
%     hold on
%     plot(sigma,psi(:,i),'r')
%      leg=legend('phi','psi');
%      set(leg,'Location','Best');
%     pause(.1)
%     hold off
% % end
for i=1:plotto
    plot(x(:,i),eta(:,i),'.b')
    hold on
    plot(x(:,i),u(:,i),'.r')
    xlabel('x')
    leg=legend('eta','u');
    set(leg,'Location','Best')
    pause(.1)
    hold off
end
%figure(99)
%plot(psi(2,:));


end