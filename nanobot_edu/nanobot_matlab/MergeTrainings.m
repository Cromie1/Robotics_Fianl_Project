clear;clc;close all;

files = uigetfile("MultiSelect",'on','.mat');

currentIndex = 1;
for i = 1:length(files)
    load(files{i});
    [h,w] = size(data);
    if i == 1
        comparitor = [data{:,1}];
    else
        if sum(comparitor == [data{:,1}])~=height(data)
            error("Invalid Training Sets. Wrong size to Merge");
        end
        data = data(:,2:end);
    end
    [h,w] = size(data);
    BigData(1:h,currentIndex:currentIndex+w-1) = data;
    currentIndex = currentIndex+w;
end

data = BigData;

t = clock;
filename = sprintf("%d%d%d_%d%d%d_MergedTrainingSet_%dGestures%dTrials",t(1),t(2),t(3),t(4),t(5),round(t(6)),height(data),width(data)-1);
save(filename, "data");
