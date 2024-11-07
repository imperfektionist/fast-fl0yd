import processing.sound.*;
import java.util.LinkedList;

class AudioProcessor {
  Config config;
  FFT fft;                 // FFT object for sound analysis
  SoundFile soundFile;     // Sound file for audio playback
  float[] fftBins;         // Holds the original FFT bins
  float[] smoothedBins;    // Holds the smoothed FFT data for visualization
  LinkedList<float[]> frameBuffer; // Buffer to store recent frames for averaging

  AudioProcessor(Config config) {
    this.config = config;
    fftBins = new float[config.fftBands];
    smoothedBins = new float[8]; // Reduced bins for visualization
    frameBuffer = new LinkedList<float[]>();

    // Initialize SoundFile and FFT
    printToConsole("Using audio file: " + config.audioFile);
    soundFile = new SoundFile(config.parent, config.audioFile);
    fft = new FFT(config.parent, config.fftBands);
    fft.input(soundFile);
  }

  // Method to start playback
  void play() {
    if (!soundFile.isPlaying()) {
      soundFile.loop();
    }
  }

  // Method to retrieve and process the FFT data
  void processAudio() {
    fft.analyze(fftBins);  // Perform FFT analysis on the sound
    calculateOctaveBins(); // Calculate octave-based bins
    applyMovingAverage();  // Apply the moving average
  }

  // Calculate octave bins from FFT data and add to the frame buffer
  void calculateOctaveBins() {
    float[] bins = new float[8]; // Temporarily store this frame's bins

    // Reset bins for this frame
    for (int i = 0; i < bins.length; i++) {
      bins[i] = 0;
    }

    // Adjust the aggregation to evenly distribute higher frequencies
    for (int i = 0; i < config.fftBands && i < 128; i++) {
      int octave = (int)(log(i + 1) / log(2)); // Calculate octave based on log scale
      if (octave < bins.length) {
        bins[octave] += fftBins[i];
      }
    }

    // Apply volume factor for quiet songs
    for (int i = 0; i < bins.length; i++) {
      bins[i] *= config.volumeFactor;
    }

    // Add this frame's bins to the frame buffer
    frameBuffer.add(bins);

    // Maintain buffer size according to the averaging range
    int maxBufferSize = config.movingAverageBinFrames * 2 + 1;
    if (frameBuffer.size() > maxBufferSize) {
      frameBuffer.removeFirst();
    }
  }

  void applyMovingAverage() {
    // Initialize smoothedBins to zero before averaging
    for (int i = 0; i < smoothedBins.length; i++) {
      smoothedBins[i] = 0;
    }

    // Calculate the range of frames available for averaging
    int framesToAverage = config.movingAverageBinFrames;
    int bufferSize = frameBuffer.size();

    // Adjust framesToConsider based on the available frames in the buffer
    int framesToConsider = Math.min(framesToAverage, bufferSize - 1);

    // Sum values within the available range around the current frame
    for (int i = -framesToConsider; i <= framesToConsider; i++) {
      int index = bufferSize - 1 + i; // Adjust index relative to the buffer end

      // Ensure the index is within bounds
      if (index >= 0 && index < bufferSize) {
        float[] frameBins = frameBuffer.get(index);
        for (int j = 0; j < smoothedBins.length; j++) {
          smoothedBins[j] += frameBins[j];
        }
      }
    }

    // Normalize the smoothed bins by dividing by the actual number of frames considered
    int totalFrames = framesToConsider * 2 + 1;
    for (int j = 0; j < smoothedBins.length; j++) {
      smoothedBins[j] = constrain(smoothedBins[j] / totalFrames, 0, 1);
    }
  }

  // Return the smoothed bins for visualization
  float[] getBins() {
    return smoothedBins;
  }
}
