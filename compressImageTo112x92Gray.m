function compressedImg = compressImageTo112x92Gray(img)
% COMPRESSIMAGETO112X92GRAY 将任意图片压缩为112x92的灰度图
%   输入:
%       imagePath - 图片文件路径（字符串，如 'input.jpg'）
%   输出:
%       compressedImg - 处理后的112x92灰度图像矩阵（uint8类型）

    try
        
        %  转换为灰度图像（处理RGB或彩色图）
        if ndims(img) == 3 && size(img,3) == 3
            grayImg = rgb2gray(img);
        else
            grayImg = img(:,:,1); % 处理单通道或异常情况
        end

        %  压缩到112x92尺寸
        targetSize = [112, 92]; % [高度, 宽度]
        compressedImg = imresize(grayImg, targetSize);
        
        %  确保输出为uint8类型（兼容性处理）
        if ~isa(compressedImg, 'uint8')
            compressedImg = im2uint8(compressedImg);
        end
        
    catch ME
        % 错误处理（如文件不存在、非图像文件等）
        error('Error: %s', ME.message);
    end
end