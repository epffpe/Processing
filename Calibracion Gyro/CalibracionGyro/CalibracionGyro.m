file = fopen('gyroRAW.float');
[M, c] = fread(file, [4, inf], 'float', 'b');
fclose(file);
%%  Extraigo los parametros del archivo
temp = M(1,:)';
gyrox = M(2,:)';
gyroy = M(3,:)';
gyroz = M(4,:)';
%% Elimino las muestras malas fijandome en la temperatura
valid = (10 < temp)&(temp < 50);
temp = temp(valid);
gyrox = gyrox(valid);
gyroy = gyroy(valid);
gyroz = gyroz(valid);


%%
novalid = (temp == 11)|(temp == 13);
temp(novalid) = [];
gyrox(novalid) = [];
gyroy(novalid) = [];
gyroz(novalid) = [];
%plot(temp)
%axis([1 length(temp) 10 50]),shg
%% Filtro la temperatura
filtTemp = zeros(size(temp));
filtTemp(1) = temp(1);
for i = 2:length(temp)
    filtTemp(i) = (temp(i) + 15 * filtTemp(i-1)) / 16;
end
% t = 1:length(temp);
% plot(t,temp,'b',t,filtTemp,'r'),shg

%% Recorto las muestras exageradas del gyrox por tramos
low = -50;
high = 70;
t = 1:11e4;
gyro = gyrox(t);
% plot(t,gyro),shg
lowlimit = gyro < low;
uperlimit = gyro > high;
gyro(lowlimit) = low;
gyro(uperlimit) = high;
% plot(t,gyro),shg
gyrox(t) = gyro;
% plot(gyrox),shg

%%
low = -50;
high = 35;
t = 2.1e4:1.1e5;
gyro = gyrox(t);
% plot(t,gyro),shg
lowlimit = gyro < low;
uperlimit = gyro > high;
gyro(lowlimit) = low;
gyro(uperlimit) = high;
% plot(t,gyro),shg
gyrox(t) = gyro;
% plot(gyrox),shg
%%
low = -70;
high = 30;
t = 11e4:2.3e5;
gyro = gyrox(t);
% plot(t,gyro),shg
lowlimit = gyro < low;
uperlimit = gyro > high;
gyro(lowlimit) = low;
gyro(uperlimit) = high;
% plot(t,gyro),shg
gyrox(t) = gyro;
% plot(gyrox),shg

%% Recorto las muestras exageradas del gyroy por tramos
low = -20;
high = 40;
lowlimit = gyroy < low;
uperlimit = gyroy > high;
gyroy(lowlimit) = low;
gyroy(uperlimit) = high;
% plot(gyroy),shg

%% Recorto las muestras exageradas del gyroz por tramos
low = -40;
high = 25;
lowlimit = gyroz < low;
uperlimit = gyroz > high;
gyroz(lowlimit) = low;
gyroz(uperlimit) = high;
% plot(gyroz),shg

%%
% figure(1)
% subplot(311);
% plot(gyrox)
% title('Gyroscopo eje X');
% subplot(312);
% plot(gyroy)
% title('Gyroscopo eje Y');
% subplot(313);
% plot(gyroz),shg
% title('Gyroscopo eje Z');
%%
% figure(2)
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
file = fopen('gyroRAW_38.float');
[M, c] = fread(file, [4, inf], 'float', 'b');
fclose(file);

%%  Extraigo los parametros del archivo
temp4 = M(1,:)';
gyro4x = M(2,:)';
gyro4y = M(3,:)';
gyro4z = M(4,:)';
% figure(3)


%% Elimino las muestras malas fijandome en la temperatura
valid = (29 < temp4)&(temp4 < 50);
temp4 = temp4(valid);
gyro4x = gyro4x(valid);
gyro4y = gyro4y(valid);
gyro4z = gyro4z(valid);

% plot(gyro4z),shg
% axis([1 length(temp4) -200 100]),shg

%% Recorto las muestras exageradas del gyro2x por tramos
low = -200;
high = -60;
lowlimit = gyro4x < low;
uperlimit = gyro4x > high;
gyro4x(lowlimit) = low;
gyro4x(uperlimit) = high;
% plot(gyro4x),shg

%% Recorto las muestras exageradas del gyro2y por tramos
low = -20;
high = 60;
lowlimit = gyro4y < low;
uperlimit = gyro4y > high;
gyro4y(lowlimit) = low;
gyro4y(uperlimit) = high;
% plot(gyro4y),shg

%% Recorto las muestras exageradas del gyro2z por tramos
low = -55;
high = 25;
lowlimit = gyro4z < low;
uperlimit = gyro4z > high;
gyro4z(lowlimit) = low;
gyro4z(uperlimit) = high;
% plot(gyro4z),shg

%%
% subplot(311);
% plot(temp2, gyro2x, 'rx', 'MarkerSize',10);
% title('Gyroscopo eje X');
% xlabel('Temperatura')
% ylabel('Gyro Offset')
% subplot(312);
% plot(temp2, gyro2y, 'rx', 'MarkerSize',10);
% xlabel('Temperatura')
% ylabel('Gyro Offset')
% title('Gyroscopo eje Y');
% subplot(313);
% plot(temp2, gyro2z, 'rx', 'MarkerSize',10);shg
% xlabel('Temperatura')
% ylabel('Gyro Offset')
% title('Gyroscopo eje Z');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
file = fopen('gyroRAW_32_40.float');
[M, c] = fread(file, [4, inf], 'float', 'b');
fclose(file);

%%  Extraigo los parametros del archivo
temp2 = M(1,:)';
gyro2x = M(2,:)';
gyro2y = M(3,:)';
gyro2z = M(4,:)';
% figure(3)


