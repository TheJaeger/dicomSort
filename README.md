dicomSort
dicomSort Recursive dicom sorting tool.
  dicomsort(input) recursive sorts all dicom files in a study folder
  regardless of directory structure or hierarchy.

  Syntax:
  dicomsort(input)
  dicomsort(input,output)
  dicomsort(__,Name,Value)

  Description:
  dicomSort(input) sorts all dicom files in a study regardless of folder
  hierarchy

  dicomsort(input,'output',dir) sorts all dicom files in a subject folder
  and outputs them to a specified folder

  dicomsort(__,Name,Value) uses additional name-value pairs to customize
  sorting

  Name-Value Pair Arguments:
  'output' --> output path
      Define an output directory for sorting
      Type: char | string

  'preserve' --> true (default) | false
      Specifies whether to preserve original files or directories.
      Setting to true deletes all original files
      Type: logical

  'compression' --> type of compression
      Specify if compression applied on old files. Recommended if
      preserve is set to 'false' to prevent loss of data
      Options: 'none' (default), 'zip', 'tar', 'gzip'
      Type: char | string

  'prefix' --> prefix before subject
      String to attach prior to subject name during creation of subject
      folder
      Type: char | string

  'suffix' --> suffix after subject
      String to attach after subject name during creation of subject
      folder

  Example:
  dicomsort('~/example_study/data');
      Sort all dicom files in ~/example_study/data

  dicomsort('~/example_study/data','output','~/example_study/sorted');
      Sort all dicom files in ~/example_study/data and output sorted data
      into ~/example_study/sorted

  dicomsort(~/example_study/data,'output','~/example_study/sorted',...
      'preserve',false','compression','tar');
      Sort all dicom files in ~/example_study/data and output sorted data
      into ~/example_study/sorted, whilst tar compressing original data
      directory hierarchy and removing original files
