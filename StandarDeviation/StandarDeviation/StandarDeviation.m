clear all; close all; clc
file = fopen('attitude24h.float');
[M, c] = fread(file, [4, inf], 'float', 'b');
fclose(file);
%%
temp = M(1,:)';
yaw = M(2,:)';
pitch = M(3,:)';
roll = M(4,:)';

% sum(isnan(temp))
% sum(isnan(yaw))
% sum(isnan(pitch))
% sum(isnan(roll))
%%
valid = (temp > 5) & (temp < 50) ;
temp = temp(valid);
yaw = yaw(valid);
pitch = pitch(valid);
roll = roll(valid);

%%
novalid = (-pi > yaw) | ( yaw > pi) | (isnan(yaw));
temp(novalid) = [];
yaw(novalid) = [];
pitch(novalid) = [];
roll(novalid) = [];

%%
novalid = (0.1*pi/180 > pitch) | ( pitch > 90*pi/180) | (isnan(pitch));
temp(novalid) = [];
yaw(novalid) = [];
pitch(novalid) = [];
roll(novalid) = [];

%%
novalid = (-pi > roll) | ( roll > pi) | (isnan(roll));
temp(novalid) = [];
yaw(novalid) = [];
pitch(novalid) = [];
roll(novalid) = [];
%%
yaw = yaw * 180/pi;
pitch = pitch * 180/pi;
roll = roll * 180/pi;

%%
novalid = (20 > yaw);
temp(novalid) = [];
yaw(novalid) = [];
pitch(novalid) = [];
roll(novalid) = [];
%%
novalid =  ( pitch > 5) ;
temp(novalid) = [];
yaw(novalid) = [];
pitch(novalid) = [];
roll(novalid) = [];
%%
novalid = (-5 > roll) | ( roll > 5) | ( (-1e-3 < roll)&(roll < 1e-3)) ;
temp(novalid) = [];
yaw(novalid) = [];
pitch(novalid) = [];
roll(novalid) = [];

% plot(roll),shg


stryaw = sprintf('\\sigma_{yaw} = %f',std(yaw));
strpitch = sprintf('\\sigma_{pitch} = %f',std(pitch));
strroll = sprintf('\\sigma_{roll} = %f',std(roll));
%%
% N = 10000;
% m = round(length(temp)/N);
% t = 1:m:length(temp);
% %%
% subplot(221)
% plot(temp(t))
% title('Temperatura')
% ylabel('ºC')
% subplot(222)
% plot(yaw(t))
% title('Yaw')
% ylabel('degree')
% text(2000,32,stryaw);
% subplot(223)
% plot(pitch(t))
% title('Pitch')
% ylabel('degree')
% text(2000,0.3,strpitch);
% subplot(224)
% plot(roll(t)),shg
% title('Roll')
% ylabel('degree')
% text(2000,-0.9,strroll);
% %%
% subplot(111)
% plot(temp,yaw, 'rx'),shg
% title('Yaw en funcion de la temperatura')
% xlabel('Temperatura en ºC')
% ylabel('degree')
% text(20,32,stryaw);
% 
% plot(temp,pitch, 'rx'),shg
% title('Pitch en funcion de la temperatura')
% xlabel('Temperatura en ºC')
% ylabel('degree')
% text(20,0.55,strpitch);
% 
% plot(temp,roll, 'rx'),shg
% title('Roll en funcion de la temperatura')
% xlabel('Temperatura en ºC')
% ylabel('degree')
% text(20,-0.7,strroll);
% %%
% subplot(221)
% plot(temp)
% title('Temperatura')
% ylabel('ºC')
% subplot(222)
% plot(yaw)
% title('Yaw')
% ylabel('degree')
% text(1e6,31,stryaw);
% subplot(223)
% plot(pitch)
% title('Pitch')
% ylabel('degree')
% text(1e6,0.6,strpitch);
% subplot(224)
% plot(roll),shg
% title('Roll')
% ylabel('degree')
% text(1e6,2,strroll);
% %%
% 
% subplot(221)
% plot(temp)
% title('Temperatura')
% ylabel('ºC')
% subplot(222)
% hist(yaw,1000)
% title('Yaw')
% subplot(223)
% hist(pitch,1000)
% title('Pitch')
% subplot(224)
% hist(roll(roll<0),1000),shg
% title('Roll')

%%
% Calibracion Yaw
yawOffset = yaw - 32.5;
plot(temp,yawOffset,'rx')
m = length(temp);
X = [ones(m, 1), temp]; % Add a column of ones to x
theta = zeros(2, 1); % initialize fitting parameters
%%
% Some gradient descent settings
iterations = 30;
alpha = 0.001;

% figure(2);
y = yawOffset;
theta = [ -3.5 0.1 ]';
% compute and display initial cost
computeCostMulti(X, y, theta)

% run gradient descent
% theta = gradientDescent(X, y, theta, alpha, iterations);
[theta1, J_history] = gradientDescentMulti(X, y, theta, alpha, iterations);
% print theta to screen
fprintf('Theta found by gradient descent: \n');
fprintf('Incluir en el codigo la siguiente linea \n');
fprintf('const float GyroThetaX = {%f, %f}; \n', theta1(1), theta1(2));
computeCostMulti(X, y, theta1)
plot(1:numel(J_history), J_history, '-b', 'LineWidth', 2);

plot(X(:,2), yawOffset,'bx');
% Plot the linear fit
hold on; % keep previous plot visible
plot(X(:,2), X*theta1, 'rx')
legend('Datos de entrenamiento', 'Curva aprendida')
hold off % don't overlay any more plots on this figure

% Predict values for population sizes of 35,000 and 70,000
predict1 = [1, 35] *theta1;

%%
yawcalibrado = yaw - X*theta1;

