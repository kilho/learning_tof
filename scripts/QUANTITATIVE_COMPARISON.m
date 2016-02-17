%
%  MERL Copyright 2016 (c) 
%  Contributor : Kilho Son, Ming-Yu Liu
% 
%  Evaluate results quantitatively presented
%
%  Refer to the paper
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

%% parameters
height                                  = 140;
width                                   = 180;
nPixels                                 = height*width;

nTrainingFiles                          = 540;
nTestFiles                              = 360;

se = ones(2);
marginThreshold                         = 1:1:10;


%% start evaluation
rawRangePDF                             = zeros(length(marginThreshold),1);
rangePDF                                = zeros(length(marginThreshold),1);
icraResultPDF                           = zeros(length(marginThreshold),1);

rawRangeBoundaryPDF                     = zeros(length(marginThreshold),1);
rangeBoundaryPDF                        = zeros(length(marginThreshold),1);
icraResultBoundaryPDF                   = zeros(length(marginThreshold),1);

totalNumPts                             = 0;
totalNumPtsOnBoundry                    = 0;
for i = 1:nTestFiles
    disp(['testing test image ' num2str(i)]) 
    % load data
    mask                    = LoadBinFiles([TESTDATA_MASK_FOLDER, 'mask' num2str(i, '%04d') '.bin']);
    g                       = LoadBinFiles([TESTDATA_RANGE_REFERENCE_FOLDER, 'reference' num2str(i, '%04d') '.bin']);
    d                       = LoadBinFiles([TESTDATA_RANGE_CALIBRATED_FOLDER, 'range_calibrated' num2str(i, '%04d') '.bin']);
    rawD                    = LoadBinFiles([TESTDATA_RANGE_RAW_FOLDER, 'range_raw' num2str(i, '%04d') '.bin']);
    directCNN               = LoadBinFiles([RESULT_ICRA2016_FOLDER, 'enhanced_rst' num2str(i, '%04d') '.bin']);
    edgeGt                  = LoadBinFiles([TESTDATA_EDGE_REFERENCE_FOLDER, 'rst' num2str(i, '%04d') '.bin']);
    
    % load mask
    mask                    = reshape(mask, height, width);
    edgeGt                  = reshape(edgeGt, height, width);
    regionAroundEdge        = imdilate(edgeGt, se);
    edgeMask                = mask.*regionAroundEdge;
    edgeMask                = logical(edgeMask(:));
    mask                    = logical(mask(:));
    
    % compare the results with reference
    rawD                    = abs(rawD-g);
    d                       = abs(d-g);
    directCNN               = abs(directCNN(:)-g);
    
    totalNumPts             = totalNumPts + sum(mask);
    totalNumPtsOnBoundry    = totalNumPtsOnBoundry + sum(edgeMask(:));
    
    % evaluate for each threshold
    for j = 1:length(marginThreshold)
        if j == 1
            mint            = 0;
            maxt            = marginThreshold(1);
        else
            mint            = marginThreshold(j-1);
            maxt            = marginThreshold(j);
        end
        
        rawRangePDF(j)              = rawRangePDF(j) + sum((rawD<maxt) & (rawD>=mint)&mask);
        rangePDF(j)                 = rangePDF(j) + sum((d<maxt) & (d>=mint)&mask);
        icraResultPDF(j)            = icraResultPDF(j) + sum((directCNN<maxt) & (directCNN>=mint)&mask);
        
        rawRangeBoundaryPDF(j)      = rawRangeBoundaryPDF(j) + sum((rawD<maxt) & (rawD>=mint)& edgeMask);
        rangeBoundaryPDF(j)         = rangeBoundaryPDF(j) + sum((d<maxt) & (d>=mint)&edgeMask);
        icraResultBoundaryPDF(j)    = icraResultBoundaryPDF(j) + sum((directCNN<maxt) & (directCNN>=mint)&edgeMask);
    end
    
end

% pdf to cdf
rawRangeCDF                         = cumsum(rawRangePDF)/totalNumPts;
rangeCDF                            = cumsum(rangePDF)/totalNumPts;
icraResultCDF                       = cumsum(icraResultPDF)/totalNumPts;

rawRangeBoundaryCDF                 = cumsum(rawRangeBoundaryPDF)/totalNumPtsOnBoundry;
rangeBoundaryCDF                    = cumsum(rangeBoundaryPDF)/totalNumPtsOnBoundry;
icraResultBoundaryCDF               = cumsum(icraResultBoundaryPDF)/totalNumPtsOnBoundry;

% draw figure
figure(1)
plot(icraResultCDF, '-rs', 'LineWidth', 1.5, 'MarkerEdgeColor','r',...
                'MarkerFaceColor',[1 1 1],...
                'MarkerSize',4)
hold on
plot(rangeCDF, ':k', 'LineWidth', 1.5,'MarkerEdgeColor','k',...
                'MarkerFaceColor',[1 1 1],...
                'MarkerSize',5);
plot(rawRangeCDF,'--k', 'LineWidth', 1.5,'MarkerEdgeColor','k',...
                'MarkerFaceColor',[1 1 1],...
                'MarkerSize',5);
hold off
grid on
legend('Proposed', 'Calibrated', 'Raw ToF range')
xlabel('Threshold (mm)');
ylabel('Percentage of correct range values');
title('Smooth and boundary regions')


figure(2)
plot(icraResultBoundaryCDF, '-rs', 'LineWidth', 1.5, 'MarkerEdgeColor','r',...
                'MarkerFaceColor',[1 1 1],...
                'MarkerSize',4)
hold on
plot(rangeBoundaryCDF, ':k', 'LineWidth', 1.5,'MarkerEdgeColor','k',...
                'MarkerFaceColor',[1 1 1],...
                'MarkerSize',5);
plot(rawRangeBoundaryCDF,'--k', 'LineWidth', 1.5,'MarkerEdgeColor','k',...
                'MarkerFaceColor',[1 1 1],...
                'MarkerSize',5);
hold off
grid on
legend('Proposed', 'Calibrated', 'Raw ToF range')
xlabel('Threshold (mm)');
ylabel('Percentage of correct range values');
title('Boundary regions')
