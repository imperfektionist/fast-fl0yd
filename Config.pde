import java.io.BufferedReader;
import java.io.FileReader;
import java.io.File;
import java.io.IOException;
import java.util.HashMap;

class Config {
  PApplet parent;
  HashMap<String, float[]> parameterMappings = new HashMap<>();
  long lastModifiedTime;

  // Paths and environment settings
  int useIniFile = 1; // If > 0, use PARAMETERS.ini values
  boolean initialLoadDone = false; // Some parameters can not be overwritten during visualization
  String iniFilePath; // Path to the INI file, initialized in constructor
  String audioFile = ossify("data/audio_input/timekeeper.mp3"); // Default audio file
  String videoPath = ossify("data/video_output/");  // Directory to save movies in
  String ffmpegPath = ossify("C:/ffmpeg/bin/ffmpeg.exe");  // Absolute FFmpeg path

  // General settings
  int frameRate = 60;
  int[] resolution = {2560, 1440};
  int[] windowPosition = {0, 0};
  int fullScreen = 0;
  int debugBins = 1;
  int debugConsole = 1;
  int recordVideo = 0;
  int videoQuality = 90;
  int abortAfterFrames = 0;
  int randomSeedValue = 0;

  // Adjustable parameters
  float volumeFactor = 1.4f; // Audio volume multiplier
  int movingAverageBinFrames = 3; // Frames to average frequency bins
  int movingAverageEnvelopeFrames = 60; // Frames to average audio envelope
  float activateFloydRate = 3; // Max frames between activating/deactivating one Floyd
  int[] floydsRange = {1, 120}; // Range for the number of Floyds
  int[] positionDelayFramesRange = {3, 40}; // Range of position delay frames for Floyds
  float[] velocityRange = {0, 50}; // Range of Floyd velocity values
  float[] angleRandomRange = {0, 6}; // Range of angle randomness for Floyds
  float[] lineWidthRange = {2, 8}; // Range for line width drawn by Floyds
  float masterSpeedBoost = 2; // Speed multiplier for Master Floyd
  float[] masterAngleRandomRange = {0, 0.2f}; // Range for angular randomness of Master Floyd
  float[] masterProximityBoostRange = {0.7f, 1.4f}; // Proximity boost for Floyds when near Master Floyd
  float[] masterFloydMargin = {0.15f, 0.15f}; // Relative X,Y-margin for Master Floyd boundaries
  float[] cohesionRange = {0.2f, 4}; // Cohesion factor range controlling attraction to Master Floyd

  // Visual settings
  float[] backgroundColor = {0, 0, 100}; // Background color (HSB)
  float[] lineColor = {0, 0, 0}; // Color for lines drawn by Floyds (HSB)
  float circleHue1 = 0; // Initial hue for first circle color
  float circleHue2 = 180; // Initial hue for second circle color
  float hueRotationRate = 0.3f; // Rate at which hue changes
  float[] circleSaturationRange = {0.8, 1}; // Saturation for circles
  float[] circleBrightnessRange = {0.2f, 1}; // Intensity range for circle brightness
  float[] circleSizeRange1 = {0, 60}; // Range for size of first circle
  float[] circleSizeRange2 = {0, 60}; // Range for size of second circle
  float[] fadeOpacityRange = {15, 5}; // Opacity range for fading effect

