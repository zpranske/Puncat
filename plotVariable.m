function[barGraphHandle] = plotVariable(T, var2graph, x_group_string, xlabel, ylabel, newtitle)
    %var2graph is the name of the table header you want to graph
    %x_groups is the list of subgroupings you want to graph by, e.g.
    %    condition or brain region. It should be a string array containing the
    %    names of each subgroup
    
    if nargin >= 4 xaxislabel=xlabel; else xaxislabel=x_group_string; end
    if nargin >= 5 yaxislabel=ylabel; else yaxislabel=var2graph; end
    if nargin >= 6 title=newtitle; else title=var2graph; end
    
    x_groups = table2array(unique(T(:,strcmp(T.Properties.VariableNames,x_group_string))));
    
     %Make a cell containing one subtable for each x_group
     subT_x_group = {};
     T_column = [T(:,strcmp(T.Properties.VariableNames,x_group_string)) T(:,strcmp(T.Properties.VariableNames,var2graph))];
     for i=1:length(x_groups)
         subT_x_group{i} = T_column(table2array(T_column(:,1))==x_groups(i),2);
     end

    %Extract the table column corresponding to the variable above for each
    %condition and put it in a 1xn cell where each cell is an array
    %containing all var2graph data for one condition
    subT_univariate = {};
    for i=1:length(x_groups)
         subT_univariate{i} = table2array(subT_x_group{i}(:,strcmp(subT_x_group{i}.Properties.VariableNames,var2graph)));
    end

    b=bar([1:length(x_groups)]); hold on;
    for i=1:length(x_groups)
        b.YData(i) = mean(subT_univariate{i}(:,1));
    end

    for i=1:length(x_groups)
        plotSpread(subT_univariate{i},'BinWidth',.025,'DistributionMarkers','.','xValues',i);
        e = errorbar(i,mean(subT_univariate{i}),mean(subT_univariate{i})/sqrt(height(subT_univariate{i})));
        e.LineWidth = 1.25;
        e.LineStyle = 'none';
        e.Color = 'r';
    end

    b.Parent.XAxis.TickValues = [1:length(x_groups)];
    b.FaceColor = [.8 .8 .9]; box off;
    b.BarWidth = .8;
    b.Parent.XTickLabel = x_groups;
    b.Parent.XLabel.String = xaxislabel;
    b.Parent.YLabel.String = yaxislabel;
    b.Parent.Title.String = title;
    
    barGraphHandle = b;
return