%% Elimino las muestras malas fijandome en la temperatura
valid = (29 < temp2)&(temp2 < 50);
temp2 = temp2(valid);
gyro2x = gyro2x(valid);
gyro2y = gyro2y(valid);
gyro2z = gyro2z(valid);

% plot(gyro2z),shg
% axis([1 length(temp2) -200 100]),shg
%% Filtro la temperatura
filtTemp2 = zeros(size(temp2));
filtTemp2(1) = temp2(1);
for i = 2:length(temp2)
    filtTemp2(i) = (temp2(i) + 15 * filtTemp2(i-1)) / 16;
end
% t = 1:length(temp2);
% plot(t,temp2,'b',t,filtTemp2,'r'),shg


%% Recorto las muestras exageradas del gyro2x por tramos
low = -135;
high = 0;
lowlimit = gyro2x < low;
uperlimit = gyro2x > high;
gyro2x(lowlimit) = low;
gyro2x(uperlimit) = high;
% plot(gyro2x),shg

%% Recorto las muestras exageradas del gyro2y por tramos
low = -20;
high = 45;
lowlimit = gyro2y < low;
uperlimit = gyro2y > high;
gyro2y(lowlimit) = low;
gyro2y(uperlimit) = high;
% plot(gyro2y),shg

%% Recorto las muestras exageradas del gyro2z por tramos
low = -45;
high = 25;
lowlimit = gyro2z < low;
uperlimit = gyro2z > high;
gyro2z(lowlimit) = low;
gyro2z(uperlimit) = high;
% plot(gyro2z),shg

%%
% subplot(311);
% plot(temp2, gyro2x, 'rx', 'MarkerSize',10);
% title('Gyroscopo eje X');
% xlabel('Temperatura')
% ylabel('Gyro Offset')
% subplot(312);
% plot(temp2, gyro2y, 'rx', 'MarkerSize',10);
% xlabel('Temperatura')
% ylabel('Gyro Offset')
% title('Gyroscopo eje Y');
% subplot(313);
% plot(temp2, gyro2z, 'rx', 'MarkerSize',10);shg
% xlabel('Temperatura')
% ylabel('Gyro Offset')
% title('Gyroscopo eje Z');
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
temp3 = [filtTemp; filtTemp2];
gyro3x = [gyrox;gyro2x];
gyro3y = [gyroy;gyro2y];
gyro3z = [gyroz;gyro2z];

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
X = [ones(m, 1), temp3]; % Add a column of ones to x
theta = zeros(2, 1); % initialize fitting parameters
%%
% Some gradient descent settings
iterations = 300;
alpha = 0.00001;

% figure(2);
y = gyro3x;
theta = [ 90 -4]';
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

plot(X(:,2), gyro3x,'b');
% Plot the linear fit
hold on; % keep previous plot visible
plot(X(:,2), X*theta1, 'r-')
legend('Datos de entrenamiento', 'Curva aprendida')
hold off % don't overlay any more plots on this figure

% Predict values for population sizes of 35,000 and 70,000
predict1 = [1, 35] *theta1;
fprintf('OffsetX para 35º = %f\n',...
    predict1);
%%
% Some gradient descent settings
iterations = 300;
alpha = 0.00001;
y = gyro3y;
theta = [ 0 0.5]';
% compute and display initial cost
computeCostMulti(X, y, theta)

% run gradient descent
[theta2, J_history2] = gradientDescentMulti(X, y, theta, alpha, iterations);
% print theta to screen
fprintf('Theta found by gradient descent: \n');
fprintf('Incluir en el codigo la siguiente linea \n');
fprintf('const float GyroThetaY = {%f, %f}; \n', theta2(1), theta2(2));
computeCostMulti(X, y, theta2)
plot(1:numel(J_history2), J_history2, '-b', 'LineWidth', 2);

plot(X(:,2), gyro3y,'b');
% Plot the linear fit
hold on; % keep previous plot visible
plot(X(:,2), X*theta2, 'r-')
legend('Datos de entrenamiento', 'Curva aprendida')
hold off % don't overlay any more plots on this figure
predict2 = [1, 35] *theta2;
fprintf('OffsetY para 35º = %f\n',...
    predict2);
%%
% Some gradient descent settings
iterations = 300;
alpha = 0.00001;
y = gyro3z;
theta = [ -1 -0.4]';
% compute and display initial cost
computeCostMulti(X, y, theta)

% run gradient descent
[theta3, J_history3] = gradientDescentMulti(X, y, theta, alpha, iterations);
% print theta to screen
fprintf('Theta found by gradient descent: \n');
fprintf('Incluir en el codigo la siguiente linea \n');
fprintf('const float GyroThetaZ = {%f, %f}; \n', theta3(1), theta3(2));
computeCostMulti(X, y, theta3)
plot(1:numel(J_history3), J_history3, '-b', 'LineWidth', 2);

plot(X(:,2), gyro3z,'b');
% Plot the linear fit
hold on; % keep previous plot visible
plot(X(:,2), X*theta3, 'r-')
legend('Datos de entrenamiento', 'Curva aprendida')
hold off % don't overlay any more plots on this figure
predict3 = [1, 35] *theta3;
fprintf('OffsetZ para 35º = %f\n',...
    predict3);

%%
fprintf('Incluir en el codigo la siguiente linea \n');
fprintf('const float GyroThetaX = {%f, %f}; \n', theta1(1), theta1(2));
fprintf('const float GyroThetaY = {%f, %f}; \n', theta2(1), theta2(2));
fprintf('const float GyroThetaZ = {%f, %f}; \n', theta3(1), theta3(2));