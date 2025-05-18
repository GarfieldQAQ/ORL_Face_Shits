load ("./mat/face_save_pca2d.mat");
load ("./mat/svm_model.mat");
% 训练阶段：计算均值和标准差
mean_train = mean(Y_flat);      % 均值向量（1×特征数）
std_train = std(Y_flat);        % 标准差向量（1×特征数）
Y_flat = (Y_flat - mean_train) ./ std_train;

% 生成标签（假设每个训练样本的标签按顺序排列）
labels_train = repelem(1:40, m)'; % 40类，每类m个样本

% 替换原代码中的分类逻辑（select判断部分）
% 训练SVM模型（以RBF核为例）
% 配置RBF核模板，启用超参数优化
% template = templateSVM('KernelFunction', 'rbf', 'Standardize', true);
% svmModel = fitcecoc(Y_flat, labels_train, ...
%     'Learners', template, ...
%     'OptimizeHyperparameters', {'BoxConstraint', 'KernelScale'}, ...
%     'HyperparameterOptimizationOptions', struct('Verbose', 1, 'ShowPlots', true));
% % 使用t-SNE可视化特征分布
% Y_tsne = tsne(Y_flat);
% figure;
% gscatter(Y_tsne(:,1), Y_tsne(:,2), labels_train);
% title('t-SNE特征分布');
% xlabel('t-SNE1'); ylabel('t-SNE2');

% 若点簇未按类别分离，需改进特征提取（如增大kkk/kkk1）

% 验证/测试阶段：使用训练集的均值和标准差
val_features = (val_features - mean_train) ./ std_train;
val_features(isnan(val_features)) = 0; % 处理零方差特征


[pred_labels, scores, probs] = predict(svmModel, val_features);
confidence = max(probs, [], 2);
threshold = quantile(confidence, 0.95); % 保留置信度最高的95%样本


% 准确率
accuracy = sum(pred_labels == val_labels) / numel(val_labels);
disp(['验证集准确率：', num2str(accuracy*100), '%']);

% 混淆矩阵
conf_mat = confusionmat(val_labels, pred_labels);
figure;
heatmap(conf_mat);
title('验证集混淆矩阵');


save face_save_pca2d;
% 保存SVM模型（可选）
% save('svm_model.mat', 'svmModel');