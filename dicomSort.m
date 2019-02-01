function dicomsort(studyPath,varargin)
% dicomSort is a recursive dicom sorting tool.
%   dicomsort(input) recursive sorts all dicom files in a study folder
%   regardless of directory structure or hierarchy.
%
%   Syntax:
%   dicomsort(input)
%   dicomsort(input,output)
%   dicomsort(__,Name,Value)
%
%   Description:
%   dicomSort(input) sorts all dicom files in a study regardless of folder
%   hierarchy
%
%   dicomsort(input,'output',dir) sorts all dicom files in a subject folder
%   and outputs them to a specified folder
%
%   dicomsort(__,Name,Value) uses additional name-value pairs to customize
%   sorting
%
%   Name-Value Pair Arguments:
%   'output' --> output path
%       Define an output directory for sorting
%       Type: char | string
%
%   'preserve' --> true (default) | false
%       Specifies whether to preserve original files or directories.
%       Setting to true deletes all original files
%       Type: logical
%
%   'compression' --> type of compression
%       Specify if compression applied on old files. Recommended if
%       preserve is set to 'false' to prevent loss of data
%       Options: 'none' (default), 'zip', 'tar', 'gzip'
%       Type: char | string
%
%   'prefix' --> prefix before subject
%       String to attach prior to subject name during creation of subject
%       folder
%       Type: char | string
%
%   'suffix' --> suffix after subject
%       String to attach after subject name during creation of subject
%       folder
%
%   Example:
%   dicomsort('~/example_study/data');
%       Sort all dicom files in ~/example_study/data
%
%   dicomsort('~/example_study/data','output','~/example_study/sorted');
%       Sort all dicom files in ~/example_study/data and output sorted data
%       into ~/example_study/sorted
%
%   dicomsort(~/example_study/data,'output','~/example_study/sorted',...
%       'preserve',false','compression','tar');
%       Sort all dicom files in ~/example_study/data and output sorted data
%       into ~/example_study/sorted, whilst tar compressing original data
%       directory hierarchy and removing original files
%
%   Author: Siddhartha Dhiman
%   Email: dhiman@musc.edu
%   First created on 01/28/2019 using MATLAB 2018b
%   Last modified on 01/31/2019 using MATLAB 2018b
%
%   SEE ALSO DIR DICOMINFO COPYFILE MOVEFILE

warning off;
%% Parse Inputs
defaultComp = 'none';
defaultPreserve = true;
expectedLog = {'yes','no'};
expectedComp = {'none','zip','tar','gzip'};
p = inputParser;
addRequired(p,'studyPath',@isstr);
addOptional(p,'output',@isstr);
addParameter(p,'preserve',defaultPreserve,@islogical);
addParameter(p,'compression',defaultComp,...
    @(s) any(validatestring(s,expectedComp)));
addOptional(p,'prefix',@isstring);
addOptional(p,'suffix',@isstring);

parse(p,studyPath,varargin{:});

%% Perform Tests
%   Check whether input path exists
if ~isfolder(studyPath)
    error('Input path not found, ensure it exists');
elseif isstr(p.Results.output)
    outPath = p.Results.output;
    if isdir(p.Results.output)
        ;
    else
        mkdir(p.Results.output)
    end
elseif ~isstr(p.Results.output)
    outPath = studyPath;
end

%% Throw Errors during Impossible Cases and Summarize Results
if ~isstr(p.Results.output) && p.Results.preserve == 0
    error(sprintf('Cannot preserve original folder structure when "output" is undefined.\nPlease define an "output" directory or disable "preserve"'));
elseif ~isstr(p.Results.output) && ~strcmp(p.Results.compression,'none')
    error('Study directory cannot be preserved after altering it, define an output directory to enable compression.');
else
    ;
end

%% Tunable Function Variables
studyDir = vertcat(dir(fullfile(studyPath,'**/*')),...
    dir(fullfile(studyPath,'**/*.dcm'))); %   Recursive directory listing
studyDirFolders = dir(studyPath);
rmPattern = {'.','.DS_Store'};   %   Remove files beginning with

%% Clean up Main Study Dir Listing
rmIdx = zeros(1,length(studyDirFolders));
for i = 1:length(studyDirFolders)
    if any(startsWith(studyDirFolders(i).name,'.'));
        rmIdx(i) = 1;
        
    else
        %   If nothing found, don't mark for deletion
        rmIdx(i) = 0;
    end
end
studyDirFolders(rmIdx ~= 0) = [];
%   Create folder listing for compression
for i = 1:length(studyDirFolders)
    compPaths{i} = fullfile(studyDirFolders(i).folder,...
        studyDirFolders(i).name);
end
nComp = length(compPaths);

%% Clean-up Dicom Directory Listing
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

%% Initialize Parallel Data Queue
% Initialized the queue
q = parallel.pool.DataQueue;
% After receiving new data, update_progress() will be called
afterEach(q, @parProgress);
parProg = 0;

%% Sort Dicom Files
%   Run in parent parfor for speed
preSorted = cell(nFiles,1);
j = 1;
parfor i = 1:nFiles
    %   Test whether file is readable by dicom. If not, move on to next
    %   file instead of throwing an error
    try
        tmp = dicominfo(fullfile(studyDir(i).folder,studyDir(i).name));
    catch
        continue
    end
    
    %   Check whether file contains a '.dcm' extension. If it does, make no
    %   changes. If not, append '.dcm' at the end
    if ~contains(studyDir(i).name,'.dcm')
        newName = [studyDir(i).name '.dcm'];
    else
        newName = studyDir(i).name;
    end
    
    %   Check for prefix flag and append if it does. Skip otherwise
    if isstr(p.Results.prefix)
        tmp.PatientID = [p.Results.prefix tmp.PatientID];
    else
        tmp.PatientID = tmp.PatientID;
    end
    
    %   Check for suffix flag and append if it does. Skip otherwise
    if isstr(p.Results.suffix)
        tmp.PatientID = [tmp.PatientID p.Results.suffix];
    else
        tmp.PatientID = tmp.PatientID;
    end
    
    %   Check if a directory 'PatientID/Protocol' exists. If it does, do
    %   nothing. Otherwise, make directry
    if ~exist(fullfile(outPath,tmp.PatientID,tmp.ProtocolName),'dir')
        mkdir(fullfile(outPath,tmp.PatientID,tmp.ProtocolName));
    else
        ;
    end
    
    %   Check whether current file is already sorted. If it is, skip that
    %   file and take note of patient ID
    if contains(tmp.Filename,...
            fullfile(outPath,tmp.PatientID,tmp.ProtocolName))
        preSorted{i} = tmp.PatientID;
        continue;
    else
        ;
    end
    
    %   Initiate file copy if another output path present
    if isstr(p.Results.output)
        copyfile(tmp.Filename,fullfile(outPath,tmp.PatientID,...
            tmp.ProtocolName,newName));
        %   Move them otherwise
    else
        movefile(tmp.Filename,fullfile(outPath,tmp.PatientID,...
            tmp.ProtocolName,newName));
    end
    
    %   Update parallel process progress
    send(q,i);
end
fprintf('\n');

%   Check compression flag and act accordingly
if strcmp(p.Results.compression,'none');
    fprintf('Skipping compression\n');
elseif strcmp(p.Results.compression,'zip')
    fprintf('Zipping files...');
    zip(fullfile(studyPath,'study_original_files.zip'),compPaths);
    fprintf('saved as %s',fullfile(studyPath,'study_original_files.zip\n'));
elseif strcmp(p.Results.compression,'tar')
    fprintf('Tarring files...');
    tar(fullfile(studyPath,'study_original_files.tar'),compPaths);
    fprintf('saved as %s',fullfile(studyPath,'study_original_files.tar\n'));
elseif strcmp(p.Results.compression,'gzip')
    fprintf('Gunziping files...');
    gzip(compPaths,studyPath);
    fprintf('saved as %s',fullfile(studyPath,'gzip','study_original_files.gz\n'));
else
    fprintf('Not sure what your compression options are');
end

%   From the list of PatientIDs that were already sorted, create a unique
%   list of IDs to that acts as a do-not-delete list. Check whether output
%   diretory has been not been defined. If both checks succeed, delete
%   files not on the DND.
if exist('preSorted','var') && ~isstr(p.Results.output)
    preSorted = unique(preSorted(~cellfun('isempty',preSorted)));
    %   Remove old file and structure if the output directory was unspecified
    fprintf('Not preserving files, removing folders:\n');
    for i = 1:nComp
        %   Check if file to be deleted is a member of do-no-delete list.
        %   If it's not, delete.
        if ~ismember(studyDirFolders(i).name,preSorted)
            fprintf('%d/%d:    %s\n',i,nComp,...
                fullfile(studyDirFolders(i).folder,studyDirFolders(i).name));
            rmdir(fullfile(studyDirFolders(i).folder,studyDirFolders(i).name),'s');
        else
            ;
        end
    end
    %   Then check if an output directory is undefined and no DND list
    %   exists. If checks pass, delete all old files
elseif ~exist('preSorted','var') && ~isstr(p.Results.output)
    for i = 1:nComp
        fprintf('%d/%d:    %s\n',i,nComp,...
            fullfile(studyDirFolders(i).folder,studyDirFolders(i).name));
        rmdir(fullfile(studyDirFolders(i).folder,studyDirFolders(i).name),'s');
    end
else
    fprintf('Preserving orignal files\n');
end

    function parProgress()
        %   parProgress is a parallel pool progress tracker
        %
        %   Syntax:
        %   parProgress() placed at the end of a parfor loop will print it's
        %   progress
        n_completed = n_completed + 1;
        parPrnthg = n_completed/nFiles;
        parStatus = fprintf('Progress: %.1f', perPrnthg);
        fprintf(repmat('/b',1,length(num2str(parPrnthg))));
    end
end