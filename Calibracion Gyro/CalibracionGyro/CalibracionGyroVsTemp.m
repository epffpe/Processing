clear all; close all; clc
file = fopen('gyroTempRAW_10_40.float');
[M, c] = fread(file, [5, inf], 'float', 'b');
fclose(file);
%%  Extraigo los parametros del archivo
temp = M(1,:)';
tempgyro = M(2,:)';
gyrox = M(3,:)';
gyroy = M(4,:)';
gyroz = M(5,:)';
%% Elimino las muestras malas fijandome en la temperatura
valid = temp > 5;
temp = temp(valid);
tempgyro = tempgyro(valid);
gyrox = gyrox(valid);
gyroy = gyroy(valid);
gyroz = gyroz(valid);

%%
novalid = (-150 > gyrox) | ( gyrox > 150);
temp(novalid) = [];
tempgyro(novalid) = [];
gyrox(novalid) = [];
gyroy(novalid) = [];
gyroz(novalid) = [];
%%
novalid = (-150 > gyroy) | ( gyroy > 150);
temp(novalid) = [];
tempgyro(novalid) = [];
gyrox(novalid) = [];
gyroy(novalid) = [];
gyroz(novalid) = [];

%%
novalid = (-150 > gyroz) | ( gyroz > 150) | isnan(gyroz);
temp(novalid) = [];
tempgyro(novalid) = [];
gyrox(novalid) = [];
gyroy(novalid) = [];
gyroz(novalid) = [];

% plot(gyroz);
% axis([1 length(temp) -1000 1000]),shg

%%
% subplot(311);
% plot(temp, gyrox, 'rx', 'MarkerSize',10);
% title('Gyroscopo eje X');
% xlabel('Temperatura')
% ylabel('Gyro Offset')
% subplot(312);
% plot(temp, gyroy, 'rx', 'MarkerSize',10);
% xlabel('Temperatura')
% ylabel('Gyro Offset')
% title('Gyroscopo eje Y');
% subplot(313);
% plot(temp, gyroz, 'rx', 'MarkerSize',10);shg
% xlabel('Temperatura')
% ylabel('Gyro Offset')
% title('Gyroscopo eje Z');

%%
% subplot(311);
% plot(tempgyro, gyrox, 'rx', 'MarkerSize',10);
% title('Gyroscopo eje X');
% xlabel('Temperatura Gyro')
% ylabel('Gyro Offset')
% subplot(312);
% plot(tempgyro, gyroy, 'rx', 'MarkerSize',10);
% xlabel('Temperatura Gyro')
% ylabel('Gyro Offset')
% title('Gyroscopo eje Y');
% subplot(313);
% plot(tempgyro, gyroz, 'rx', 'MarkerSize',10);shg
% xlabel('Temperatura Gyro')
% ylabel('Gyro Offset')
% title('Gyroscopo eje Z');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
valid = temp > 10;
temp = temp(valid);
tempgyro = tempgyro(valid);
gyrox = gyrox(valid);
gyroy = gyroy(valid);
gyroz = gyroz(valid);


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
file = fopen('gyroTempRAW_30_40.float');
[M, c] = fread(file, [5, inf], 'float', 'b');
fclose(file);

%%  Extraigo los parametros del archivo
temp2 = M(1,:)';
tempgyro2 = M(2,:)';
gyro2x = M(3,:)';
gyro2y = M(4,:)';
gyro2z = M(5,:)';
%% Elimino las muestras malas fijandome en la temperatura
valid = temp2 > 25;
temp2 = temp2(valid);
tempgyro2 = tempgyro2(valid);
gyro2x = gyro2x(valid);
gyro2y = gyro2y(valid);
gyro2z = gyro2z(valid);
%%
valid = tempgyro2 > 200;
tempgyro2(valid) = tempgyro2(valid) - 256;

%%
novalid = (-150 > gyro2y) | ( gyro2y > 150);
temp2(novalid) = [];
tempgyro2(novalid) = [];
gyro2x(novalid) = [];
gyro2y(novalid) = [];
gyro2z(novalid) = [];

%%
novalid = (-150 > gyro2z) | ( gyro2z > 150) | isnan(gyro2z);
temp2(novalid) = [];
tempgyro2(novalid) = [];
gyro2x(novalid) = [];
gyro2y(novalid) = [];
gyro2z(novalid) = [];

% plot(tempgyro2),shg
%%
temp3 = [temp;temp2];
tempgyro3 = [tempgyro;tempgyro2];
gyro3x = [gyrox;gyro2x];
gyro3y = [gyroy;gyro2y];
gyro3z = [gyroz;gyro2z];
% sum(isnan(gyro2z))

