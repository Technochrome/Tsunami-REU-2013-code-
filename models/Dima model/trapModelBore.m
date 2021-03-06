% This program will find the solution to the tsunami runup problem on a
% trapezoidal beach with a constant slope in the x direction.
% It requires that the programs trapF.m and fixit.m be present.
%
% The following varables are used in this program:
% W        - Vector that is used to find A.
% A        - n by n matrix that is used to solve the wave equation.
% I        - Matrix to look for breaks in time.
% a        - The amplitud of our gauss pulse.
% alpha    - The slope of th beach.
% b        - Length n vector that holds the right side of our system.
% breakc   - Checks to see if we have broken at that time.
% brokeat  - Keeps the index if there was a break.
% dW       - The derivative of W. used to find A.
% dlambda  - The step size in lambda.
% dlambda2 - dlambda^2
% dummy    - Matrix that is not used but comes from building a grid.
% eta1     - n by length(lambda) matrix that contains our exact solution if
%            it exist.
% eta2     - n by length(lambda) matrix that contains our numerical
%            solution.
% Exact    - Bool that it true if a exact analytical solution is known to
%            exist.
% F        - Vector of length n that contains information about our cross
%            sections.
% Fgrid    - Matrix that is used to convert from nonphysical varables to
%            physical ones.
% G        - Length n vector that is used to solve the wave equation.
% g        - Gravity.
% i        - Counter.
% intF     - Length n vector that is the integral of F. Use in conversion.
% intgrid  - Matrix used in the conversion.
% keeprate - Used in picking what values of lambda we will keep. Kept delta
%            lambda is 1/keeprate.
% LAM      - Matrix that  is used to convert from nonphysical varables to
%            physical ones.
% l        - Counter to keep our information.
% lambda   - Contians out kept lambda values.
% leg      - Used to move legend.
% maxl     - The maximum value of lambda.
% n        - The length of sigma.
% Phi      - Length n vector that holds the curent time step for our solution
%            to the wave equation.
% Phi_n    - Length n vector that holds the curent time step for our solution
%            to the wave equation. Needed to shuffle data.
% Phi_nm1  - Length n vector that holds the curent time step for our solution
%            to the wave equation. Needed to shuffle data.
% Phiout   - n by length(lambda) matrix that contains out approxamation for
%            Phi.
% plotb    - bool to turn on plot.
% Psi      - Length n vector that holds the curent time step for our solution
%            to the wave equation.
% Psi_n    - Length n vector that holds the current time step for our solution
%            to the wave equation. Needed to shuffle data.
% Psi_nm1  - Length n vector that holds the current time step for our solution
%            to the wave equation. Needed to shuffle data.
% Psiout   - n by length(lambda) matrix that contains out approxamation for
%            Psi.
% p        - The varence of our gauss pulse.
% phi      - Exact phi if it exist.
% psi      - Exact psi if it exist.
% slope    - Finds the slope of the wave to check for breaking
% s0       - The mean of our gauss pulse.
% SIG      - Matrix that  is used to convert from nonphysical varables to
%            physical ones.
% sigma    - Vector that contains out values for sigma.
% step     - Counter that keeps track of lambda when solving our system
% t1       - Our time output for the exact solution. NOTE MATRIX
% t2       - Our time output for the aprox solution. NOTE MATRIX
% timestpes- Sets the change in lambda.
% u1       - n by length(lambda) matrix for our velocity output fot the
%            exact solution.
% u2       - n by length(lambda) matrix for our velocity output fot the
%            aprox solution.
% x1       - Our distance output for the exact solution. NOTE MATRIX
% x2       - Our distance output for the aprox solution. NOTE MATRIX




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
clc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define all needed user inputs

tic
maxl=50;                 % maximum for lambda
timesteps=30000;            % number of time steps between \lambda=0, and \lambda=maxl, %DJN 4/10/13
keeprate=timesteps/100;     % keep every \it{keeprate}-th step.
g=9.81;                  % Set gravity
alpha=1/100;               % Set slope
plotb=1;                 % Bool to plot
dsigma=.01;              % Our change in Sigma from program
maxsigma=150;             % The maximum value for sigma that we want.


DJN_beachwidth=50;
DJN_slopes=.5;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%We generate the space-determined variables sigma, F, H, H0, intF, dF, W,
%and dW.

%[sigma,F,H,H0,intF,dF,W,dW] = trapF(1,1,dsigma,maxsigma,340,g);
[sigma,F,H,H0,intF,dF,W,dW] = trapF(DJN_slopes,DJN_beachwidth/2,dsigma,maxsigma,1000,g);
W(1)=1e100; %W(1) is the infinity, just make it huge, instead of the Inf, DJN 4/10/13

