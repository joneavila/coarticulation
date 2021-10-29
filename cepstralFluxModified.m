function flux = cepstralFluxModified(signal, sampleRate, applySmoothing)

    % Compute MFCCs using parameters from Kamil Wojcicki's mfcc.m 
    % documentation.
    nCoeff = 13;
    cc = mfcc(signal, sampleRate, 25, 10, 0.97, @hamming, [300 3700], ...
        20, nCoeff, 22);

    % Pad due to the window size. (I'm not sure if this is needed.)
    cc = [zeros(nCoeff, 1) cc zeros(nCoeff, 1)];
    
    cct = cc'; 
    diff = cct(2:end,:) - cct(1:end-1,:);  
    diffSquared = diff .*diff;
    sumdiffsq = sum(diffSquared,2);
    
    if applySmoothing
        
        % Smooth over 150ms windows.
        smoothed = smoothJcc(sumdiffsq, 15);
        flux = smoothed;
    else
        flux = sumdiffsq;
    end
end