%%
% figure(1)
% subplot(311);
% plot(temp3, gyro3x, 'rx', 'MarkerSize',10);
% title('Gyroscopo eje X');
% xlabel('Temperatura')
% ylabel('Gyro Offset')
% subplot(312);
% plot(temp3, gyro3y, 'rx', 'MarkerSize',10);
% xlabel('Temperatura')
% ylabel('Gyro Offset')
% title('Gyroscopo eje Y');
% subplot(313);
% plot(temp3, gyro3z, 'rx', 'MarkerSize',10);shg
% xlabel('Temperatura')
% ylabel('Gyro Offset')
% title('Gyroscopo eje Z');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Aplicando Gradient Descent a gyrox...\n')
m = length(temp3);
% X = [ones(m, 1), temp3, tempgyro3, temp3.^2, tempgyro3.^2, temp3 .* tempgyro3 ]; % Add a column of ones to x
% theta = zeros(6, 1); % initialize fitting parameters
X = [temp3, tempgyro3, temp3.^2, tempgyro3.^2, temp3 .* tempgyro3 ];
% X = [temp3, tempgyro3, temp3.^2, temp3 .* tempgyro3 ];
[X mu sigma] = featureNormalize(X);
X = [ones(m, 1) X];
%%
% Some gradient descent settings
iterations = 500;
alpha = 0.01;

% figure(2);
y = gyro3x;
% theta = [ 137 -3.8 -1]';
% theta = [ 90 -3.8 -0.1 0 0 0]';
% theta = [ 0 -3.8 0 0 0 0]';
theta = [ -36.111296, -8.312006, 4.370051, -4.458925, 4.191510, 3.901900]';
% theta = [ -34.710552, -9.848857, 5.748318, -5.502377, 3.752127]';
% compute and display initial cost
computeCostMulti(X, y, theta)

% run gradient descent
% theta = gradientDescent(X, y, theta, alpha, iterations);
[theta1, J_history] = gradientDescentMulti(X, y, theta, alpha, iterations);
% print theta to screen
fprintf('Theta found by gradient descent: \n');
fprintf('Incluir en el codigo la siguiente linea \n');
fprintf('const float GyroThetaX = {%f, %f, %f, %f, %f, %f}; \n', theta1(1), theta1(2), theta1(3), theta1(4), theta1(5), theta1(6));
% fprintf('const float GyroThetaX = {%f, %f, %f, %f, %f}; \n', theta1(1), theta1(2), theta1(3), theta1(4), theta1(5));
computeCostMulti(X, y, theta1)
plot(1:numel(J_history), J_history, '-b', 'LineWidth', 2);shg

plot(X(:,2), gyro3x,'bx');shg
% Plot the linear fit
hold on; % keep previous plot visible
plot(X(:,2), X*theta1, 'rx')
legend('Datos de entrenamiento', 'Curva aprendida')
hold off % don't overlay any more plots on this figure

plot(X(:,3), gyro3x,'bx');shg
% Plot the linear fit
hold on; % keep previous plot visible
plot(X(:,3), X*theta1, 'rx')
legend('Datos de entrenamiento', 'Curva aprendida')
hold off
%%
% Some gradient descent settings
iterations = 300;
alpha = 0.01;
y = gyro3y;
% theta = [ -0.000945  0.282421 0.085632]';
% theta = [ 47 -0.7 -1]';
% theta = [ 0 0 0]';
theta = [ 6.008141, -0.154777, 0.189613, -0.307960, -0.208153, 0.589281]';
% compute and display initial cost
computeCostMulti(X, y, theta)

% run gradient descent
[theta2, J_history2] = gradientDescentMulti(X, y, theta, alpha, iterations);
% print theta to screen
fprintf('Theta found by gradient descent: \n');
fprintf('Incluir en el codigo la siguiente linea \n');
% fprintf('const float GyroThetaY = {%f, %f, %f}; \n', theta2(1), theta2(2), theta2(3));
fprintf('const float GyroThetaY = {%f, %f, %f, %f, %f, %f}; \n', theta2(1), theta2(2), theta2(3), theta2(4), theta2(5), theta2(6));
computeCostMulti(X, y, theta2)
plot(1:numel(J_history2), J_history2, '-b', 'LineWidth', 2);

plot(X(:,2), gyro3y,'bx');
% Plot the linear fit
hold on; % keep previous plot visible
plot(X(:,2), X*theta2, 'rx')
legend('Datos de entrenamiento', 'Curva aprendida')
hold off % don't overlay any more plots on this figure
shg

plot(X(:,3), gyro3y,'bx');
% Plot the linear fit
hold on; % keep previous plot visible
plot(X(:,3), X*theta2, 'rx')
legend('Datos de entrenamiento', 'Curva aprendida')
hold off

%%
% Some gradient descent settings
iterations = 300;
alpha = 0.01;
% sum(isnan(gyroz))
y = gyro3z;
% theta = [-1.002970, -0.256227, -0.064843]';
% theta = [-1, -0.2, -0.1]';
theta = [ 0, 0, 0, 0, 0, 0]';
% compute and display initial cost
computeCostMulti(X, y, theta)

