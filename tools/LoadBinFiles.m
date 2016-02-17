%
% MERL Copyright 2014 (c) 
% Contributor : Kilho Son (intern), Ming-Yu Liu
% 
% load all the results(binary files)
function data = LoadBinFiles(fileName)

FID = fopen(fileName, 'r');
data = fread(FID, 'float32');
fclose(FID);