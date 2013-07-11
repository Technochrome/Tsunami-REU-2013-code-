clear all
Num_Roots=150;
m=2;

lambda_S=0;
lambda_E=50;


%put numbers for our problem
alpha=.05;
xmax=800;
x=-[0:.001:10 10.001:.1:xmax];
g=9.81;
sigma=2*sqrt(-x*alpha*g*(m+1)/m);
Sigma_L=max(sigma);

lambda=(lambda_S:lambda_E/200:lambda_E);
disp('Zeros of bessel')
Zeros_of_bessel=besselzero((1/m)+1,Num_Roots-1,1);
Lambda_n=-([0 Zeros_of_bessel']./Sigma_L).^2;% build the eigenvalues from zeros of bessel
if(m==2)
    plot(tan(Sigma_L*sqrt(-Lambda_n))-Sigma_L*sqrt(-Lambda_n))%compares eigen values to expected ones for m=2, shows deviation from 0 for each eigen value.
    pause(1)
end

%find constants
disp('Finding Consts using Eigenfunctions')
C_n=zeros(Num_Roots,1);
D_n=zeros(Num_Roots,1);

besselpart=zeros(Num_Roots,length(sigma));
for n=1:Num_Roots%need to make besselj better so that x can be 0
    
    besselpart(n,:)=besselj(1/m,sqrt(-1*Lambda_n(n))*sigma)./sigma.^(1/m);
    %fix the zero point
    besselpart(n,1)=besseljo(1/m,Lambda_n(n),0);
    
    
    
    C_n(n)=trapz(sigma,(sqrt(-1*Lambda_n(n))*2*g*eta_0(-sigma).*besselpart(n,:)));
    % Use eta0 flag later
    D_n(n)=0.*trapz(sigma(2:end),(besselpart(n,2:end).*cumsimps(sigma(2:end),m/(m+1).*sigma(2:end).*eta_0(-sigma(2:end)).*sqrt(g./(alpha*-x(2:end))))));
    if(n==Num_Roots)
        figure(1)
        plot(sigma,besselpart(n,:),'.b')
        hold on
        plot(sigma(1:end-1),diff(besselpart(n,:))./diff(sigma),'.r','MarkerSize',1)
        plot(sigma,0.*sigma,'k')
        legend('Eig(sigma)','Eigp(sigma)');
        hold off
        figure(2)
        plot(x,besselpart(n,:),'.b')
        hold on
        plot(x(1:end-1),diff(besselpart(n,:))./diff(x),'.r','MarkerSize',1)
        plot(x,0.*x,'k')
        legend('Eig(x)','Eigp(x)');
        set(gca,'xdir','reverse')
        hold off
        figure(3)
        plot(C_n,'.-b')
        hold on
        plot(D_n,'.-r')
        plot(1:length(D_n),0.*D_n,'k')
        legend('C_n','D_n');
        hold off
        pause(2)
    end
    
end

disp('Checking convergence of Constants')
NEED_ROOTS=max([abs(max(C_n(floor(Num_Roots*.9):end))),abs(min(C_n(floor(Num_Roots*.9):end))),abs(max(D_n(floor(Num_Roots*.9):end))),abs(min(D_n(floor(Num_Roots*.9):end)))]);%measure of how far from 0 last 10% of constants are
if NEED_ROOTS>.01
   disp('May Need more roots for accuracy') 
end


disp('Building function from basis')
Phi= zeros(Num_Roots,length(sigma),length(lambda));


for j=1:length(lambda)
    Phi(n,:,j)=besselpart(1,:).*(C_n(n).*sin(sqrt(-1*Lambda_n(n))*lambda(j))+D_n(n).*cos(sqrt(-1*Lambda_n(n))*lambda(j)));%both D_n had sin instead of cos YIKES, look through paper work (finally)
end

for n=2:Num_Roots
    for j=1:length(lambda)
        Phi(n,:,j)=Phi(n-1,:,j)+besselpart(n,:).*(C_n(n).*sin(sqrt(-1*Lambda_n(n))*lambda(j))+D_n(n).*cos(sqrt(-1*Lambda_n(n))*lambda(j)));
    end
    if( mod(floor((Num_Roots-n)/Num_Roots)*100,2)==0)
        disp(strcat(num2str(100-floor((Num_Roots-n)/Num_Roots*100)),'%'))
    end
end
p2(:,:)=Phi(Num_Roots,:,:);
clear Phi
close(1)
close(2)
close(3)
figure(4)
for i=1:length(p2(1,:))
plot(sigma,p2(:,i))
pause(.1)
end

disp('finding phi...')


phi=zeros(length(sigma),length(lambda)-1);

phi(:,1)=(p2(:,2)-p2(:,1))/(lambda(2)-lambda(1));
phi(:,length(lambda))=(p2(:,length(lambda))-p2(:,length(lambda)-1))/(lambda(length(lambda))-lambda(length(lambda)-1));
for j=2:length(lambda)-1
        phi(:,j)=(p2(:,j+1)-p2(:,j-1))/(lambda(j+1)-lambda(j-1));
end

disp('finding psi...')



psi(1,:)=(p2(2,:)-p2(1,:))/(sigma(2)-sigma(1));
psi(length(sigma),:)=(p2(length(sigma),:)-p2(length(sigma)-1,:))/(sigma(length(sigma))-sigma(length(sigma)-1));
for k=2:length(sigma)-1
        psi(k,:)=(p2(k+1,:)-p2(k-1,:))/(sigma(k+1)-sigma(k-1));
end


disp('final conversion')
[LAM, Fgrid] = meshgrid(-lambda, m/(m+1)*sigma);
[~, intgrid] = meshgrid(-lambda, 1/2*m/(m+1)*(sigma.^2-sigma(1)^2));

u2   = psi./Fgrid;
eta2 = (phi-u2.^(2))/(2*g);
t2   = abs(((LAM-u2)/(alpha*g)));
x2   = (phi-u2.^(2)-intgrid)/(2*alpha*g);

eta2 = eta2(2:end-1,:);
t2   =   t2(2:end-1,:);
x2   =   x2(2:end-1,:);
u2   =   u2(2:end-1,:);

%[x_lin t_lin eta_lin u_lin] = toConstantTime(x2,t2, 1:max(max(t2)) ,eta2, u2);



figure(4)
for i=1:length(x2(1,:))
plot(x2(:,i),eta2(:,i))
pause(.1)
end




close(4)












