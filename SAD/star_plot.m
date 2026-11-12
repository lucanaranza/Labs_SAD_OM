clc
clear
close all

map = load('star_map.mat');
map = map.star_map;
stars = [map.p_x, map.p_y, map.p_z];

figure()
plot3(stars(:, 1), stars(:, 2), stars(:, 3), '.')
axis equal