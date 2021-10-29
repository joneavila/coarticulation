% Note: Add `midlevel-master` and `data` and subfolders to path.

% Assume all *_S2_*.wav files exist here.
REL_PATH_ISOLATED_UTTERANCES = 'data/isolated_utterances';

fluxesASD = cepstralFluxUtterances(REL_PATH_ISOLATED_UTTERANCES, 'ASD');
fluxesNT = cepstralFluxUtterances(REL_PATH_ISOLATED_UTTERANCES, 'NT');

% Create histogram plot.
N_BINS = 60;
NORMALIZATION = 'probability';
BIN_LIMITS = [0, 325];
hold on
histogram(fluxesASD, N_BINS, 'Normalization', NORMALIZATION, ...
    'BinLimits', BIN_LIMITS, 'FaceColor', '#2196f3', 'DisplayName', 'ASD');
histogram(fluxesNT, N_BINS, 'Normalization', NORMALIZATION, ...
    'BinLimits', BIN_LIMITS, 'FaceColor', '#f44336', 'DisplayName', 'NT');
legend
xlabel('Cepstral Flux Bin')
ylabel('Bin Count (Normalized)')
hold off

savefig(sprintf('histograms/grouped/coeff%d.fig', coeffNum));

%% Now do the same but using the cepstralFluxCoeffs measure.

fluxesASD = cepstralFluxUtterancesCoeffs(REL_PATH_ISOLATED_UTTERANCES, 'ASD');
fluxesNT = cepstralFluxUtterancesCoeffs(REL_PATH_ISOLATED_UTTERANCES, 'NT');

% Print mean, max, and min for each coefficient.
assert(size(fluxesASD, 2) == size(fluxesNT, 2))
for coeffNum = 1:size(fluxesASD, 2)
    coeffMean = mean(fluxesASD(:, coeffNum));
    coeffMax = max(fluxesASD(:, coeffNum));
    coeffMin = min(fluxesASD(:, coeffNum));
    fprintf('Coeff #%d: mean=%f, max=%f, min=%f\n', coeffNum, coeffMean, coeffMax, coeffMin);
end

% Create histogram plots, one for each coefficient.
assert(size(fluxesASD, 2) == size(fluxesNT, 2))
for coeffNum = 1:size(fluxesASD, 2)
    
    clf;
    
    N_BINS = 60;
    NORMALIZATION = 'probability';
    BIN_LIMITS = [-20, 20];
    hold on
    histogram(fluxesASD(:, coeffNum), N_BINS, 'Normalization', ...
        NORMALIZATION, 'BinLimits', BIN_LIMITS, 'FaceColor', '#2196f3', ...
        'DisplayName', 'ASD');
    histogram(fluxesNT(:, coeffNum), N_BINS, 'Normalization', ...
        NORMALIZATION, 'BinLimits', BIN_LIMITS, 'FaceColor', '#f44336', ...
        'DisplayName', 'NT');
    legend
    xlabel('Coefficient Value Bin')
    ylabel('Bin Count (Normalized)')
    title(sprintf('MFCC #%d', coeffNum))
    hold off
    
    % TODO Create output directory.
    savefig(sprintf('histograms/grouped_MFCCs/coeff%d.fig', coeffNum));
end

function fluxesCoeffs = cepstralFluxUtterancesCoeffs(relPathIsolatedUtterances, group)

    % All files in relPathIsolatedUtterances matching 
    % "C<group>*_S2_*.wav", e.g. "CASD001_07112017_S2_1.wav".
    audioFiles = dir([relPathIsolatedUtterances, '/C', group, '*_S2_*.wav']);
    
    fluxesCoeffs = [];

    for fileNum = 1:size(audioFiles, 1)
        audioFile = audioFiles(fileNum);
        pathAudio = [audioFile.folder, '/', audioFile.name];
        [signal, sampleRate] = audioread(pathAudio);
        signalLeft = signal(:, 1);
        fprintf('Processing %s\n', audioFile.name);

        % Remove rows with zero, i.e. discard portions with silence.
        signalLeft(all(~signalLeft, 2), :) = [];

        fluxCoeffs = cepstralFluxCoeffs(signalLeft, sampleRate);
        fluxesCoeffs = [fluxesCoeffs; fluxCoeffs];
    end
end

function fluxes = cepstralFluxUtterances(relPathIsolatedUtterances, group)

    % All files in relPathIsolatedUtterances matching 
    % "C<group>*_S2_*.wav", e.g. "CASD001_07112017_S2_1.wav".
    audioFiles = dir([relPathIsolatedUtterances, '/C', group, '*_S2_*.wav']);
    
    fprintf('Processing utterances for group: %s ', group);
    
    fluxes = [];
    
    nCharsLastPrint = 0;
    numFiles = size(audioFiles, 1);
    for fileNum = 1:numFiles
        audioFile = audioFiles(fileNum);
        pathAudio = [audioFile.folder, '/', audioFile.name];
        [signal, sampleRate] = audioread(pathAudio);
        signalLeft = signal(:, 1);
        
        % Print progress message, erasing previous progress message first
        toPrint = sprintf('[%d/%d]', fileNum, numFiles);
        fprintf(repmat('\b', 1, nCharsLastPrint));
        fprintf(toPrint);
        nCharsLastPrint = numel(toPrint);

        % Remove rows with zero, i.e. discard portions with silence.
        signalLeft(all(~signalLeft, 2), :) = [];
        
        applySmoothing = false;
        flux = cepstralFluxModified(signalLeft, sampleRate, applySmoothing);
        fluxes = [fluxes; flux];
    end
    
    fprintf('\n');
end