n = length(sigma);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Build starting need information from user inputs and build the matrix A
% that will be used to solve our system

disp('Building model...')
dlambda=maxl/timesteps;     % Define dlambda %DJN correction 4/10/13

dsigma2=dsigma*dsigma;   % Find dlambda^2 and dsigma^2
dlambda2=dlambda*dlambda;

A=sparse(n,n);
b=zeros(n,1);


A(1,1)=1;               % Define the matrix A, W and dW needed for our model
for i=2:n-1
    A(i, i-1)=   -(    dlambda2/(dsigma2) - dlambda2/(2*dsigma)*W(i)                    );
    A(i, i)  = 1 -( -2*dlambda2/(dsigma2)                           + dlambda2*dW(i)    );
    A(i, i+1)=   -(    dlambda2/(dsigma2) + dlambda2/(2*dsigma)*W(i)                    );
end
A(n,n)=1;


%DJN
%Define the initial profile
DJN_x=-[0:1:35046];
%Comparison with the FUNWAVE model

%eta_0 gives eta and u
[DJN_eta,U_0]=eta_0(DJN_x);



% DJN_eta=-9.0315e-4*exp(-1.5e-5*(1000+DJN_x).^2).*(1000+DJN_x); %alpha=0.01
DJN_eta(abs(DJN_eta)<1e-5)=0;

DJN_u=U_0*DJN_eta.*sqrt(g./(-alpha*DJN_x-DJN_eta));


%DJN_eta=0.01*(1-tanh((1000+DJN_x)/200 ))/2
plot(DJN_x, DJN_eta)

%We need to convert (x, t, \eta, u) to (\sigma, \lambda, \phi, \psi)
DJN_H=DJN_eta-DJN_x*alpha;
DJN_Sigma=interp1(H, sigma, DJN_H);

DJN_Phi=2*g*DJN_eta;


%------------------MODEL STARTS HERE-----------------------
%----------------------------------------------------------
%----------------------------------------------------------
% Define the initial Phi (wave height)
% Phi_nm1=-4*a*sigma.^(-1).*((sigma-s0)/p^2.*exp(-1*((sigma-s0)/p).^2)+(sigma+s0)/p^2.*exp(-((sigma+s0)/p).^2));
% Phi_nm1(1)=0;

Phi_nm1=interp1(DJN_Sigma, DJN_Phi, sigma);
Phi_nm1(isnan(Phi_nm1))=0;
Phi_nm1(1)=0;
Phi_nm1(end)=Phi_nm1(end-1);

Phi_nm1=Phi_nm1';   %Make it the column, DJN 4/10/13

%Define the initial Psi and then the next time step (wave velocity)
PHI_sigma=zeros(n,1);                                                % Pre-allocate for speed
PHI_sigma(1)=(-Phi_nm1(3)+4*Phi_nm1(2)-3*Phi_nm1(1))/(2*dsigma);     % Second order forwards difference
for i=2:n-1
    PHI_sigma(i)=(Phi_nm1(i+1)-Phi_nm1(i-1))/(2*dsigma);             % Second order central difference
end
PHI_sigma(n)=(-3*Phi_nm1(n)+4*Phi_nm1(n-1)-Phi_nm1(n-2))/(2*dsigma); % Second order backwards difference


DJN_u(isnan(DJN_u))=0;
u_sigma=interp1(DJN_Sigma, DJN_u, sigma);
u_sigma(isnan(u_sigma))=0;


Psi_nm1=F.*u_sigma;
Psi_nm1=Psi_nm1';   %Make it the column, DJN 4/10/13
%zeros(n,1);                                          % psi=0, %Make it the column, DJN 4/10/13


Psi_n=Psi_nm1+PHI_sigma*dlambda;                                     % Compute psi at the second step
%DJN 4/10/13 %Psi=Psi_n;                                                   % Define Psi as the nth step


%Find Phi at the next time step using Psi_n
PSI_sigma=zeros(n,1); 
PSI_sigma(1)=(-Psi_nm1(3)+4*Psi_nm1(2)-3*Psi_nm1(1))/(2*dsigma)+Psi_nm1(1)*W(1);     % Second order forwards difference
for i=2:n-1
    PSI_sigma(i)=(Psi_nm1(i+1)-Psi_nm1(i-1))/(2*dsigma)+Psi_nm1(i)*W(i);             % Second order central difference
end
PSI_sigma(n)=(-3*Psi_nm1(n)+4*Psi_nm1(n-1)-Psi_nm1(n-2))/(2*dsigma)+Psi_nm1(n)*W(n); % Second order backwards difference
Phi_n=Phi_nm1+dlambda*(PSI_sigma);                                                   % Compute phi at the nth step
%DJN 4/10/13 %Phi=Phi_n;                                                                   % Define Psi as the nth step



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%FOR MOVING BOUNDRY OPTION%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Solve the model for Psi and Phi