stryaw = sprintf('\\sigma_{yaw} = %f',std(yawcalibrado));
strcal = sprintf('\\theta_{yaw} = [ %f, %f]', theta1(1), theta1(2));
n = 1:3:length(temp);
plot(temp,yawcalibrado,'rx'),shg
title('Yaw calibrado en funcion de la temperatura')
xlabel('Temperatura en ºC')
ylabel('degree')
text(20,32,stryaw);
text(20,32.8,strcal);

%%
hist(yawcalibrado,1000),shg
title('Yaw calibrado')
text(32.2,10000,stryaw);

%%
%%
% Calibracion Pich
pitchOffset = pitch - 0.4;
% plot(temp,pitchOffset,'rx')
% grid
m = length(temp);
X = [ones(m, 1), temp]; % Add a column of ones to x
theta = zeros(2, 1); % initialize fitting parameters
%%
% Some gradient descent settings
iterations = 30;
alpha = 0.001;

% figure(2);
y = pitchOffset;
theta = [ -0.3 0.01 ]';
% compute and display initial cost
computeCostMulti(X, y, theta)

% run gradient descent
% theta = gradientDescent(X, y, theta, alpha, iterations);
[theta2, J_history2] = gradientDescentMulti(X, y, theta, alpha, iterations);
% print theta to screen
fprintf('Theta found by gradient descent: \n');
fprintf('Incluir en el codigo la siguiente linea \n');
fprintf('const float GyroThetaX = {%f, %f}; \n', theta2(1), theta2(2));
computeCostMulti(X, y, theta2)
plot(1:numel(J_history2), J_history2, '-b', 'LineWidth', 2);

plot(X(:,2), pitchOffset,'bx');
% Plot the linear fit
hold on; % keep previous plot visible
plot(X(:,2), X*theta2, 'rx')
legend('Datos de entrenamiento', 'Curva aprendida')
hold off % don't overlay any more plots on this figure

%%
pitchcalibrado = pitch - X*theta2;

strpitch = sprintf('\\sigma_{pitch} = %f',std(pitchcalibrado));
strcal = sprintf('\\theta_{pitch} = [ %f, %f]', theta2(1), theta2(2));
n = 1:3:length(temp);

plot(temp(n),pitchcalibrado(n),'rx'),shg
title('Pitch calibrado lineal en funcion de la temperatura')
xlabel('Temperatura en ºC')
ylabel('degree')
text(20,0.3,strpitch);
text(20,0.6,strcal);
axis([15 40 0.2 0.65])
%%
hist(pitchcalibrado,1000),shg
title('Pitch calibrado lineal')
text(0.45,1.5e4,strpitch);

%%
%%
% Calibracion Pich
n = 1:10:length(temp);
% plot(temp(n),pitch(n),'rx')
% grid
pitchOffset = pitch - 0.4;
% plot(temp(n),pitchOffset(n),'rx')
% grid
m = length(temp);
X = [ones(m, 1), temp temp.^2]; % Add a column of ones to x
% X = [temp temp.^2 ];
% % X = [temp3, tempgyro3, temp3.^2, temp3 .* tempgyro3 ];
% [X mu sigma] = featureNormalize(X);
% X = [ones(m, 1) X];
%%
% Some gradient descent settings
iterations = 50;
alpha = 0.0000001;



% figure(2);
y = pitchOffset;
theta = [ -8 0.4 -0.005]';

x0 = 50;
y0 = 0.05;
p = 3000;

theta(3) = -1/(2*p);
theta(2) = x0/p;
theta(1) = y0 + x0^2 * theta(3);

% plot(temp(n), pitchOffset(n),'bx');
% % Plot the linear fit
% newoff = X*theta;
% hold on; % keep previous plot visible
% plot(temp(n), newoff(n), 'rx')
% legend('Datos de entrenamiento', 'Curva aprendida')
% hold off % don't overlay any more plots on this figure

% compute and display initial cost
computeCostMulti(X, y, theta)

% run gradient descent
% theta = gradientDescent(X, y, theta, alpha, iterations);
[theta3, J_history3] = gradientDescentMulti(X, y, theta, alpha, iterations);
% print theta to screen
fprintf('Theta found by gradient descent: \n');
fprintf('Incluir en el codigo la siguiente linea \n');
fprintf('const float GyroThetaX = {%f, %f, %f}; \n', theta3(1), theta3(2), theta3(2));
computeCostMulti(X, y, theta3)
plot(1:numel(J_history3), J_history3, '-b', 'LineWidth', 2);

strcal = sprintf('\\theta_{pitch} = [ %f, %f, %f]', theta3(1), theta3(2), theta3(3));
n = 1:10:length(temp);
plot(temp(n), pitchOffset(n),'bx');
% Plot the linear fit
newoff = X*theta3;
hold on; % keep previous plot visible
plot(temp(n), newoff(n), 'rx')
legend('Datos de entrenamiento', 'Curva aprendida')
hold off
text(20,0.05,strcal)
%%
pitchcalibrado = pitch - X*theta3;

strpitch = sprintf('\\sigma_{pitch} = %f',std(pitchcalibrado));
strcal = sprintf('\\theta_{pitch} = [ %f, %f, %.8f]', theta3(1), theta3(2), theta3(3));
n = 1:3:length(temp);

plot(temp(n),pitchcalibrado(n),'rx'),shg
title('Pitch calibrado cuadratico en funcion de la temperatura')
xlabel('Temperatura en ºC')
ylabel('degree')
text(20,0.55,strpitch);
text(20,0.6,strcal);
axis([15 40 0.2 0.65])
%%
hist(pitchcalibrado,1000),shg
title('Pitch calibrado Cuadratico')
text(0.45,1.5e4,strpitch);

