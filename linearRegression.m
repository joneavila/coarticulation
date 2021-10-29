% Assume all *_S2_*.wav files exist here.
REL_PATH_ISOLATED_UTTERANCES = 'data/isolated_utterances';

fluxesASD = cepstralFluxes(REL_PATH_ISOLATED_UTTERANCES, 'ASD');
fluxesNT = cepstralFluxes(REL_PATH_ISOLATED_UTTERANCES, 'NT');

% Evaluate a linear regressor.
[Xtrain, Ytrain, Xtest, Ytest] = split(fluxesASD, fluxesNT);
regressor = fitlm(Xtrain, Ytrain);
Ypred = predict(regressor, Xtest);
mse = @(actual, pred) (mean((actual - pred) .^ 2));
regressorMSE = mse(Ypred, Ytest);
fprintf('regressorMSE = %f\n', regressorMSE);

function [Xtrain, Ytrain, Xtest, Ytest] = split(fluxesASD, fluxesNT)

    % Set seed for reproducibility
    rng(2021107);
    
    % Shuffle windows.
    fluxesASD = fluxesASD(randperm(length(fluxesASD)));
    fluxesNT = fluxesNT(randperm(length(fluxesNT)));

    % Trim either fluxesASD or fluxesNT to match in size.
    nWindowsASD = size(fluxesASD, 1);
    nWindowsNT = size(fluxesNT, 1);
    if nWindowsASD < nWindowsNT
        fluxesNT = fluxesNT(1:nWindowsASD, :);
    elseif nWindowsASD > nWindowsNT
        fluxesASD = fluxesASD(1:nWindowsNT, :);
    end
    
    % Split into train set (80%) and test set (20%).
    assert(size(fluxesASD, 1) == size(fluxesNT, 1));
    nWindows = size(fluxesASD, 1);
    splitIdx = int64(nWindows * 0.80);

    XtrainASD = fluxesASD(1:splitIdx, :);
    XtrainNT = fluxesNT(1:splitIdx, :);

    XtestASD = fluxesASD(splitIdx+1:end, :);
    XtestNT = fluxesNT(splitIdx+1:end, :);

    YtrainASD = ones(size(XtrainASD, 1), 1);
    YtrainNT = zeros(size(XtrainNT, 1), 1);

    YtestASD = ones(size(XtestASD, 1), 1);
    YtestNT = zeros(size(XtestNT, 1), 1);

    Xtrain = [XtrainASD; XtrainNT];
    Ytrain = [YtrainASD; YtrainNT];

    Xtest = [XtestASD; XtestNT];
    Ytest = [YtestASD; YtestNT];
end