function createContourManual(Layers, F, ind_Refstack,binsize)
%createContourManual allows to select ROI by hand
% Layers
% F             focus
% ind_Refstac   indices of reference stack

% TODO integrate Geoffrey's easy algorithm

for layer = Layers
    try % try to load existing contour
        load(fullfile(F.dir.files, 'signal_stacks', num2str(layer), 'contour.mat'));
    catch % otherwise, create it
        Limg = @(n) double(imread(fullfile(F.dir.images, [F.IP.prefix num2str(n, F.IP.format) '.tif'])));
        Img1 = Limg(size(F.sets,2)*(ind_Refstack-1)+(layer-1));
        
%             % Load first image of the set \\ automatic zone
%     Img = F.iload(10);
%     Tmp1 = Img1;
%     Tmp1.rm_infos();
%     Tmp1.filter('Gaussian', 'box', [5 5], 'sigma', 2);
%         
%     % Get default threshold value
%     th = graythresh(Tmp1.pix)*(max(Tmp1.pix(:)))/10;

        Img1sm = imresize(Img1,1/binsize);
        figure(100);
        imshow(rescalegd(Img1sm));
        if binsize == 10
            BW = ones(size(Img1sm,1),size(Img1sm,2),'logical');
            w = find(BW==1);
        else
            BW = roipoly;
            w = find(BW==1);
        end

        % --- Out directorties ---
        outdir = fullfile(F.dir.files, 'signal_stacks', num2str(layer));
        [status, message, messageid] = rmdir(outdir,'s');
        mkdir(outdir)
        save(fullfile(F.dir.files, 'signal_stacks', num2str(layer), 'contour.mat'), 'w');
    end
    W{layer-(Layers(1)-1)} = w;
    
end


close gcf
disp('all ROI have been defined')
    
    
end