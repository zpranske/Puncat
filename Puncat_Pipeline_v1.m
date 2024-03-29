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
defaultpath = 'C:\Users\Zachary_Pranske\Desktop\pipeline_inputs';
uiwait(msgbox('Open analysis folder containing subfolders called "measure" and "summary"'))
d = dir(uigetdir('C:\Users\Zachary_Pranske\Desktop\ZP_03 pyramidal cell reanalysis 2022-10-31'));
while(~max(ismember({d(1:end).name},"measure")) || ~max(ismember({d(1:end).name},"summary")))
    error('Folder must be parent folder containing "measure" and "summary" folders')
    d = dir(uigetdir(defaultpath));
end; 

% %DELETE THIS LINE LATER
%  d = dir('C:\Users\Zachary_Pranske\Desktop\pipeline_inputs');

 disp('Found measure and summary folders...')

 d_measure = d(ismember({d(1:end).name},"measure"));
 d_summary = d(ismember({d(1:end).name},"summary"));
 measure_files = dir([d_measure.folder '\' d_measure.name]);
 idx_m=[]; idx_p=[];
 for i=1:length(measure_files)
    idx_m(i) = contains(measure_files(i).name,"Measure");
    idx_p(i) = contains(measure_files(i).name,"ROIs");
 end
 
 puncta_files = measure_files(find(idx_p==1));
 measure_files = measure_files(find(idx_m==1));
 summary_files = dir([d_summary.folder '\' d_summary.name]);

 M = processMeasures(measure_files);
 M_cells = M(M.Shape_Type == "cell",:);
 M_bands = M(M.Shape_Type == "band",:);
 S = processSummary(summary_files);
 [P_all, P] = processPuncta(puncta_files);
 disp('File processing done!')
 warning('off','all') 
 
 T = [M_cells, S(ismember(S.Unique_Z_ID_S,M_cells.Unique_Z_ID),6:end), P(ismember(P.Unique_Z_ID_P,M_cells.Unique_Z_ID),:)];
 
 uiwait(msgbox('Upload decoding file: Should be an Excel spreadsheet or csv containing columns called "File#" and "Condition".','Upload decoding file'))
 d_coding = uigetfile('*.*','Select file',defaultpath);
 D = readtable([d(1).folder,'\',d_coding]);
 
 if ~(D.Properties.VariableNames(1:2) == [{'File_'} {'Condition'}])
     D.Properties.VariableNames(1) = {'File_'};
     if ~(D.Properties.VariableNames(1:2) == [{'File_'} {'Condition'}])
         error('Unable to match file #s. Check decoding file headers.')
     end
 end         
 
 %Assign cells to their treatment condition and region based on codebreaker
 %file    
 disp('Assigning treatment conditions to coded filenames...')
 end_idx = width(T);
 for i=1:height(D)
     T(T.("CodedFile#")==(D.File_(i)),end_idx+1) = table(string(D.Condition(i)));
     T(T.("CodedFile#")==(D.File_(i)),end_idx+2) = table(string(D.Region(i)));
     T(T.("CodedFile#")==(D.File_(i)),end_idx+3) = table(string(D.Animal(i)));
     T(T.("CodedFile#")==(D.File_(i)),end_idx+4) = table(string(D.Day(i)));

 end
 
 T = renamevars(T,T(:,end_idx+1).Properties.VariableNames{1},'Condition');
 T = renamevars(T,T(:,end_idx+2).Properties.VariableNames{1},'Region');
 T = renamevars(T,T(:,end_idx+3).Properties.VariableNames{1},'Animal');
 T = renamevars(T,T(:,end_idx+4).Properties.VariableNames{1},'Day');
 T = [T(:,1:7) T(:,end-1:end) T(:,8:end-2)];
 
 disp('Checking file for incomplete data...')
 if(max(ismissing(T.Condition))>0 || min(strlength(T.Condition))== 0 || max(ismissing(T.Region))>0 || min(strlength(T.Region))== 0)
    error('Check decoding file: some coded file numbers could not be assigned a condition or region.');
 end
 disp('No missing files found! Dataset ready for analysis.')
 
 % Add in additional calculations
 T(:,end+1) = table(T.Count./T.Perim_S); T = renamevars(T,T(:,end).Properties.VariableNames{1},'NormCount');

   
%% GRAPHING

%Pass in the table T, a string corresponding to the table column to
%   analyze, and a string corresponding to the column containing the subgroup
%   identifier (e.g. Condition or Region). Can optionally include a string
%   containing the name of the treatment group to normalize to.
%   Example call: b = plotVariable(T, "NormCount", "Condition", "GFP");

%Graph params can be changed by accessing the graph by its handle b or 
%   accessing the axis by the handle b.Parent
%   Example call: b4.Parent.Title.String = 'Mean puncta intensity';

figure(1) = subplot(2,2,1); b = plotVariable(T, "NormCount", "Condition");
subplot(2,2,2); b2 = plotVariable(T, "AverageSize", "Condition");
subplot(2,2,3); b3 = plotVariable(T, "PercentArea", "Condition");
subplot(2,2,4); b4 = plotVariable(T, "mean_Mean_P", "Condition");

b4.Parent.Title.String = 'Mean puncta intensity';
b4.Parent.YLabel.String = 'Mean puncta intensity';

%% STATS

runstats2(T, "NormCount", "Condition", ["GFP" "Sema4D"]);
runstats2(T, "AverageSize", "Condition", ["GFP" "Sema4D"]);
runstats2(T, "PercentArea", "Condition", ["GFP" "Sema4D"]);
runstats2(T, "mean_Mean_P", "Condition", ["GFP" "Sema4D"]);


 
