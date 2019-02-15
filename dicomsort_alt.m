function dicomsort_alt(subjectParent)
% dicomSort is a recursive dicom sorting tool.
%   dicomsort(input) recursively sorts all dicom files in a study folder
%   regardless of directory structure or hierarchy, but preserves original
%   folders, so no PatientID is involved.
%
%   Syntax:
%   dicomsort_alt(subjectParent)
%
%   Arguments:
%   subjectParent --> Input path
%   Parent folder contiaing all subject folders
%   Type: char | string
%
%   Author: Siddhartha Dhiman
%   Email: dhiman@musc.edu
%   First created on 02/15/2019 using MATLAB 2018b
%
%   SEE ALSO DICOMSORT DIR DICOMINFO COPYFILE MOVEFILE

studyPath = subjectParent;
%% Create Subject List
subjectDir = dir(studyPath);

%   Clean up listing
rmIdx = zeros(1,length(subjectDir));
for i = 1:length(subjectDir)
    if any(startsWith(subjectDir(i).name,'.'));
        rmIdx(i) = 1;
        
    else
        %   If nothing found, don't mark for deletion
        rmIdx(i) = 0;
    end
end
subjectDir(rmIdx ~= 0) = [];

%% Sort Dicoms
parfor j = 1:length(subjectDir)
    %% Create Recirsive Listing
    studyDirDel = dir(fullfile(studyPath,subjectDir(j).name));
    studyDir = dir(fullfile(studyPath,subjectDir(j).name,'**/*'));
    fprintf('Subject %s: Found %d files\n',subjectDir(j).name,length(studyDir));
    % Clean-up Dicom Directory Listing
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
    
    %   Clean-up Deletion Listing
    rmIdx = zeros(1,length(studyDirDel));
    for i = 1:length(studyDirDel)
        %   Check for files starting with'.'
        if any(startsWith(studyDirDel(i).name,'.'));
            rmIdx(i) = 1;
            %  Check for directories
        elseif studyDirDel(i).isdir == 1
            rmIdx(i) = 0;
            
        else
            %   If nothing found, don't mark for deletion
            rmIdx(i) = 1;
        end
        
    end
    studyDirDel(rmIdx ~= 0) = [];   %   Apply deletion filter
    
    for i = 1:nFiles
        try
            tmp = dicominfo(fullfile(studyDir(i).folder,studyDir(i).name));
        catch
            continue
        end
        %   Replace all '.' in protocol names with '_'
        tmp.ProtocolName = strrep(tmp.ProtocolName,'.','_');
        %   Replace spaces
        tmp.ProtocolName = strrep(tmp.ProtocolName,' ', '_');
        
        %   Define copy/move folder
        defineFolder = fullfile(studyPath,subjectDir(j).name,...
            sprintf('%s_%d',tmp.ProtocolName,tmp.SeriesNumber));
        
        if ~exist(defineFolder,'dir')
            mkdir(defineFolder);
        end
        
        if ~contains(studyDir(i).name,'.dcm')
            newName = [studyDir(i).name '.dcm'];
        else
            newName = studyDir(i).name;
        end
        movefile(tmp.Filename,fullfile(defineFolder,newName));
    end
    
    %   Delete old folders from StudyDirDel
    for i = 1:length(studyDirDel)
        rmdir(fullfile(studyDirDel(i).folder,studyDirDel(i).name),'s');
    end
end
fprintf('done\n')
end
