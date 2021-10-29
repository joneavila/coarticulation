function flux = cepstralFluxCoeffs(signal, sampleRate)

    % This function is the same as cepstralFluxModified, but doesn't
    % square and sum the differences between windows. flux is a matrix 
    % with shape (<~N_WINDOWS> x <N_COEFFS>) measuring the difference 
    % between coefficients between windows.

    % Compute MFCCs using parameters from Kamil Wojcicki's mfcc.m 
    % documentation.
    nCoeff = 13;
    cc = mfcc(signal, sampleRate, 25, 10, 0.97, @hamming, [300 3700], ...
        20, nCoeff, 22);

    % Pad due to the window size. (I'm not sure if this is needed.)
    cc = [zeros(nCoeff, 1) cc zeros(nCoeff, 1)];
    
    cct = cc'; 
    diff = cct(2:end,:) - cct(1:end-1,:);  
    
    flux = diff;
end