% run gradient descent
[theta3, J_history3] = gradientDescentMulti(X, y, theta, alpha, iterations);
% print theta to screen
fprintf('Theta found by gradient descent: \n');
fprintf('Incluir en el codigo la siguiente linea \n');
fprintf('const float GyroThetaZ = {%f, %f, %f}; \n', theta3(1), theta3(2), theta3(3));
computeCostMulti(X, y, theta3)
plot(1:numel(J_history3), J_history3, '-b', 'LineWidth', 2);

plot(X(:,2), gyro3z,'bx');
% Plot the linear fit
hold on; % keep previous plot visible
plot(X(:,2), X*theta3, 'rx')
legend('Datos de entrenamiento', 'Curva aprendida')
hold off % don't overlay any more plots on this figure


plot(X(:,3), gyro3z,'bx');
% Plot the linear fit
hold on; % keep previous plot visible
plot(X(:,3), X*theta3, 'rx')
legend('Datos de entrenamiento', 'Curva aprendida')
hold off

%% Calculando los parámetros
GyroThetaX = zeros(6,1);
GyroThetaY = zeros(6,1);
GyroThetaZ = zeros(6,1);

GyroThetaX(2:end) = theta1(2:end)./sigma';
GyroThetaX(1) = theta1(1) - sum( mu' .* GyroThetaX(2:end));

GyroThetaY(2:end) = theta2(2:end)./sigma';
GyroThetaY(1) = theta2(1) - sum( mu' .* GyroThetaY(2:end));

GyroThetaZ(2:end) = theta3(2:end)./sigma';
GyroThetaZ(1) = theta3(1) - sum( mu' .* GyroThetaZ(2:end));

X = [ones(m,1) temp3, tempgyro3, temp3.^2, tempgyro3.^2, temp3 .* tempgyro3 ];

plot(X(:,2), gyro3y,'bx');shg
% Plot the linear fit
hold on; % keep previous plot visible
plot(X(:,2), X*GyroThetaY, 'rx')
legend('Datos de entrenamiento', 'Curva aprendida')
hold off % don't overlay any more plots on this figure

fprintf('Incluir en el codigo la siguiente linea \n');
fprintf('// X = [temp3, tempgyro3, temp3.^2, tempgyro3.^2, temp3 .* tempgyro3 ]; \n');
fprintf('const float GyroThetaX[6] = {%.8f, %.8f, %.8f, %.8f, %.8f, %.8f}; \n' , GyroThetaX(1), GyroThetaX(2), GyroThetaX(3), GyroThetaX(4), GyroThetaX(5), GyroThetaX(6));
fprintf('const float GyroThetaY[6] = {%.8f, %.8f, %.8f, %.8f, %.8f, %.8f}; \n' , GyroThetaY(1), GyroThetaY(2), GyroThetaY(3), GyroThetaY(4), GyroThetaY(5), GyroThetaY(6));
fprintf('const float GyroThetaZ[6] = {%.8f, %.8f, %.8f, %.8f, %.8f, %.8f}; \n' , GyroThetaZ(1), GyroThetaZ(2), GyroThetaZ(3), GyroThetaZ(4), GyroThetaZ(5), GyroThetaZ(6));


%% ============= Part 4: Visualizing J(theta_0, theta_1) =============
fprintf('Visualizing J(theta_0, theta_1) ...\n')

y = gyro3x;

% 
% X = [ones(m, 1) temp3];
% % Grid over which we will calculate J
% theta0_vals = linspace(40, 140, 40);
% theta1_vals = linspace(-6, -2, 40);

X = [temp3];
[X mu sigma] = featureNormalize(X);
X = [ones(m, 1) X];
% Grid over which we will calculate J
theta0_vals = linspace(-55, -20, 50);
theta1_vals = linspace(-40, -10, 50);

% initialize J_vals to a matrix of 0's
J_vals = zeros(length(theta0_vals), length(theta1_vals));

% Fill out J_vals
for i = 1:length(theta0_vals)
    for j = 1:length(theta1_vals)
	  t = [theta0_vals(i); theta1_vals(j)];    
	  J_vals(i,j) = computeCost(X, y, t);
    end
end


% Because of the way meshgrids work in the surf command, we need to 
% transpose J_vals before calling surf, or else the axes will be flipped
J_vals = J_vals';

% Contour plot
% figure;
% Plot J_vals as 15 contours spaced logarithmically between 0.01 and 100
contour(theta0_vals, theta1_vals, J_vals, logspace(-2, 3, 50)),shg
xlabel('\theta_0'); ylabel('\theta_1');

% Surface plot
% figure;
surf(theta0_vals, theta1_vals, J_vals)
xlabel('\theta_0'); ylabel('\theta_1');


