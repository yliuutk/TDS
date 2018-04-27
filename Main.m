% Time domain simulation using GENCLS model
% Yang Liu; yliu161@vols.utk.edu

clear all
close all
clc
warning off
global GLO

%% settings
GLO.Base   = 100;   % baseMVA
GLO.w0     = 1;     % nominal frequency, p.u.
FtBus      = 7;     % Fault bus
FtLine     = [6,7]; % Fault line
FtLineIdx  = 15;    % Fault line index in mpc.branch
FtTime     = 5/60;  % Fault clearing time (second)
TotalTime  = 10;    % Total simulation time (second)
TimeRange1 = [0,1]; % pre-fault simulation time (second)
TimeRange2 = [TimeRange1(2),TimeRange1(2)+FtTime]; % fault-on simulation time
TimeRange3 = [TimeRange2(2),TotalTime]; % post-fault simulation time

%% Solve power flow
[mpc SUCESS]     = runpf(twoarea);

MPC2 = MPC
MPC2.GEN(2,3)=100;
[mpc3 SUCESS]     = runpf(MPC2);

%% ReadDynamicData
GLO.H    = [90 45 90 54]';
GLO.Xd   = [0.2 0.2 0.2 0.2]';
GLO.Xdp  = [0.0333 0.0333 0.0333 0.0333]';
GLO.Xqp  = [0.0333 0.0333 0.0333 0.0333]';
GLO.Ra   = [0 0 0 0]';
% GLO.D    = [45 45 45 45]';
GLO.D    = [0 0 0 0]';

%% Initialization
GenIdx       = [1 2 3 4];
LoadIdx      = [7 9];
NonGenIdx    = [5 6 7 8 9 10 11];

Vtx          = mpc.bus(:,8).*cos(mpc.bus(:,9)*pi/180);
Vty          = mpc.bus(:,8).*sin(mpc.bus(:,9)*pi/180);
Vt           = Vtx + 1i*Vty; % terminal voltage
GenPQ        = (mpc.gen(:,2)+1i*mpc.gen(:,3))./GLO.Base;
LoadPQ       = (mpc.bus(LoadIdx,3)+1i*mpc.bus(LoadIdx,4))./GLO.Base;

x0.Vt        = Vt(GenIdx,:);       % terminal voltage of generator bus
x0.It        = conj(GenPQ./x0.Vt); % current injection
x0.EQ        = x0.Vt + (GLO.Ra+1i*GLO.Xdp).*x0.It; % internal voltage
x0.dta       = angle(x0.EQ);% rotor angle
x0.omg       = [0 0 0 0]';  % rotor speed

x0.Pe        = real(x0.EQ.*conj((x0.EQ-x0.Vt)./(GLO.Ra+1i*GLO.Xdp))); 
x0.Pm        = x0.Pe + GLO.D.*x0.omg/GLO.w0;        
x0.Yload     = conj(LoadPQ./abs(Vt(LoadIdx,:)).^2); % constant Z load
GLO.Ef       = abs(x0.EQ); % field voltage
GLO.Pm       = x0.Pm;      % mechanical power

%% Form the Ybus matrix of pre-fault stage
Ybus_pre      = makeYbus(GLO.Base, mpc.bus, mpc.branch);
Ybus_pre(7,7) = Ybus_pre(7,7)+x0.Yload(1);
Ybus_pre(9,9) = Ybus_pre(9,9)+x0.Yload(2);

%% Form the Ybus matrix of fault-on stage
Ybus_on              = Ybus_pre;
Ybus_on(FtBus,FtBus) = 10^10; % inf

%% Form the Ybus matrix of post-fault stage
Ybus_post = Ybus_pre;
rxb       = mpc.branch(FtLineIdx ,3:5);
ys        = 1/(rxb(1)+1i*rxb(2));
yp        = 1i*rxb(3);
Y_FtLine  = [ys+yp,-ys; -ys,ys+yp]; % contribution of the fault line
Ybus_post(FtLine,FtLine) = Ybus_post(FtLine,FtLine) - Y_FtLine;

%% Kron reduction
Yi_pre  = KronReduction(Ybus_pre,x0.dta,GenIdx,NonGenIdx);
Yi_on   = KronReduction(Ybus_on,x0.dta,GenIdx,NonGenIdx);
Yi_post = KronReduction(Ybus_post,x0.dta,GenIdx,NonGenIdx);

%% Pre-fault simulation
x0_ini = [x0.dta(1) x0.omg(1) x0.dta(2) x0.omg(2) x0.dta(3) x0.omg(3) x0.dta(4) x0.omg(4) ]';
GLO.Yi = Yi_pre;
[t_pre,sol_pre] = ode45(@GENCLS,TimeRange1,x0_ini);

%% fault-on simulation
GLO.Yi = Yi_on;
[t_on,sol_on] = ode45(@GENCLS,TimeRange2,sol_pre(end,:)');

%% post-fault simulation
GLO.Yi = Yi_post;
[t_post,sol_post] = ode45(@GENCLS,TimeRange3,sol_on(end,:)');

t   = [t_pre;t_on(2:end);t_post(2:end)];
sol = [sol_pre;sol_on(2:end,:);sol_post(2:end,:)];

%% Display the rotor angle differences
anglediff = sol(:,1:2:8)-sol(:,1)*ones(1,4);
figure(1)
plot(t,anglediff(:,1:end)*180/pi,'LineWidth',1);hold on;
xlabel('Time (s)')
ylabel('Relative Rotor angles (degree)')
set(gca, 'Fontname', 'Times New Roman', 'Fontsize', 12);
hold off
box on

%% Prony analysis
test_t    = t(end/2:end);
test_data = anglediff(end/2:end,4);
[iapp,ai,a_list,tau_list,omega_list,~,~,~] = applyprony(test_t,test_data,8,6,1);
f       = omega_list/2/pi; % frequency
a       = abs(a_list)*2;   % amplitude
sigma   = 1./tau_list ;    
damp    = -sigma./(sqrt(sigma.^2+omega_list.^2));% damping
Mode    = [f,a,damp];
return


%% SUBFUNCTION --- NO NEED TO CHANGE
function Yi = KronReduction(Ybus,dta,GenIdx,NonGenIdx)

global GLO

Ynn = Ybus(NonGenIdx,NonGenIdx);
Ymm = Ybus(GenIdx,GenIdx);
Ynm = Ybus(NonGenIdx,GenIdx);
Yt  = (Ymm - Ynm.'/Ynn*Ynm);

T1 = zeros(8,8);T2=T1;
for i = 1:4
  T1(2*i-1:2*i,2*i-1:2*i) = [sin(dta(i)) -cos(dta(i)); cos(dta(i)) sin(dta(i))];
  T2(2*i-1:2*i,2*i-1:2*i) = [GLO.Ra(i) -GLO.Xqp(i); GLO.Xdp(i) GLO.Ra(i)];
end

Yr = zeros(size(T1));
Yr(1:2:end,1:2:end) = real(Yt);
Yr(1:2:end,2:2:end) = -imag(Yt);
Yr(2:2:end,1:2:end) = imag(Yt);
Yr(2:2:end,2:2:end) = real(Yt);
Y = (T1/Yr+T2*T1)\T1;
Yi = Y(1:2:end,1:2:end) - 1i*Y(1:2:end,2:2:end);
end

