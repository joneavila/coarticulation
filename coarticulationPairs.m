% Note: Add `midlevel-master`, `data`, and 'nmsu-copy' and subfolders to 
% path.

% TODO: Create `histogram` directory.

% Assume all *_S2_*.wav files exist here.
REL_PATH_ISOLATED = 'data/isolated';
REL_PATH_METADATA_AGES = 'nmsu_copy/metadata-ages.txt';

opts = delimitedTextImportOptions('VariableTypes', {'string', 'double'}, 'VariableNames', {'ID', 'age'}, 'Delimiter', '\t');
metadataTable = readtable(REL_PATH_METADATA_AGES, opts);

for rowIdx = 1:2:height(metadataTable)
    
    rowIdxASD = rowIdx;
    rowIdxNT = rowIdx + 1;
    
    idASD = metadataTable{rowIdxASD, 1};
    idNT = metadataTable{rowIdxNT, 1};
    
    ageASD = metadataTable{rowIdxASD, 2};
    ageNT = metadataTable{rowIdxNT, 2};
    
    fluxASD = cepstralFluxWithID(REL_PATH_ISOLATED, idASD);
    fluxNT = cepstralFluxWithID(REL_PATH_ISOLATED, idNT);
    
    clf;
    
    % Create histogram plot.
    N_BINS = 60;
    NORMALIZATION = 'probability';
    BIN_LIMITS = [0, 325];
    hold on
    histogram(fluxASD, N_BINS, 'Normalization', NORMALIZATION, ...
        'BinLimits', BIN_LIMITS, 'FaceColor', '#2196f3', 'DisplayName', ...
        sprintf('%s (age %.2f)', idASD, ageASD));
    histogram(fluxNT, N_BINS, 'Normalization', NORMALIZATION, ...
        'BinLimits', BIN_LIMITS, 'FaceColor', '#f44336', 'DisplayName', ...
        sprintf('%s (age %.2f)', idNT, ageNT));
    legend
    xlabel('Cepstral Flux Bin')
    ylabel('Bin Count (Normalized)')
    title('Cepstral Flux (Dialog)')
    hold off
    
    savefig(sprintf('histograms/pairs/%s_%s.fig', idASD, idNT));

end

function flux = cepstralFluxWithID(relPathIsolated, ID)

    % All files in relPathIsolated matching 
    % "<ID>_*_S2.wav", e.g. "CASD001_07112017_S2.wav".
    disp(ID);
    audioFiles = dir([relPathIsolated, '/', char(ID), '_*_S2.wav']);
    
    % There should be just a single file matching this pattern.
    assert(size(audioFiles, 1) == 1);
    audioFile = audioFiles(1);

    pathAudio = [audioFile.folder, '/', audioFile.name];
    [signal, sampleRate] = audioread(pathAudio);
    signalLeft = signal(:, 1);
    % fprintf('Processing %s\n', audioFile.name);

    % Remove rows with zero, i.e. discard portions with silence.
    signalLeft(all(~signalLeft, 2), :) = [];

    flux = cepstralFluxModified(signalLeft, sampleRate);
end
