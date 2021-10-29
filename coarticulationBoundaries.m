% Note: Add `midlevel-master` and `data` and subfolders to path.

fluxesNT = cepstralFluxes("word_boundaries/CNT004_06012018.txt", ...
    "word_boundaries/CNT004_06012018.wav");
fluxesASD = cepstralFluxes("word_boundaries/CASD005_07252018.txt", ...
    "word_boundaries/CASD005_07252018.wav");

assert(size(fluxesNT, 2) == size(fluxesASD, 2));
nWindows = size(fluxesNT, 2);
X = linspace(1, nWindows, nWindows)';

hold on
p1 = plot(X, fluxesNT, 'r');
p2 = plot(X, fluxesASD, 'b');
legend([p1(1), p2(1)], {'NT', 'ASD'})
xlabel('Window Difference')
ylabel('Cepstral Flux')
hold off

function fluxes = cepstralFluxes(annFilename, audioFilename)

    WINDOW_SIZE_MS = 100;

    [signal, sampleRate] = audioread(audioFilename);

    windowSizeSeconds = WINDOW_SIZE_MS / 1000;
    windowSizeFrames = sampleRate * windowSizeSeconds;
    
    fluxes = [];
    annTable = annotationTableFromTxt(annFilename);
    for rowNum = 1:height(annTable)
        startTime = annTable{rowNum, "startTime"};
        
        frameCenter = sampleRate * seconds(startTime);
        frameStart = int64(frameCenter - windowSizeFrames / 2);
        frameEnd = int64(frameCenter + windowSizeFrames / 2);

        audioClip = signal(frameStart:frameEnd,:);
        audioClipLeft = audioClip(:,1);
         
        applySmoothing = false;
        fluxes(rowNum, :) = cepstralFluxModified(audioClipLeft, sampleRate, applySmoothing);
    end
    
end

function annotationTable = annotationTableFromTxt(annotationFilename)
    % ANNOTATIONTABLEFROMTXT Read a tab-delimited annotation file with
    % columns 'tier', 'startTime', and 'label' and return a table with
    % the same columns.
    importOptions = delimitedTextImportOptions( ...
        'Delimiter', {'\t'}, ...
        'VariableNames', {'tier', 'startTime', 'label'}, ...
        'VariableTypes', {'string', 'duration', 'string'}, ...
        'ConsecutiveDelimitersRule', 'join' ...
        );
    annotationTable = readtable(annotationFilename, importOptions);
end
