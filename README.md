# dicomsort
This is a MATLAB function to sort all dicom files in a study directory regardless of folder structure or hierarchy. This flexible script is for sorting your dicoms faster than Trump's approval rating dropped, faster than a pro Genji and faster than Yngwie Malmsteen, . It neither cares about all the other junk you have in your study directory, nor does it care about your organizational skills. It just goes in, sorts fast, so you can breathe easy.

Tired of arranging your subject folder into the right format? BAM, dicomSort that!

Tired of Horos or OsiriX messing up your study folder? BAM, dicomSort that!

Some PI lacks organizational skills? BAM, dicomSort that!
MRI scanner gone rogue? BAM, dicomSort that!

Your PC is a toaster? BAM, dicomSort that!

Your chair is uncomfortable? BAM, dicomSort that!

Just broke up? BAM, dicomSort that! I dicomSort all day!

Sort your dicom life now, the dicomSort way. 

  ### Syntax:
  dicomsort(input)
  dicomsort(input,output)
  dicomsort(__,Name,Value)

  ### Description:
  dicomSort(input) sorts all dicom files in a study regardless of folder
  hierarchy

  dicomsort(input,'output',dir) sorts all dicom files in a subject folder
  and outputs them to a specified folder

  dicomsort(__,Name,Value) uses additional name-value pairs to customize
  sorting

  ### Name-Value Pair Arguments:
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

  ### Example:
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
