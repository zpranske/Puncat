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
% d = dir(uigetdir('C:\Users\Zachary_Pranske\Desktop\pipeline_inputs'));
% while(~max(ismember({d(1:end).name},"measure")) || ~max(ismember({d(1:end).name},"summary")))
%     disp('ERROR: Folder must be parent folder containing "measure" and "summary" folders')
%     d = dir(uigetdir('C:\Users\Zachary_Pranske\Desktop\pipeline_inputs'));
% end; 

%DELETE THIS LINE LATER
d = dir('C:\Users\Zachary_Pranske\Desktop\pipeline_inputs');

disp('Found measure and summary folders...')

 d_measure = d(ismember({d(1:end).name},"measure"));
 d_summary = d(ismember({d(1:end).name},"summary"));
 measure_files = dir([d_measure.folder '\' d_measure.name]);
 summary_files = dir([d_summary.folder '\' d_summary.name]);
 
%% Extract data and organize measure files
 M = [];
 for i = 3:length(measure_files)
    temp_M = readtable([measure_files(i).folder '\' measure_files(i).name]);    
    temp_M = renamevars(temp_M,'Var1','Cell#');
    temp_M = [table(string(repmat(measure_files(i).name,height(temp_M),1))) temp_M];
    temp_M = renamevars(temp_M,'Var1','Filename');
    M = [M; temp_M];
 end 
 
 t = [];
 for i=1:height(M)
    temp = strsplit(M.Filename(i),'.'); temp = temp(1); temp = strsplit(temp,'_');
    temp = temp(end); temp = str2num(temp); t = [t; temp];
 end
 M = [table(t) M];
 M = renamevars(M,'t','CodedFile#');
 
 %This code extracts cell z from the auto-generated label column in Fiji 
 %Measure files. Needs to be changed if only choosing z using one channel
 %as the default format of the label column is different
 label_bin = table();
 labels = string(M.Label);
 for i=1:length(labels)
    s = strsplit(labels(i),':');
    shape_type = strsplit(s(2),'_');
    label_bin(i,1) = {shape_type(1)};
    coded_z = str2num(s(3));
    %Coded z is written as: 1-2 are z=1, c=1-2. 3-4 are z=2, c=1-2. 
    %Thus, the true z is the coded z extracted from the column divided by 2 
    %and rounded up.
    if(mod(coded_z,2)==0) z = coded_z/2;
    else z = coded_z/2 + 0.5; end
    label_bin(i,2) = {z};
 end
 
 M = [M(:,1:4) label_bin M(:,5:end)];
 M = renamevars(M,'Var1','Shape_Type');
 M = renamevars(M,'Var2','Shape_Z');

 %% Extract data and organize summary files
 
 S = [];
 for i = 3:length(summary_files)
    temp_S = readtable([summary_files(i).folder '\' summary_files(i).name]);    
    %temp_M = renamevars(temp_M,'Var1','Cell#');
    temp_S = [table(string(repmat(summary_files(i).name,height(temp_S),1))) temp_S];
    temp_S = renamevars(temp_S,'Var1','Filename');
    S = [S; temp_S];
 end 
 
 t2 = [];
 for i=1:height(S)
    temp = strsplit(S.Filename(i),'.'); temp = temp(1); temp = strsplit(temp,'_');
    temp = temp(end); temp = str2num(temp); t2 = [t2; temp];
 end
 S = [table(t2) S];
 S = renamevars(S,'t2','CodedFile#');
 
 %This code extracts cell z from the auto-generated Slice column in Fiji 
 %Summary files
 label_bin = table();
 labels = string(S.Slice);
 cell_num = 0;
 for i=1:length(labels)
    s = strsplit(labels(i),':');
    z = strsplit(s(3),'/');
    z = str2num(z(1));
    label_bin(i,1) = {z};
    
    image_code = strsplit(s(3));
    label_bin(i,2) = {image_code(3)};
    if i==1 cell_num = 1;
    else if label_bin{i,2}~=label_bin{i-1,2} cell_num = 1; 
    else if label_bin{i,1}<label_bin{i-1,1} cell_num = cell_num+1; end; end
    end
    label_bin(i,3) = {cell_num};
 end
 
 S = [S(:,1:3) label_bin(:,1) label_bin(:,3) S(:,4:end)];
 S = renamevars(S,'Var1','Shape_Z');
 S = renamevars(S,'Var3','Cell#');

 
 
 

 
    
 
    

%% GRAPHING - Need to format data for import
% b = bar([1 2],[mean(gfpdata(:,5)) mean(sema4ddata(:,5))]);
% b.FaceColor = [.8 .8 .9];
% b.BarWidth = .8;
% hold on
% plotSpread(gfpdata(1:end,5),'BinWidth',.025,'DistributionMarkers','.','xValues',1);
% plotSpread(sema4ddata(1:end,5),'BinWidth',.025,'DistributionMarkers','.','xValues',2);
% e = errorbar([1 2], [mean(gfpdata(:,5)) mean(sema4ddata(:,5))], [std(gfpdata(:,5))/sqrt(length(gfpdata(:,5)))...
%     std(sema4ddata(:,5))/sqrt(length(sema4ddata(:,5)))]);
% e.LineWidth = 1.25;
% e.LineStyle = 'none';
% e.Color = 'r';
% box off
% 
% figure(2)
% b = bar([1 2],[mean(gfpdata(:,6)) mean(sema4ddata(:,6))]);
% b.FaceColor = [.8 .8 .9];
% b.BarWidth = .8;
% hold on
% plotSpread(gfpdata(1:end,6),'BinWidth',.025,'DistributionMarkers','.','xValues',1);
% plotSpread(sema4ddata(1:end,6),'BinWidth',.025,'DistributionMarkers','.','xValues',2);
% e = errorbar([1 2], [mean(gfpdata(:,6)) mean(sema4ddata(:,6))], [std(gfpdata(:,6))/sqrt(length(gfpdata(:,6)))...
%     std(sema4ddata(:,6))/sqrt(length(sema4ddata(:,6)))]);
% e.LineWidth = 1.25;
% e.LineStyle = 'none';
% e.Color = 'r';
% box off