  // Direction and movement bias settings
  float[] switchDirectionChanceRange = {0.1f, 6}; // Time range for direction bias switch interval (seconds)
  float[] switchDiscreteChanceRange = {0.1f, 6}; // Time range for discrete movement bias switch interval (seconds)
  float angularBiasFactor = 0.1f; // Random between 0 and this multiplied with directionBiasOptions
  float[] directionBiasOptions = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.5f, 1, 2, -0.5f, -1, -2}; // Bias directions
  float[] discreteBiasOptions = {0, 3, 4, 5, 6, 7, 8, 9, 10, 12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}; // Discrete movement biases

  // Other settings
  int fftBands = 128; // Number of FFT bands
  PFont monoFont; // Font field

  // Custom parameters
  float[][] paramMappings = new float[10][7]; // Mapping for each param from bins
  float[] params = new float[10]; // Params array

  Config(PApplet parent) {
    this.parent = parent;
    iniFilePath = parent.sketchPath(ossify("data/PARAMETERS.ini")); // change INI path here
    setDefaultMappings();

    // Load parameters from INI file
    if (useIniFile > 0) {
      loadParametersFromIni(iniFilePath);
      lastModifiedTime = new java.io.File(iniFilePath).lastModified(); // Set the last modified time
    }

    // Ensure audio file path is resolved within the data directory for the sound library
    audioFile = parent.sketchPath(audioFile);
    printToConsole("Resolved audio file path: " + audioFile);

    // Initialize the font
    if (useIniFile <= 0) {
      monoFont = parent.createFont("Courier", 14, true); // Default font initialization
    }
  }

  void setDefaultMappings() {
    // Default parameter mappings initialization
    parameterMappings.put("param0", new float[]{1, 0.1f, 0, 0, 0, 0, 0});
    parameterMappings.put("param1", new float[]{0, 0, 1, 0, -1, 0, 1});
    parameterMappings.put("param2", new float[]{0, 1, 0, 0, 0, 0, 0});
    parameterMappings.put("param3", new float[]{0, 0, 0, 0, 1, 0, 0});
    parameterMappings.put("param4", new float[]{0, 0, 0, 1, 0, 0, 0});
    parameterMappings.put("param5", new float[]{0, 0, 0, 0, 0, 1, 0});
    parameterMappings.put("param6", new float[]{0, 0, 0, 0, 0.5f, 0, 0.5f});
    parameterMappings.put("param7", new float[]{0.5f, 0.5f, 0, 0, 0, 0, 0});
    parameterMappings.put("param8", new float[]{-1, 0, 0, 1, 0, 0, 0});
    parameterMappings.put("param9", new float[]{0, 0, 0, 0, 0, 0, 0});
  }

  void loadParametersFromIni(String filename) {
    try (BufferedReader reader = new BufferedReader(new FileReader(filename))) {
      String line;
      printToConsole("\n------- " + getCurrentDateTime() + " -------");
      printToConsole("Loading parameters from INI file...");

      while ((line = reader.readLine()) != null) {
        line = line.trim();

        // Skip empty lines or comment-only lines
        if (line.isEmpty() || line.startsWith(";") || !line.contains("=")) {
          continue;
        }

        // Remove inline comments after values
        int commentIndex = line.indexOf(";");
        if (commentIndex != -1) {
          line = line.substring(0, commentIndex).trim();
        }

        // Split line into key-value pair
        String[] parts = line.split("=", 2);
        if (parts.length < 2) {
          printToConsole("Skipping invalid line: " + line);
          continue;
        }

        String key = parts[0].trim();
        String value = parts[1].trim().replaceAll("^\"|\"$", ""); // Remove leading/trailing quotes

        printToConsole("Reading line: " + key + " = " + value);  // Log each line

        try {
          // Parse and constrain INI parameters here
          // AUDIO SETTINGS
          if (key.equals("audioFile") && !initialLoadDone) {
            audioFile = ossify(value); // Set the audioFile directly from ini
            printToConsole("--> Audio file set to: " + audioFile);
          } else if (key.equals("volumeFactor")) {
            volumeFactor = constrain(Float.parseFloat(value), 0, 100);
            printToConsole("--> Volume factor set to: " + volumeFactor);

            // VIDEO SETTINGS
          } else if (key.equals("ffmpegPath") && !initialLoadDone) {
            ffmpegPath = ossify(value); // Set the video path directly from ini
            printToConsole("--> FFmpeg path: " + ffmpegPath);
          } else if (key.equals("videoPath") && !initialLoadDone) {
            videoPath = ossify(value); // Set the video path directly from ini
            printToConsole("--> Video path set to: " + videoPath);
          } else if (key.equals("frameRate") && !initialLoadDone) {
            frameRate = constrain(Integer.parseInt(value), 1, 240);
            printToConsole("--> Frame rate set to: " + frameRate);
          } else if (key.equals("resolution") && !initialLoadDone) {
            resolution = parseIntRange(value);
            resolution[0] = constrain(resolution[0], 100, 5120);
            resolution[1] = constrain(resolution[1], 100, 2880);
            printToConsole("--> Window resolution set to: " + java.util.Arrays.toString(resolution));
          } else if (key.equals("windowPosition") && !initialLoadDone) {
            windowPosition = parseIntRange(value);
            windowPosition[0] = constrain(windowPosition[0], 0, 5120);
            windowPosition[1] = constrain(windowPosition[1], 0, 2880);
            printToConsole("--> Window position set to: " + java.util.Arrays.toString(windowPosition));
          } else if (key.equals("fullScreen") && !initialLoadDone) {
            fullScreen = constrain(Integer.parseInt(value), 0, 1);
            printToConsole("--> Full screen set to: " + fullScreen);
          } else if (key.equals("debugBins")) {
            debugBins = constrain(Integer.parseInt(value), 0, 1);
            printToConsole("--> Debug bins set to: " + debugBins);
          } else if (key.equals("debugConsole") && !initialLoadDone) {
            debugConsole = constrain(Integer.parseInt(value), 0, 1);
            printToConsole("--> Debug console set to: " + debugConsole);
          } else if (key.equals("recordVideo") && !initialLoadDone) {
            recordVideo = constrain(Integer.parseInt(value), 0, 1);
            printToConsole("--> Record video set to: " + recordVideo);
          } else if (key.equals("videoQuality") && !initialLoadDone) {
            videoQuality = constrain(Integer.parseInt(value), 0, 100);
            printToConsole("--> Video quality set to: " + videoQuality);
          } else if (key.equals("abortAfterFrames") && !initialLoadDone) {
            abortAfterFrames = constrain(Integer.parseInt(value), 0, 999999);
            printToConsole("--> Abort after frames set to: " + abortAfterFrames);
          } else if (key.equals("randomSeedValue")) {
            randomSeedValue = Integer.parseInt(value);
            printToConsole("--> Random seed value set to: " + randomSeedValue);

            // FLOYD SETTINGS
          } else if (key.equals("floydsRange") && !initialLoadDone) {
            floydsRange = constrainInts(parseIntRange(value), 1, 999);
            printToConsole("--> Floyds range set to: " + java.util.Arrays.toString(floydsRange));
          } else if (key.equals("activateFloydRate")) {
            activateFloydRate = constrain(Float.parseFloat(value), 1, 999);
            printToConsole("--> Activate Floyd rate set to: " + activateFloydRate);
          } else if (key.equals("velocityRange")) {
            velocityRange = constrainFloats(parseRange(value), 0, 999);
            printToConsole("--> Velocity range set to: " + java.util.Arrays.toString(velocityRange));
          } else if (key.equals("angleRandomRange")) {
            angleRandomRange = constrainFloats(parseRange(value), 0, 100);
            printToConsole("--> Angle random range set to: " + java.util.Arrays.toString(angleRandomRange));
          } else if (key.equals("positionDelayFramesRange")) {
            positionDelayFramesRange = constrainInts(parseIntRange(value), 1, 999);
            printToConsole("--> Position delay frames range set to: " + java.util.Arrays.toString(positionDelayFramesRange));
          } else if (key.equals("lineWidthRange")) {
            lineWidthRange = constrainFloats(parseRange(value), 0.1, 100);
            printToConsole("--> Line width range set to: " + java.util.Arrays.toString(lineWidthRange));
          } else if (key.equals("circleSizeRange1")) {
            circleSizeRange1 = constrainFloats(parseRange(value), 0, 999);
            printToConsole("--> Circle size range 1 set to: " + java.util.Arrays.toString(circleSizeRange1));
          } else if (key.equals("circleSizeRange2")) {
            circleSizeRange2 = constrainFloats(parseRange(value), 0, 999);
            printToConsole("--> Circle size range 2 set to: " + java.util.Arrays.toString(circleSizeRange2));

            // MASTER FLOYD SETTINGS
          } else if (key.equals("masterSpeedBoost")) {
            masterSpeedBoost = constrain(Float.parseFloat(value), 0, 100);
            printToConsole("--> Master speed boost set to: " + masterSpeedBoost);
          } else if (key.equals("masterAngleRandomRange")) {
            masterAngleRandomRange = constrainFloats(parseRange(value), 0, 100);
            printToConsole("--> Master angle random range set to: " + java.util.Arrays.toString(masterAngleRandomRange));
          } else if (key.equals("masterProximityBoostRange")) {
            masterProximityBoostRange = constrainFloats(parseRange(value), 0, 100);
            printToConsole("--> Master proximity boost range set to: " + java.util.Arrays.toString(masterProximityBoostRange));
          } else if (key.equals("masterFloydMargin")) {
            masterFloydMargin = constrainFloats(parseRange(value), 0, 0.5);
            printToConsole("--> Master Floyd margin set to: " + java.util.Arrays.toString(masterFloydMargin));
          } else if (key.equals("cohesionRange")) {
            cohesionRange = constrainFloats(parseRange(value), 0, 100);
            printToConsole("--> Cohesion range set to: " + java.util.Arrays.toString(cohesionRange));

            // FREQUENCY BIN SMOOTHING
          } else if (key.equals("movingAverageBinFrames")) {
            movingAverageBinFrames = constrain(Integer.parseInt(value), 1, 999);
            printToConsole("--> Moving average bin frames set to: " + movingAverageBinFrames);
          } else if (key.equals("movingAverageEnvelopeFrames")) {
            movingAverageEnvelopeFrames = constrain(Integer.parseInt(value), 1, 999);
            printToConsole("--> Moving average envelope frames set to: " + movingAverageEnvelopeFrames);

            // VISUALIZATION SETTINGS
          } else if (key.equals("backgroundColor")) {
            backgroundColor = parseRange(value);
            backgroundColor[0] = constrain(backgroundColor[0], 0, 360);
            backgroundColor[1] = constrain(backgroundColor[1], 0, 1);
            backgroundColor[2] = constrain(backgroundColor[2], 0, 2);
            printToConsole("--> Background color set to: " + java.util.Arrays.toString(backgroundColor));
          } else if (key.equals("lineColor")) {
            lineColor = parseRange(value);
            lineColor[0] = constrain(lineColor[0], 0, 360);
            lineColor[1] = constrain(lineColor[1], 0, 1);
            lineColor[2] = constrain(lineColor[2], 0, 2);
            printToConsole("--> Line color set to: " + java.util.Arrays.toString(lineColor));
          } else if (key.equals("circleHue1")) {
            circleHue1 = constrain(Float.parseFloat(value), 0, 360);
            printToConsole("--> Circle hue 1 set to: " + circleHue1);
          } else if (key.equals("circleHue2")) {
            circleHue2 = constrain(Float.parseFloat(value), 0, 360);
            printToConsole("--> Circle hue 2 set to: " + circleHue2);
          } else if (key.equals("hueRotationRate")) {
            hueRotationRate = constrain(Float.parseFloat(value), 0, 100);
            printToConsole("--> Hue rotation rate set to: " + hueRotationRate);
          } else if (key.equals("circleSaturationRange")) {
            circleSaturationRange = constrainFloats(parseRange(value), 0, 1);
            printToConsole("--> Circle saturation range set to: " + java.util.Arrays.toString(circleSaturationRange));
          } else if (key.equals("circleBrightnessRange")) {
            circleBrightnessRange = constrainFloats(parseRange(value), 0, 1);
            printToConsole("--> Brightness range set to: " + java.util.Arrays.toString(circleBrightnessRange));
          } else if (key.equals("fadeOpacityRange")) {
            fadeOpacityRange = constrainFloats(parseRange(value), 0, 255);
            printToConsole("--> Fade opacity range set to: " + java.util.Arrays.toString(fadeOpacityRange));

            // DIRECTION AND MOVEMENT BIAS
          } else if (key.equals("switchDirectionChanceRange")) {
            switchDirectionChanceRange = constrainFloats(parseRange(value), 0, 999);
            printToConsole("--> Switch direction chance range set to: " + java.util.Arrays.toString(switchDirectionChanceRange));
          } else if (key.equals("switchDiscreteChanceRange")) {
            switchDiscreteChanceRange = constrainFloats(parseRange(value), 0, 999);
            printToConsole("--> Switch discrete chance range set to: " + java.util.Arrays.toString(switchDiscreteChanceRange));
          } else if (key.equals("angularBiasFactor")) {
            angularBiasFactor = constrain(Float.parseFloat(value), 0, 100);
            printToConsole("--> Angular bias factor set to: " + angularBiasFactor);
          } else if (key.equals("directionBiasOptions")) {
            directionBiasOptions = constrainFloats(expandShorthand(value), -100, 100);
            printToConsole("--> Overwritten " + key + " with: " + java.util.Arrays.toString(directionBiasOptions));
          } else if (key.equals("discreteBiasOptions")) {
            discreteBiasOptions = constrainFloats(expandShorthand(value), 0, 999);
            printToConsole("--> Overwritten " + key + " with: " + java.util.Arrays.toString(discreteBiasOptions));

            // FFT AND FONT SETTINGS
          } else if (key.equals("fftBands") && !initialLoadDone) {
            fftBands = nextPowerOfTwo(Integer.parseInt(value));
            printToConsole("--> FFT bands set to: " + fftBands);
          } else if (key.equals("monoFont")) {
            String[] fontParts = value.split(",");
            String fontType = fontParts[0].trim();
            if (videoQuality == 42 || randomSeedValue == 42 || frameRate == 42 || movingAverageEnvelopeFrames == 42) { // osterei
              fontType = "Caidoz.ttf";
            }
            int fontSize = constrain(Integer.parseInt(fontParts[1].trim()), 1, 72);
            Boolean boldFont = Boolean.parseBoolean(fontParts[2].trim());
            monoFont = parent.createFont(fontType, fontSize, boldFont);
            textFont(monoFont);
            printToConsole("--> Mono font set to: " + fontParts[0].trim() + ", size: "
              + constrain(Integer.parseInt(fontParts[1].trim()), 1, 72) + ", bold: " + fontParts[2].trim());

            // PARAMETER MATRIX
          } else if (key.startsWith("param")) {
            float[] mapping = constrainFloats(parseMapping(value), -10, 10);
            parameterMappings.put(key, mapping);
            printToConsole("--> Overwritten " + key + " with: " + java.util.Arrays.toString(mapping));
          }
        }
        catch (NumberFormatException e) {
          printToConsole("!!! Invalid format for key '" + key + "'. Using default value.");
        }
      }

      // After loading all parameters, mark the initial load as done to prevent reloading of fundamental parameters
      initialLoadDone = true;
    }
    catch (IOException e) {
      printToConsole("Error loading INI file. Using default parameters: " + e.getMessage());
    }
  }

  void calculateParams(float[] bins) {
    for (int i = 0; i < params.length; i++) {
      params[i] = 0; // Reset current param
      float[] mapping = parameterMappings.get("param" + i);
      for (int j = 0; j < mapping.length; j++) {
        params[i] += mapping[j] * bins[j];
      }
      // Constrain the final parameter to the range [0, 1]
      params[i] = constrain(params[i], 0, 1);
    }
  }
}
