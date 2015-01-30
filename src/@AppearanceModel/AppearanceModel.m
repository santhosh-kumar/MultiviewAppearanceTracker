%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Appearance Model learns and updates the appearance model.
%
%   Author -- Santhoshkumar Sunderrajan
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef AppearanceModel
      
   methods(Static)
       % learn appearance for objects both local and global
       cameraNetwork = LearnObjectsAppearancesAcrossDifferentViews( cameraNetwork, frameIndex );
       
       % sample from generative subspaces by taking view point shift into
       % account
       [ trainingFeatures, trainingLabels] = SampleFromGenerativeSubspace( trainingFeatures,...
                                                                           traningLabels,...
                                                                           otherViewTrainingSamples,...
                                                                           drOptions);
    
   end% methods
   
       
   methods( Static, Access = private )
       % learn local appearance model
       cameraNetwork = LearnLocalAppearanceModel( cameraNetwork,...
                                                  frameIndex );

       % learn global appearance model
       cameraNetwork = LearnGlobalAppearanceModel( cameraNetwork,...
                                                   frameIndex );
       
       % collect training samples from other views
       otherViewTrainingSamples = CollectTrainingSamples( cameraNetwork,...
                                                          cameraIndex,...
                                                          targetIndex );
   end
end%classdef