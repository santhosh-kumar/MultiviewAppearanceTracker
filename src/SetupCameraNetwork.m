%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This function sets up the camera network
%
%   Input --
%       void
%   Output -- 
%       @cameraNetwork              - Structure containing the camera networks
%       @frameRangeForAnalysis      - frame range
%
%   Author -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ cameraNetwork,...
           frameRangeForAnalysis ] = SetupCameraNetwork( )

    fprintf( '\nSetting Up the Libraries...' );
    fprintf( '\n ############################################################' );
    
    if ispc
        baseLocation = '..\..';
    else
        baseLocation = '../..';
    end
    
    currentDirectory  = pwd;
    
    addpath( '../lib/');
    
    addpath( '../lib/UnsupervisedDA_Grassmann/' );
    
    %set up the necessary libraries
    addpath(fullfile('../lib/','lib_boosting'));
    addpath(fullfile('../lib/','PHOG'));
    
    %set up graph visualizer
    addpath(fullfile('../lib/','GraphVizWrapper'));
    
    % setup Dollar's toolbox
    addpath(fullfile('../lib/','lib_dollar', 'images'));
    addpath(fullfile('../lib/','lib_dollar', 'classify'));
    addpath(fullfile('../lib/','lib_dollar', 'filters'));
    addpath(fullfile('../lib/','lib_dollar', 'matlab'));
    
    % set up KD-tree library
    addpath(fullfile('../lib/','kdtree'));
    
    %set up 2d geometry toolbox
    cd(fullfile('../lib/','geom2d', 'libGeom2d'));
    setupGeom2d;
    
    cd(currentDirectory);

    fprintf('\n ############################################################');
    fprintf('Completed setting up the libraries... \n');
    
    fprintf('Setting up the camera network... \n');
    
    % include constant file
    Constants();
     
    numberOfCameras             = 2;
    numberOfObjects             = 2;
    frameRangeForAnalysis       = [ 1 50 ];  %[ startFrame, endFrame ];
    cameraIndices               = [ 2; 4;];  % Helps to select the camera required for analysis
    scenarioPath                = '../data/UCSB/Scenario 1';

    % Network Structure
    networkStructure.numberOfCamera           = numberOfCameras;
    networkStructure.trackWindow              = 1;
    networkStructure.boostWindow              = 2;
    networkStructure.interactWindow           = 3;
    networkStructure.spRows                   = numberOfCameras + 1;
    networkStructure.adjacencyMatrix          = TrajectoryDatabase.GetNetworkTopology( 1, numberOfCameras );
    networkStructure.networkHierarchy         = TrajectoryDatabase.GetNetworkHierarchy( );
    networkStructure.spCols                   = 1;
    networkStructure.clock                    = 1;

    % Create Objects for each camera with their respective data and camera attributes
    cameraNetwork = CameraNetwork( numberOfCameras,...
                                   numberOfObjects,...
                                   cameraIndices,...
                                   fullfile(scenarioPath, 'InputImages/'),...
                                   fullfile(scenarioPath, 'Homography.mat'),...
                                   '',...
                                   frameRangeForAnalysis,...
                                   networkStructure,...
                                   SHOULD_USE_INIT_MAT );
                              
   fprintf('Camera Network Setup Complete... \n');
   
end%function