disp('Running model...')

%Pre-allocate for the speed %DJN 4/10/13
Psiout=zeros(ceil(timesteps/keeprate), n);
Phiout=zeros(ceil(timesteps/keeprate), n);
lambda=zeros(ceil(timesteps/keeprate), 1);

step=0;
l=1;                            % Index to keep only parts of our informaion
Phiout(l,:)=Phi_nm1;         % Keep the initial conditions
Psiout(l,:)=Psi_nm1;
lambda(l)=0;

%DJN 4/10/13, we need to keep the second step too.
step=1;
if(mod(step,keeprate)==0) %Check if we need to keep it.
    l=2;                            % Index to keep only parts of our informaion
    Phiout(l,:)=Phi_n;           
    Psiout(l,:)=Psi_n;
    lambda(l)=step*dlambda;
end

l=l+1;
for step=2:timesteps    %we start from the third step, since the first two are already computed, DJN 4/10/13
    
%DJN  b(1)=0;                     % Define b as the right side of our system
%     for i=2:n-1
%         b(i)=2*Psi_n(i)-Psi_nm1(i);
%     end
%     b(n)=0;
     
    b=2*Psi_n-Psi_nm1;          %Convert into the vector operation, DJN 4/10/13  
    b(1)=0; b(n)=0;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%Linear Boundary%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     A(end,end)=dsigma+dlambda;
%     A(end,end-1)=-dlambda;
%     b(n)=dsigma*Psi_n(n);
    
    
            
            
            
    Psi_nm1=Psi_n;              %We don't really need Psi vector, it just got eliminated to save time, DJN 4/10/13
    Psi_n=A\b;
    
    PSI_sigma(1)=(-Psi_n(3)+4*Psi_n(2)-3*Psi_n(1))/(2*dsigma)+W(1)*Psi_n(1);     % Second order forwards differene
    for i=2:n-1
        PSI_sigma((i))=(Psi_n(i+1)-Psi_n(i-1))/(2*dsigma)+W(i)*Psi_n(i);           % Second order centeral differene
    end
    PSI_sigma((n))=(-3*Psi_n(n)+4*Psi_n(n-1)-Psi_n(n-2))/(2*dsigma)+W(n)*Psi_n(n); % Second order backwards differene
    
    Phi=4/3*Phi_n-1/3*Phi_nm1+2/3*PSI_sigma*dlambda;                             % Define the next Phi
    Phi_nm1=Phi_n;
    Phi_n=Phi;
      
    if(mod(step,keeprate)==0)              % Keep information at some points
        Psiout(l,:)=Psi_n;              % save the values at the current time step (written into the *_n arrays)
        Phiout(l,:)=Phi_n;
        lambda(l)=step*dlambda;
        l=l+1;
        display(['Step = ', num2str(step),', or ', num2str(step/timesteps*100,'%5.2f'),'%'])
        plot(sigma,Phiout(l-1,:));
        pause(.001)
    end
    
end

%clearvars -except 'Phiout' 'Psiout' 'a' 'p' 's0' 'sigma' 'lambda' 'sigma' 'm' 'g' 'alpha' 'plotb' 'F' 'intF' 'DJN_beachwidth' 'DJN_slopes' 'dlambda' 'dsigma' 'DJN_x' 'DJN_eta'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Convert back to physical varables

disp('Converting Approx data...')
Phiout=Phiout';
Psiout=Psiout';
lambda=lambda';



% Data Needed to convert both exact and aprox data
[LAM, Fgrid] = meshgrid(-lambda, F);
[~, intgrid] = meshgrid(-lambda, intF);


% Convert Aprox.
u2 = Psiout./Fgrid;
eta2=(Phiout-u2.^(2))/(2*g);
t2=-(LAM-u2)/(alpha*g);
x2 = (Phiout-u2.^(2)-intgrid)/(2*alpha*g);


%%%%%%%%%
x21=x2(3:end,:);       t21=t2(3:end,:);
eta21=eta2(3:end,:);   u21=u2(3:end,:);

Feta = TriScatteredInterp(x21(:),t21(:),eta21(:));
Ueta = TriScatteredInterp(x21(:),t21(:),u21(:));

min_x=-2000;         min_t=0; max_t=max(max(t21));
dt=1;

xref=max(x21(:));
x1=zeros(200,1);
xl(1)=xref*1.1;
dx=xref/10; 
factor=1.05;
for i=2:200
    dx=dx*factor;
    xl(i)=xl(i-1)-dx;
