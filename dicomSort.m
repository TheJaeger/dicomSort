function dicomSort(studyPath,output)
% dicomSort Recursive dicom solrting tool.
%   dicomSort(input) sorts all dicom files for each subject in a study
%   folder.
%
%   dicomSort(input,output) sorts all dicom files in a subject folder and
%   outputs them into a predefined folder.
%
%   Author: Siddhartha Dhiman
%   Email: dhiman@musc.edu
%   First created on 01/28/2019 using MATLAB 2018b
%   Last modified on 01/28/2019 using MATLAB 2018b
%
%   SEE ALSO ...

%% Tunable unction Variables
studyDir = dir(fullfile(studyPath,'**/*')); %   Recursive directory listing
rmPattern = {'.','.DS_Store'};   %   Remove files beginning with

%% Clean-up Directory Listing
rmIdx = zeros(1,length(studyDir));
for i = 1:length(studyDir)
    %  Check for directories
    if studyDir(i).isdir == 1
        rmIdx(i) = 1;
        
        %   Check for files starting with'.'
    elseif any(startsWith(studyDir(i).name,'.'));
        rmIdx(i) = 1;
        
    else
        %   If nothing found, don't mark for deletion
        rmIdx(i) = 0;
    end
end
studyDir(rmIdx ~= 0) = [];   %   Apply deletion filter
nFiles = length(studyDir);
fprintf('Found %d dicom files\n',nFiles);

%% Sort Dicom Files
%   Run in parent parfor for speed
parfor i = 1:nFiles
    tmp = dicominfo(fullfile(studyDir(i).folder,studyDir(i).name));
    [~,tmpName,~] = fileparts(tmp.Filename);
        sortStatus = fprintf('%d/%d: sorting %s',j,length(studyDir),...
            tmp.SeriesDescription);
        
        if ~exist(fullfile(outPath,tmp.PatientID,tmp.ProtocolName),'dir')
            mkdir(fullfile(outPath,tmp.PatientID,tmp.ProtocolName));
        else
            ;
        end
        if ~contains(tmpName,'.dcm')
            newName = [tmpName '.dcm'];
        else
            newName = tmpName;
        end
        copyfile(tmp.Filename,fullfile(outPath,tmp.PatientID,...
            tmp.ProtocolName,newName));
        
        fprintf('Sorting %s: %d/%d',tmp.PatientID,i,nFiles);
end
end
    
