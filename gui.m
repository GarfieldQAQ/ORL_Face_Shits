clear all;
close all;
load ("./mat/face_save_pca2d.mat");
load ("./mat/svm_model.mat");
simpleImageProcessor(avrgx,Vpca1,Vpca,svmModel,kkk,kkk1,threshold);

function simpleImageProcessor(avrgx,Vpca1,Vpca,svmModel,kkk,kkk1,threshold)
% 创建主窗口


fig = figure('Name', '简单图像处理器', 'NumberTitle', 'off', ...
    'Position', [200, 200, 800, 600], 'MenuBar', 'none', ...
    'ToolBar', 'none', 'Resize', 'on');

% 创建"加载图片"按钮
loadBtn = uicontrol('Style', 'pushbutton', 'String', '加载图片', ...
    'Position', [20, 550, 100, 30], ...
    'Callback', @loadImage);

% 创建"匹配图片"按钮（预留功能）
processBtn = uicontrol('Style', 'pushbutton', 'String', '匹配图片', ...
    'Position', [140, 550, 100, 30], ...
    'Callback', @processImage, 'Enable', 'off');

% 创建原始图像显示区域
origAxes = axes('Parent', fig, 'Units', 'pixels', ...
    'Position', [150, 250, 250, 250]);
title(origAxes, '原始图像');
axis(origAxes, 'off');

% 创建处理后图像显示区域
procAxes1 = axes('Parent', fig, 'Units', 'pixels', ...
    'Position', [450, 250, 250, 250]);
title(procAxes1, '输出结果');
axis(procAxes1, 'off');


% 状态文本
statusText = uicontrol('Style', 'text', 'String', '请加载一张图片', ...
    'Position', [300, 550, 200, 30], ...
    'HorizontalAlignment', 'center');

% 存储图像数据
originalImage = [];
processedImage = [];

% 加载图片回调函数
    function loadImage(~, ~)
        [filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp;*.tif;*.pgm', '图像文件 (*.jpg, *.png, *.bmp, *.tif, *.jpg)'}, ...
            '选择图像文件');
        if isequal(filename, 0)
            set(statusText, 'String', '用户取消选择');
            return;
        end

        try
            fullpath = fullfile(pathname, filename);
            originalImage = imread(fullpath);

            % 显示原始图像
            axes(origAxes);
            imshow(originalImage);
            title(origAxes, ['原始图像']);

            % 启用处理按钮
            set(processBtn, 'Enable', 'on');
            set(statusText, 'String', '图片加载成功');

        catch ME
            set(statusText, 'String', ['错误: ' ME.message]);
        end
    end

% 匹配图片回调函数（预留）
    function processImage(~, ~)
        if isempty(originalImage)
            set(statusText, 'String', '请先加载一张图片');
            return;
        end

        try
            originalImage = compressImageTo112x92Gray(originalImage);
            processedImage = double(originalImage)/255;
            processedImage = processedImage.^0.5;         % 对比度增强（若训练阶段使用）
            processedImage = processedImage - avrgx; % 使用训练集的平均脸

            % 2D-PCA投影
            feature = Vpca1' * processedImage * Vpca;
            feature = reshape(feature, 1, kkk*kkk1);
            [label, scores, feature_probs] = predict(svmModel, feature);
            feature_confidence = max(feature_probs, [], 2);
            if (feature_confidence < 0.8)
                processedImage = imread('./guiimg/1.jpg');
                axes(procAxes1);
                imshow(processedImage);
                title(procAxes1, [sprintf('识别失败不在库中')]);
            else
                processedImage = imread(sprintf('orl-faces\\s%d\\%d.pgm',label,1));
                axes(procAxes1);
                imshow(processedImage);
                title(procAxes1, [sprintf('识别成功！匹配类别%d',label)]);
            end
        catch ME
            set(statusText, 'String', ['处理错误: ' ME.message]);
        end
    end
end