end
xl=(xl-xref)*min_x/min(xl-xref)+xref;
plot(xl,'.')


[t,x]=meshgrid(min_t:dt:max_t, xl);
etatmp=Feta(x, t);
utmp=Ueta(x, t);

tmpx=interp1(t21(1,:), x21(1,:), t);
index=(x>tmpx);
etatmp(index)=NaN;
utmp(index)=NaN;

x2=x;
t2=t;
eta2=etatmp;
u2=utmp;
    


toc
% [J, UL, US]=Jacobian(F,g,alpha,u2,sigma,lambda,dsigma,dlambda);

%clearvars -except  'u2'  'eta2' 'x2' 't2' 'm' 'g' 'alpha' 'lambda' 'sigma' 'Exact' 'plotb' 'DJN_beachwidth' 'DJN_slopes' 'DJN_x' 'DJN_eta' 'J' 'UL' 'US' 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot the data

% Look for break in time.
disp('Plotting...')
% [dummy,I]=sort(t2*alpha,2);
% found=0;
% brokeat=length(t2(1,:))+1;
% for j=1:length(t2(1,:))
%     if I(2,j)~=j
%         found=1;
%         brokeat=j;
%         break
%     end
% end


if plotb
    
% % %     % Plot to look for global error and information
%     slope=zeros(1,length(lambda));
%     breakc=slope;
%     for j=1:length(lambda)
%         for i=1:length(eta2(:,1))-1
%             slope(i)=(eta2(i+1,j)-eta2(i,j))/(x2(i+1,j)-x2(i,j));
%         end
%         breakc(j)=max(slope(:));
%     end
%     for i=1:length(lambda)
%         % %         if ((breakc(i)>=1/2*alpha)||(i==brokeat))
%         % %             disp('BROKE...')
%         % %             if found
%         % %                 disp('Numerical')
%         % %             end
%         % %             %break
%         % %         end
%         index1=(J(:,i)>=0);
%         index2=~index1;
%         plot(sigma(index1), eta2(index1,i), '.r')
%         hold on
%         plot(sigma(index2), eta2(index2,i), '.b')
%         plot(sigma, J(:,i), '-k')
%         hold off
%         axis([0 300 min(min(eta2)) max(max(eta2))])
%         leg=legend('Aprox solution');
%         % set(leg,'Location','Best');
%         xlabel('Sigma')
%         title(num2str(t2(2,i)))
%         pause(0.01)
%     end
    
    % Plot at the shore
    x=-3*max(max(x2)):.1:2*max(max(x2));
    for i=1:size(t2,2)
%         if ((breakc(i)>=1/2*alpha)||(i==brokeat))
%             disp('BROKE...')
%             if found
%                 disp('Numerical')
%             end
%             %break
%         end
        
        plot(x2(:,i), eta2(:,i),'.r')
        hold on
        plot(x,alpha*x)
        plot(0, 0, '^b')
        hold off
        %axis([1.5*(-1*(max(max(eta2))-min(min(eta2)))/alpha+max(max(x2))) 1.5*max(max(x2)) 1.5*min(min(eta2)) 1.5*max(max(eta2))])
        axis([-2350 1.5*max(max(x2)) max(min(min(eta2)), -1) 1.5*max(max(eta2))])
        leg=legend('Aprox Solution');
        xlabel('x')
        title(num2str(t2(2,i)))
        
        results.snapshot{i}.x=x2(:,i);
        results.snapshot{i}.eta=eta2(:,i);
        results.snapshot{i}.time=t2(2,i);
        results.snapshot{i}.u=u2(2,i);
        results.max_runup=max(max(eta2));
        results.case=['case_',num2str(DJN_beachwidth),'m_',num2str(1/DJN_slopes),'_',num2str(alpha)];
            hold on
    plot(DJN_x, DJN_eta,'-b')
    hold off
        pause(0.1)
    end
    hold on
    plot(DJN_x, DJN_eta,'-b')
    hold off
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%plot top down%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     addpath(genpath(pwd))
%     x_axis   = [min(min(x2))  , max(max(x2))+10];
%     eta_axis = [min(min(eta2)), max(max(eta2)) ];
%     max_height = eta_axis(2) - x_axis(1)*alpha;
%     max_y      = max_height/DJN_slopes + DJN_beachwidth/2;
%     bath.height = [max_height; 0];
%     bath.left   = [-max_y; -DJN_beachwidth/2];
%     bath.right  = [ max_y;  DJN_beachwidth/2];
%     bath.slope  = alpha;
%     plotWave(x2,eta2,t2(1,:),bath)
%     
%     
    
    
    
    
    
    
end

save(['analytical_nw_',results.case,'tmp.mat'], 'results')