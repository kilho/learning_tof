%
%  MERL Copyright 2016 (c) 
%  Contributor : Kilho Son, Ming-Yu Liu
% 
%  Display datasets and results in the paper below
%
%  Kilho Son, Ming-Yu Liu, and Yuichi Taguchi, “Automatic Learning to Remove 
%  Multipath Distortions in Time-of-Flight Range Images”, Accepted to 
%  the IEEE international Conference on Robotics and Automation (ICRA) 2016

clear all
close all
clc

%% add lib
addpath('..\tools\')

%% set path
TRAINDATA_MASK_FOLDER                   = '..\data\train\mask\';
TRAINDATA_AMPLITUDE_FOLDER              = '..\data\train\amplitude\';
TRAINDATA_RANGE_RAW_FOLDER              = '..\data\train\range_raw\';
TRAINDATA_RANGE_CALIBRATED_FOLDER       = '..\data\train\range_calibrated\';
TRAINDATA_RANGE_REFERENCE_FOLDER        = '..\data\train\range_reference\';

TESTDATA_MASK_FOLDER                    = '..\data\test\mask\';
TESTDATA_AMPLITUDE_FOLDER               = '..\data\test\amplitude\';
TESTDATA_RANGE_RAW_FOLDER               = '..\data\test\range_raw\';
TESTDATA_RANGE_CALIBRATED_FOLDER        = '..\data\test\range_calibrated\';
TESTDATA_RANGE_REFERENCE_FOLDER         = '..\data\test\range_reference\';
TESTDATA_EDGE_REFERENCE_FOLDER          = '..\data\test\edge_reference\';

RESULT_ICRA2016_FOLDER                  = '..\results\icra2016\';

%% parameter
height                                  = 140;
width                                   = 180;

imageIdx                                = 1;

%% load data 
mask                    = LoadBinFiles([TESTDATA_MASK_FOLDER, 'mask' num2str(imageIdx, '%04d') '.bin']);
g                       = LoadBinFiles([TESTDATA_RANGE_REFERENCE_FOLDER, 'reference' num2str(imageIdx, '%04d') '.bin']);
d                       = LoadBinFiles([TESTDATA_RANGE_CALIBRATED_FOLDER, 'range_calibrated' num2str(imageIdx, '%04d') '.bin']);
rawD                    = LoadBinFiles([TESTDATA_RANGE_RAW_FOLDER, 'range_raw' num2str(imageIdx, '%04d') '.bin']);
directCNN               = LoadBinFiles([RESULT_ICRA2016_FOLDER, 'enhanced_rst' num2str(imageIdx, '%04d') '.bin']);

g                       = reshape(g,height, width);
d                       = reshape(d,height, width);
rawD                    = reshape(rawD,height, width);
directCNN               = reshape(directCNN,height, width);

%% display results
% parameter calculation for display purpose
minZ = min(g(:))-20;
temp1 = g(:) < 500;
temp2 = g(:);
maxZ = max(temp2(temp1))+20;
interval = maxZ-minZ;

figure(1)
imshow(MakeColorMaskedResults((g-minZ)/interval, mask));
title('reference')

figure(2)
subplot(2,1,1)
imshow(MakeColorMaskedResults((rawD-minZ)/interval, mask));
title('raw range')
subplot(2,1,2)
DisplayDifferenceMap(rawD(:)-g(:), mask(:), 15, height, width, 2)
title('difference map: reference - raw range')

figure(3)
subplot(2,1,1)
imshow(MakeColorMaskedResults((d-minZ)/interval, mask));
title('calibrated range')
subplot(2,1,2)
DisplayDifferenceMap(d(:)-g(:), mask(:), 15, height, width, 3)
title('difference map:  reference - calibrated range')

figure(4)
subplot(2,1,1)
imshow(MakeColorMaskedResults((directCNN-minZ)/interval, mask));
title('result on ICRA 2016')
subplot(2,1,2)
DisplayDifferenceMap(directCNN(:)-g(:), mask(:), 15, height, width, 4)
title('difference map: reference - result on ICRA 2016')







