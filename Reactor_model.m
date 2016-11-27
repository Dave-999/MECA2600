function m = Reactor_model(t_final,dt_plot,P_stable,PF_retarded)
tic
%Donnees

V = 30; %Volume du reacteur en [m^3]
m_Utot = 1000; %Masse d'Uranium [kg]

m_U235 = m_Utot*0.07; %Masse d'U235 [kg]
N_U235 = m_U235/molarMass('U235'); %Nombre de moles d'U235 [mol]

m_U238 = m_Utot*0.93; %Masse d'U238 [kg]
N_U238 = m_U238/molarMass('U238'); %Nombre de moles d'U238 [mol]

E_thermal = 0.025; %[eV]
E_fast = 1e6; %[eV]

v_thermal = 10; %[m/s]
v_fast= 1000; %[m/s]

n_thermal = 1e10; %Nombre de neutrons thermiques en t=0
flux_thermal = n_thermal*v_thermal/V; %Flux de neutrons thermiques en t=0 [#/m^2.s]

NA = 6.022e23;

%--------------------------------------------------------------------------
%%

fis_U235 = Section_efficace('U235','Fission',E_thermal,'DATABASE');
cap_U235 = Section_efficace('U235','Capture',E_thermal,'DATABASE');
demi_U235 = Demi_vie('U235','Alpha');
    
fis_U238 = Section_efficace('U238','Fission',E_thermal,'DATABASE');
cap_U238 = Section_efficace('U238','Capture',E_thermal,'DATABASE');
demi_U238 = Demi_vie('U238','Alpha');
    
fis_U239 = Section_efficace('U239','Fission',E_thermal,'DATABASE');
demi_U239 = Demi_vie('U239','BetaMinus');
    
fis_Np239 = Section_efficace('Np239','Fission',E_thermal,'DATABASE');
demi_Np239 = Demi_vie('Np239','BetaMinus');
    
fis_Pu239 = Section_efficace('Pu239','Fission',E_thermal,'DATABASE');
demi_Pu239 = Demi_vie('Pu239','Alpha');


t_final = 10; %[s]
dt_gen = 10^-4;
T = [0:dt_gen:t_final];
Y = zeros(length(T),6); %U235,U238,U239,Np239,Pu239,PF*
Y(1,:) = [N_U235 N_U238 0 0 0 0]; %Quantit�s initiales
N = zeros(length(T),1); %Flux de neutrons thermiques
N(1,1) = flux_thermal;

for i = 2:length(T)
    Y(i,1) = Y(i-1,1) + (- Y(i-1,1)*fis_U235*1e-28*N(i-1,1) - Y(i-1,1)*cap_U235*1e-28*N(i-1,1) - Y(i-1,1)*log(2)/demi_U235)*dt_gen; %U235
    Y(i,2) = Y(i-1,2) + (- Y(i-1,2)*cap_U238*1e-28*N(i-1,1) - Y(i-1,2)*log(2)/demi_U238)*dt_gen; %U238
    Y(i,3) = Y(i-1,3) + (Y(i-1,2)*cap_U238*1e-28*N(i-1,1) - Y(i-1,3)*fis_U239*1e-28*N(i-1,1) - Y(i-1,3)*log(2)/demi_U239)*dt_gen; %U239
    Y(i,4) = Y(i-1,4) + (Y(i-1,3)*log(2)/demi_U239 - Y(i-1,4)*fis_Np239*1e-28*N(i-1,1) - Y(i-1,4)*log(2)/demi_Np239)*dt_gen; %Np239
    Y(i,5) = Y(i-1,5) + (Y(i-1,4)*log(2)/demi_Np239 - Y(i-1,5)*fis_Pu239*1e-28*N(i-1,1) - Y(i-1,5)*log(2)/demi_Pu239)*dt_gen; %Pu239
    Y(i,6) = Y(i-1,6) + (Y(i-1,1)*fis_U235*1e-28*N(i-1,1) + Y(i-1,3)*fis_U239*1e-28*N(i-1,1) + Y(i-1,4)*fis_Np239*1e-28*N(i-1,1) + Y(i-1,5)*fis_Pu239*1e-28*N(i-1,1))*2*dt_gen; %PF*

    N(i,1) = N(i-1,1) + (Y(i-1,1)*fis_U235*1e-28*N(i-1,1) + Y(i-1,1)*fis_U238*1e-28*N(i-1,1) - Y(i-1,1)*cap_U235*1e-28*N(i-1,1) - Y(i-1,2)*cap_U238*1e-28*N(i-1,1) + Y(i-1,3)*fis_U239*1e-28*N(i-1,1) + Y(i-1,4)*fis_Np239*1e-28*N(i-1,1) + Y(i-1,5)*fis_Pu239*1e-28*N(i-1,1))*NA*dt_gen; %Flux
end

% t_final = 10; %[s]
% [T,Y] = ode45(@fun,[0,t_final],[N_U235,N_U238,0,0,0,0]);

figure;
semilogy(T,Y(:,1));
hold on;
semilogy(T,Y(:,2));
hold on;
semilogy(T,Y(:,3));
hold on;
semilogy(T,Y(:,4));
hold on;
semilogy(T,Y(:,5));
hold on;
semilogy(T,Y(:,6));
xlabel('Temps [s]');
ylabel('Esp�ces [mol]');
legend('U235','U238','U239','Np239','Pu239','PF*','Location','southeast');
hold off;

figure;
semilogy(T,N(:,1));
xlabel('Temps [s]');
ylabel('Flux de neutrons thermiques [#/m^2.s]');


toc
end