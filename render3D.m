function [] = render3D(x,y,z,w,alpha,beta)
    shp = alphaShape(x, y, z, w);
    % Obtention des faces du bord
    F = boundaryFacets(shp);
    % Obtention des sommets de votre alphaShape
    P = shp.Points;
    % Création de la figure
    % Utilisation de patch pour dessiner chaque face
    p=patch('Vertices', P, 'Faces', F, 'FaceColor', [.5 .5 .5], 'EdgeColor', 'none');
    % Activation de l'interpolation de shading pour un rendu plus lisse
    % shading interp;
    % Ajout d'une source lumineuse pour améliorer la visualisation 3D
    if true
        camlight headlight; 
        lighting gouraud;
        lightangle(alpha,beta)
    end
    p.FaceLighting = 'gouraud';
    p.AmbientStrength = .25;
    p.DiffuseStrength = .7;
    p.SpecularStrength = .6;
    p.SpecularExponent = .125;
    p.BackFaceLighting = 'lit';
    % Ajustements optionnels
    axis equal; % Pour garder les proportions égales
    view(3); % Pour une vue 3D
    % xlabel('X');
    % ylabel('Y');
    % zlabel('Z');
    axis off
    ax = gca;
    ax.Color = [0 0 0];
end