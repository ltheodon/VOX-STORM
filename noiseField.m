% Fonction pour créer un champ de bruit
function noise = noiseField(n, correlationLength)
    % Création d'un noyau gaussien isotrope
    [x, y, z] = ndgrid(linspace(-n/2, n/2, n+1), linspace(-n/2, n/2, n+1), linspace(-n/2, n/2, n+1));
    r = sqrt(x.^2 + y.^2 + z.^2);
    kernel = exp(-(r/correlationLength).^2);
    
    % Transformée de Fourier du noyau
    kernel_fft = fftn(kernel);
    
    % FFT d'un bruit blanc
    noise_fft = fftn(randn(n+1, n+1, n+1));
    
    % Multiplication dans le domaine fréquentiel
    noise = real(ifftn(noise_fft .* kernel_fft));
    
    % Normalisation
    noise = noise - min(noise(:));
    noise = noise / max(noise(:));
end


