%%%%%% PIPECAT TM %%%%%%
% Zachary Pranske
% Paradis Lab
% Rev. 10/12/2022  

%% Description
% This macro takes as input the automatically generated "Measure" and
% "Summary" files generated by Puncat (originally designed to work with
% Puncat v2.4) and processes them for analysis, combines them into a single
% dataset, and runs basic summary statistics. Further analysis will depend
% on the project type.

%% Combine files
uiwait(msgbox('Open analysis folder containing subfolders called "measure" and "summary"'))
d = dir(uigetdir('C:\Users\Zachary_Pranske\Desktop\pipeline_inputs'));
while(~max(ismember({d(1:end).name},"measure")) || ~max(ismember({d(1:end).name},"summary")))
    error('Folder must be parent folder containing "measure" and "summary" folders')
    d = dir(uigetdir('C:\Users\Zachary_Pranske\Desktop\pipeline_inputs'));
end; 

% %DELETE THIS LINE LATER
%  d = dir('C:\Users\Zachary_Pranske\Desktop\pipeline_inputs');

 disp('Found measure and summary folders...')

 d_measure = d(ismember({d(1:end).name},"measure"));
 d_summary = d(ismember({d(1:end).name},"summary"));
 measure_files = dir([d_measure.folder '\' d_measure.name]);
 summary_files = dir([d_summary.folder '\' d_summary.name]);

 M = processMeasures(measure_files); 
 M_cells = M(M.Shape_Type == "cell",:);
 S = processSummary(summary_files);
 disp('File processing done!')
 warning('off','all') 

 T = [M_cells, S(ismember(S.Unique_Z_ID_S,M_cells.Unique_Z_ID),6:end)];
 
 uiwait(msgbox('Upload decoding file: Should be an Excel spreadsheet or csv containing columns called "File#", "Condition", and "Region"','Upload decoding file'))
 d_coding = uigetfile('*.*','Select file','C:\Users\Zachary_Pranske\Desktop\pipeline_inputs');
 D = readtable([d(1).folder,'\',d_coding]);
 
 if ~(D.Properties.VariableNames == [{'File_'} {'Condition'} {'Region'}])
     D.Properties.VariableNames(1) = {'File_'};
     if ~(D.Properties.VariableNames == [{'File_'} {'Condition'} {'Region'}])
         error('Unable to match file #s. Check decoding file headers.')
     end
 end
     
         
 
 %Assign cells to their treatment condition and region based on codebreaker
 %file    
 disp('Assigning treatment conditions to coded filenames...')

 for i=1:height(D)
     T(T.("CodedFile#")==(D.File_(i)),39) = table(string(D.Condition(i)));
     T(T.("CodedFile#")==(D.File_(i)),40) = table(string(D.Region(i)));
 end
 
 T = renamevars(T,'Var39','Condition');
 T = renamevars(T,'Var40','Region');
 T = [T(:,1:7) T(:,end-1:end) T(:,8:end-2)];
 
 disp('Checking file for incomplete data...')
 if(max(ismissing(T.Condition))>0 || max(ismissing(T.Region))>0)
     error('Check decoding file: some file numbers are missing from spreadsheet.')
 end
 disp('No missing files found! Dataset ready for analysis.')
   
%% GRAPHING

%Pass in the table T, a string corresponding to the table column to
%   analyze, and a string corresponding to the column containing the subgroup
%   identifier (e.g. Condition or Region)

%You can also optionally pass in strings for xlabel, ylabel, and title, but
%   they have to be in that order. Other params can be changed by accessing 
%   the graph by its handle b or accessing the axis by the handle b.Parent

b = plotVariable(T, "TotalArea", "Region");
