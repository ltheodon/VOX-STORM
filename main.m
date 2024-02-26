clear all;
close all;

%% META
RENDER = true;

se = strel('disk',3);


% Dimensions de la grille
% n = 97;
n = 129;
% n = 255;
% n = 351;
% n = 65;
% n = 49;

% iterations = 20;
% iterations = poissrnd(20)+1;
% iterations = ceil(betarnd(3,7)*100)
iterations = 40;
cFactor = .25;
weight_c = 5.0;
% alpha = 2*sqrt(2)+1e-5;
alpha = 5;
gLA = 60;
gEA = 10.125;
gLT = 3;
gET = 5;

% AJOUTER UN CHAMP GAUSSIEN
GFA = noiseField(n, gLA);
GFA = GFA(1:n,1:n,1:n).^gEA;
GFT = noiseField(n, gLT);
GFT = GFT(1:n,1:n,1:n).^gET;
GF = GFA .* GFT;

% Initialisation de la grille à false
grille = zeros(n, n, n);

% Mise à jour du point central à true
% centre = ceil((n+1)/2.5);
% grille(centre, centre, centre) = 1;
centre = (n+1)/2;
grille(centre, centre, centre) = 1;


% Définir le noyau pour la convolution
map = [0 1 0; 1 1 1; 0 1 0];
map = repmat(map,[1 1 3]);
map(2, 2, 2) = 0;
map(1, 1, 2) = 1;
map(1, 3, 2) = 1;
map(3, 1, 2) = 1;
map(3, 3, 2) = 1;
sz = [3, 3, 3];
[x, y, z] = ndgrid(1:sz(1), 1:sz(2), 1:sz(3));
% distances = 1./sqrt((x-2).^2 + (y-2).^2 + (z-2).^2);
distances = exp(-((x-2).^2/weight_c^2 + (y-2).^2 + (z-2).^2));
kd = zeros(sz);
kd(distances < Inf) = distances(distances < Inf);
% kd = kd ./ sum(kd,"all");
kernel = map .* kd;
kernel = kernel ./ sum(kernel,"all");
% distances(2, 2, 2) = 0;
% kernel = distances;

if(RENDER)
    f = figure('Position', [100, 500, 1200, 600], 'Visible', 'on');
end
tic
for k = 1:iterations
    % Trouver les cellules candidates en utilisant la convolution
    convResult = convn(grille, kernel, 'same');
%     convResult = convResult / sum(convResult(:));
    candidates = convResult .* ~grille;
    % convResult = convResult .* GF;
    
    % Obtenir les indices et les valeurs de convolution des cellules candidates
    [i, j, h] = ind2sub(size(candidates), find(candidates));
    
    if ~isempty(i)
        % Obtenir les valeurs de convolution comme des probabilités
        s2i = sub2ind(size(grille), i, j, h);
        % probs = convResult(s2i) .* GFA(s2i) .* GFT(s2i);
        probs = convResult(s2i) .* GF(s2i);
        
        % Sélectionner aléatoirement les indices en fonction des probabilités
        % idx = randsample(length(i), max(ceil(length(i) * cFactor),1), true, probs);
        idx = randsample(length(i), min(max(poissrnd(ceil(length(i) * cFactor)),1),length(i)), true, probs);
        
        % Mettre à jour la grille avec les voxels sélecti onnés
        linearIdx = sub2ind(size(grille), i(idx), j(idx), h(idx));
        grille(linearIdx) = convResult(linearIdx)>0;
    end

    if(RENDER)
        clf;
        subplot(1,2,1)
        [i, j, h] = ind2sub(size(grille), find(grille));
        % render3D(i,j,h,alpha,150,-35);
        render3D(i,j,h,alpha,0,220);
        xlim([0 (n+1)])
        ylim([0 (n+1)])
        zlim([0 (n+1)])
        subplot(1,2,2)
        I = max(grille>0,[],3);
        sk = 4;
        I = imresize(I,sk);
        I = imdilate(I,se);
        I = imerode(I,se);
        I = imopen(I,se);
        imshow(~I + .75*I)
        hold on
        try
            [B, L] = bwboundaries(I, 'noholes');
            boundary = B{1};
            boundary = [boundary; boundary(1,:)];
            plot(boundary(:,2), boundary(:,1), 'LineWidth', 1, 'Color', [0 32 96]/255);
        catch
        end
        render3D(sk*j,sk*i,sk*h,sk*alpha,180,220);
        axis off
        xlim([0 sk*(n+1)])
        ylim([0 sk*(n+1)])
        zlim([0 sk*(n+1)])
        drawnow
        pause(.025);
        hold off
    end
end
toc



