%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   TrajectoryDatabase
%
%   Creates a trajectory using the trajectories in the given path.
%
%   Author -- Santhoshkumar Sunderrajan
%
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef TrajectoryDatabase < handle
    
    properties
        m_trajectoryList;
        m_objectPositionsInEachCamera;
        m_trajectoryLabels;
        m_numberOfCameras;
        m_subsampleIndices;
        m_numberOfObjectsInEachCameraList;
        m_databasePath;
        m_shouldUseCameraModel;
        m_cameraIndices;
        m_homographyMatrixList;
        m_cameraModelList;
        m_trajectoryDescriptor;
        m_homographyIndices;
        m_kde
    end

    % Constant member variables
    properties(Constant)
    end
   
    methods

        % Constructor
        function obj = TrajectoryDatabase(  numberOfCameras,...
                                            subsampleIndices,...
                                            numberOfObjectsInEachCameraList,...
                                            cameraIndices,...
                                            databasePath,...
                                            shouldUseCameraModel,...
                                            homographyIndices )

            assert( nargin == 7 );
            assert( length(cameraIndices)       == numberOfCameras );
            assert( length(subsampleIndices)    == numberOfCameras );

            %store the member variables
            obj.m_numberOfCameras                   = numberOfCameras;
            obj.m_subsampleIndices                  = subsampleIndices;
            obj.m_numberOfObjectsInEachCameraList   = numberOfObjectsInEachCameraList;
            obj.m_cameraIndices                     = cameraIndices;
            obj.m_databasePath                      = databasePath;
            obj.m_shouldUseCameraModel              = shouldUseCameraModel;
            obj.m_homographyIndices                 = homographyIndices;

            %initialize the trajactory database from the given path
            obj = obj.Initialize( );

            %display trajectories on the common ground plane
            obj.DisplayTrajectories( );
            
            %get trajectory descriptor
            obj.m_trajectoryDescriptor = obj.GetVectorizedTrajectoryDescriptor( );

            assert( ~isempty( obj.m_trajectoryDescriptor ) );

            %build the kde with the trajectory descriptor
            obj.m_kde = kde( obj.m_trajectoryDescriptor', [ 10^4 10^4 10^4 10^4 ]' );

        end%constructor

        % Initialize trajectory database with a given path
        function obj = Initialize( obj )
            
            %load the homography matrix
            if obj.m_shouldUseCameraModel
                obj.m_cameraModelList = cell( 1, obj.m_numberOfCameras );
                load( [ obj.m_databasePath '/Calibration.mat' ] );
                for i = 1 : obj.m_numberOfCameras
                   obj.m_cameraModelList{i} =  CameraModel( Calibration{obj.m_cameraIndices(i)});
                end
            else
                load( [ obj.m_databasePath '/Homography.mat' ] );
                obj.m_homographyMatrixList = Homography;
            end

            % load the object rectangles from the training set
            for cameraIndex =  1 : obj.m_numberOfCameras
                cameraName = [ 'C' num2str(obj.m_cameraIndices(cameraIndex)) ];
                numberOfObjects = obj.m_numberOfObjectsInEachCameraList(cameraIndex);
                for objectIndex = 1 : numberOfObjects
                    objRectFilePath = [ obj.m_databasePath '/' cameraName '_O' num2str(objectIndex) '/objectRect.mat' ];

                    load( objRectFilePath );
                    obj.m_objectPositionsInEachCamera{ cameraIndex, objectIndex } = objectRect;
                end
            end
        end
        
        % Display trajectories on the ground plane
        function obj = DisplayTrajectories( obj, useLabels )
            if nargin == 1
                useLabels = 0;
            end
            colors = {'r-', 'b-', 'g-', 'm-', 'y-', 'c-', 'r+', 'b+', 'g+'};
            figure;
            hold on;
             for cameraIndex =  1 : obj.m_numberOfCameras
                for objectIndex = 1 : obj.m_numberOfObjectsInEachCameraList(cameraIndex)
                    groundPlanePositionNormalized = obj.ProjectToGroundPlane( cameraIndex, objectIndex );
                    %plot the trajectory
                    if size(groundPlanePositionNormalized,1) ~= 0
                        if ~useLabels
                            plot3( groundPlanePositionNormalized(1,:), groundPlanePositionNormalized(2,:), zeros( length(groundPlanePositionNormalized'),1 )', colors{cameraIndex});
                        else
                            plot3( groundPlanePositionNormalized(1,:), groundPlanePositionNormalized(2,:), zeros( length(groundPlanePositionNormalized'),1 )', colors{obj.m_trajectoryLabels(cameraIndex,objectIndex)});
                        end
                    end
                end
             end           

            %             load exit.mat
            %             for exitIter = 1 : size( staticRegionRectangles, 1 )
            %                 rectangle( 'Position', staticRegionRectangles( exitIter, :)  ,'FaceColor', 'g', 'Curvature', [1 1] )
            %             end
            %             
            %             load obstacles.mat
            %             for obstacleIter = 1 : size( staticRegionRectangles, 1 )
            %                 rectangle( 'Position', staticRegionRectangles( obstacleIter, :)  ,'FaceColor', 'r', 'Curvature', [1 1] )
            %             end
            %             
            hold off;
        end

        % Input the static scene information such as the entry and exit points
        function obj = InputStaticSceneInformation( obj, staticSceneInformatioLabel )
            assert( nargin == 2 );
            obj.DisplayTrajectories( );
            shouldInputMore = 1;
            staticRegionRectangles = [];
            while( shouldInputMore )
                regionRectangle = getrect();
                staticRegionRectangles = [ staticRegionRectangles; regionRectangle ];
                shouldInputMore = input('Please press 1 to mark more regions , else press 0 : ');
            end

            save( staticSceneInformatioLabel, 'staticRegionRectangles' );
        end

        % Project trajectories to the ground plane
        function groundPlanePositionNormalized = ProjectToGroundPlane( obj, cameraIndex, objectIndex )
            objectRect = downsample( obj.m_objectPositionsInEachCamera{ cameraIndex, objectIndex }, obj.m_subsampleIndices(cameraIndex) );
            
            if size(objectRect,1) == 1 || size(objectRect,2) == 1
                groundPlanePositionNormalized = [];
                return;
            end
            if obj.m_shouldUseCameraModel
                groundPlanePositionNormalized = [];
                objectFootPosition = [ objectRect(:,1) +  objectRect(:,3) /2 , objectRect(:,2) +  objectRect(:,4)];
                for i = 1 : size( objectFootPosition , 1 )
                    groundPlanePositionNormalized = [ groundPlanePositionNormalized; obj.m_cameraModelList{cameraIndex}.ImageToWorld(objectFootPosition( i, : ) )' ];
                end
                
                groundPlanePositionNormalized = groundPlanePositionNormalized(:,1:2)';
            else
                objectFootPostion = [ objectRect(:,1) +  objectRect(:,3) /2 , objectRect(:,2) +  objectRect(:,4), ones( length(objectRect),1 ) ]';
                groundPlanePosition = obj.m_homographyMatrixList{obj.m_homographyIndices{cameraIndex}} * objectFootPostion;
                groundPlanePositionNormalized = [ groundPlanePosition(1,:) ./ groundPlanePosition(3,:);  groundPlanePosition(2,:) ./ groundPlanePosition(3,:) ];
            end
        end

        % Vectorize trajectories for pattern mining
        function vectorizedTrajectories = VectorizeTrajectories( obj )
            assert( obj.m_numberOfCameras >= 1 );
            assert( sum( obj.m_numberOfObjectsInEachCameraList ) >= 1 );
            vectorizedTrajectories = [];
            for cameraIndex =  1 : obj.m_numberOfCameras
                for objectIndex = 1 : obj.m_numberOfObjectsInEachCameraList(cameraIndex)
                    vectorizedTrajectories = [ vectorizedTrajectories; obj.ProjectToGroundPlane( cameraIndex, objectIndex )'];
                end
            end
        end

        % Get a trajectory from the database
        function trajectory = GetTrajectory( obj, cameraIndex, objectIndex )
            trajectory = double(obj.ProjectToGroundPlane( cameraIndex, objectIndex ))';
        end

        % Get static scene information
        function [ exitSceneStaticInformation, obstaclesStaticInformation ]  = GetStaticSceneInformation( obj, currentLocation )

            load exit_PETS.mat
            exitRegionCenters = exitGP;
            nearestNeighborIndex    = knnsearch( exitRegionCenters, currentLocation, 'k', 1 );
            exitSceneStaticInformation = exitRegionCenters( nearestNeighborIndex, : );
            obstaclesStaticInformation = [];
            
%             exitRegionCenters       = staticRegionRectangles( :, 1:2 ) + staticRegionRectangles( :, 3:4 )./2 ;
%             nearestNeighborIndex    = knnsearch( exitRegionCenters, currentLocation, 'k', 1 );
%             exitSceneStaticInformation = exitRegionCenters( nearestNeighborIndex, : );
% 
%             load obstacles.mat
%             obstaclesCenters        = staticRegionRectangles( :, 1:2 ) + staticRegionRectangles( :, 3:4 )./2 ;
%             nearestNeighborIndex    = knnsearch( exitRegionCenters, currentLocation, 'k', 1 );
%             obstaclesStaticInformation = obstaclesCenters( nearestNeighborIndex, : );
        end

        % Vectorized trajectory descriptor for KDE
        function trajectoryDescriptors = GetVectorizedTrajectoryDescriptor( obj )
            assert( obj.m_numberOfCameras >= 1 );
            assert( sum( obj.m_numberOfObjectsInEachCameraList ) >= 1 );
            trajectoryDescriptors = [];
            for cameraIndex =  1 : obj.m_numberOfCameras
                for objectIndex = 1 : obj.m_numberOfObjectsInEachCameraList(cameraIndex)
                    %returns a column vector of trajectory
                    vectorizedTrajectories = obj.ProjectToGroundPlane( cameraIndex, objectIndex )';

                    numberOfPoints = length( vectorizedTrajectories );
                    for i = 1 : numberOfPoints - 1
                        descriptor = [  vectorizedTrajectories(i,1), vectorizedTrajectories(i,2), ...
                                        vectorizedTrajectories(i+1,1), vectorizedTrajectories(i+1,2) ];
                        trajectoryDescriptors = [ trajectoryDescriptors; descriptor ];
                    end

                end
            end
        end
        
        % project the image plane position to the ground plane and 
        function p = EvaluateDensity(  obj,...
                                       prevLoc,...
                                       curLoc,...
                                       cameraIndex )
                                   
            if obj.m_shouldUseCameraModel
                gpLoc   = obj.m_cameraModelList{cameraIndex}.ImageToWorld(curLoc);
                gpLoc1   = obj.m_cameraModelList{cameraIndex}.ImageToWorld(prevLoc);
            else
                groundPlanePosition = obj.m_homographyMatrixList{obj.m_homographyIndices{cameraIndex}} * [ curLoc 1]';
                gpLoc = [ groundPlanePosition(1,:) ./ groundPlanePosition(3,:);  groundPlanePosition(2,:) ./ groundPlanePosition(3,:) ];
                
                groundPlanePosition1 = obj.m_homographyMatrixList{obj.m_homographyIndices{cameraIndex}} * [ prevLoc 1]';
                gpLoc1 = [ groundPlanePosition1(1,:) ./ groundPlanePosition1(3,:);  groundPlanePosition1(2,:) ./ groundPlanePosition1(3,:) ];
            end

            y  = [ gpLoc1(1) gpLoc1(2) gpLoc(1) gpLoc(2) ];

            p = evaluate( obj.m_kde, y' );
        end

    end%method
   
    methods(Static)
        
        % Get Current Velocity based on the trajectory history
        function currentVelocity = GetCurrentVelocity( x, trajectoryHistory )
            trajectoryHistoryLength = size( trajectoryHistory, 1 );
            previousPosition = trajectoryHistory( trajectoryHistoryLength, : );
            currentVelocity = previousPosition' - x;
        end

        % Get the network topology in the form adjacent matrix
        function networkTopology = GetNetworkTopology( isFullyConnected, numberOfCameras )
            if ~isFullyConnected                                   %1 2 3 4 5 6 
                networkTopology = [ 1 1 1 0 1 0;...%1
                                    1 1 1 1 1 0;...%2
                                    1 1 1 1 1 1;...%3
                                    0 1 1 1 1 1;...%4
                                    1 1 1 1 1 0;...%5
                                    0 0 1 1 0 1;...%6
                                  ];
            else     
                networkTopology =  ones( numberOfCameras, numberOfCameras );
            end
        end

        % Get the network hierarchy, used in hierarchical consensus
        function networkHierarchy = GetNetworkHierarchy( )
            networkHierarchy = [];
        end

    end%static methods
end