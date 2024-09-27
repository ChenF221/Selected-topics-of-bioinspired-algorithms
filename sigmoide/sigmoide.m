% FUNCION DE TRANSFORMACION SIGMOIDE
clc
close all
clear all
warning off 

img = imread('kodim23.png');

% Convertir la imagen a tipo double y normalizar al rango [0, 1]
img_double = im2double(img);

alpha = input('Ingrese el valor de alpha entre el rango de (0, 10]: '); % Factor de contraste (0, 10]
delta = input('Ingrese el valor de delta entre el rango de [0, 1]: '); % Valor de equilibrio [0, 1]

% Aplicar la función sigmoide a cada plano de color
img_sigmoide = 1 ./ (1 + exp(-alpha * (img_double - delta)));

% Reescalar la imagen mejorada al rango [0, 1]
img_mejorada = mat2gray(img_sigmoide);


figure;
subplot(1, 2, 1);
imshow(img);
title('Imagen Original');

subplot(1, 2, 2);
imshow(img_mejorada);
title('Imagen Transformada (Sigmoide)');

