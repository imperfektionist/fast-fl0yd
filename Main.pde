Config config;
AudioProcessor audioProcessor;
Visualization visualization;
VideoRecorder videoRecorder;

int totalFrames;

void setup() {

  createConsole();  // Initialize debug console regardless

  config = new Config(this);  // Initialize parameters, maybe read from file

  if (config.debugConsole == 1) {  // Close console if undesired
    changeConsoleFont(config.monoFont);
  } else {
    closeConsole();
  }

  fullScreen(JAVA2D);  // Fullscreen is default, renderer JAVA2D
  if (config.fullScreen == 0) {  // switch to specific window size and position
    surface.setSize(config.resolution[0], config.resolution[1]);
    surface.setLocation(config.windowPosition[0], config.windowPosition[1]);
  }

  try {
    if (config.randomSeedValue > 0) { // TODO: random seed does not work
      randomSeed(config.randomSeedValue);
    }

    audioProcessor = new AudioProcessor(config); // Initialize audio processor
    visualization = new Visualization(config); // Initialize visualization

    // General settings
    frameRate(config.frameRate);
    colorMode(HSB, 360, 1, 1);
    textFont(config.monoFont);
    smooth();

    videoRecorder = new VideoRecorder(config);  // Initialize VideoRecorder if recording is enabled

    // Total number of frames might be reduced by config.abortAfterFrames
    if (config.abortAfterFrames > 0 && config.recordVideo > 0) {
      totalFrames = config.abortAfterFrames;
    } else {
      totalFrames = (int) (audioProcessor.soundFile.duration() * config.frameRate);
    }

    audioProcessor.play();  // Start audio playback
  }
  catch (Exception e) {
    printToConsole("Error initializing visualizer: " + e.getMessage());
  }
}

void draw() {
  try {
    int currentFrame = frameCount - 1;

    // Check if PARAMETERS.ini has been modified
    long currentModifiedTime = new java.io.File(config.iniFilePath).lastModified();
    if (currentModifiedTime != config.lastModifiedTime) {
      config.loadParametersFromIni(config.iniFilePath); // Reload parameters from INI
      config.lastModifiedTime = currentModifiedTime; // Update last modified time
    }

    // Video recorder update
    if (config.recordVideo > 0) {
      if (config.randomSeedValue > 0) { // TODO: random seed does not work
        randomSeed(config.randomSeedValue * currentFrame);
      }

      float targetTime = currentFrame / (float) config.frameRate;
      audioProcessor.soundFile.jump(targetTime); // Set audio to exact time
      updateVisuals(); // Call the method directly for rendering visuals

      videoRecorder.saveFrame(currentFrame, totalFrames);

      if (currentFrame >= totalFrames) {
        videoRecorder.finishRecording();
        exit();
      }
    } else {
      updateVisuals(); // Call the same method for regular drawing
    }
  }
  catch (Exception e) {
    printToConsole("Error while updating: " + e.getMessage());
  }
}

void updateVisuals() {
  audioProcessor.processAudio();
  float[] bins = audioProcessor.getBins();
  config.calculateParams(bins);
  float[] params = config.params;

  // Add slight randomness to opacity to avoid Floyd artifacts, must be a Java issue or rounding error
  float fadeOpacity = map(params[7], 0, 1, config.fadeOpacityRange[0], config.fadeOpacityRange[1]) + random(2) - 1;
  fill(config.backgroundColor[0], config.backgroundColor[1], config.backgroundColor[2], fadeOpacity);
  noStroke();
  rect(0, 0, width, height); // Draw background with fade opacity

  visualization.update(bins); // Update visualization

  if (config.debugBins > 0) {
    debugBins(params, bins, config, visualization.getCurrentFloydCount(), visualization.getCurrentDirectionBias(), visualization.getCurrentDiscreteBias());
  }

  displayTimeline(audioProcessor, config);
}
