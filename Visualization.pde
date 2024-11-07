import java.util.Arrays;

class Visualization {
  Config config;
  Floyd[] floyds;
  MasterFloyd masterFloyd;
  float hueOffset = 0;
  float currentDirectionBias = 0;
  float currentDiscreteBias = 0;

  // Frame counters to control direction and discrete bias switches
  int nextDirectionSwitchFrame = 0;
  int nextDiscreteSwitchFrame = 0;
  int frameCounter = 0; // For Floyd activation

  Visualization(Config config) {
    this.config = config;
    floyds = new Floyd[config.floydsRange[1]];

    // Initialize all Floyds as inactive
    for (int i = 0; i < floyds.length; i++) {
      floyds[i] = new Floyd(config);
    }

    masterFloyd = new MasterFloyd(config);

    // Initialize switch intervals based on frame count
    scheduleNextDirectionSwitch();
    scheduleNextDiscreteSwitch();
  }

  void update(float[] bins) {
    config.calculateParams(bins);
    float[] params = config.params;
    frameCounter++;

    // Adjust Floyd count based on frame counter
    if (frameCounter >= config.activateFloydRate) {
      adjustFloydCount(bins);
      frameCounter = 0; // Reset frame counter after adjustment
    }

    masterFloyd.update(params, config);
    hueOffset = (hueOffset + config.hueRotationRate) % 360;

    // Check if it's time to switch direction bias
    if (frameCount >= nextDirectionSwitchFrame) {
      int randomIndex = (int) random(config.directionBiasOptions.length); // Get a random index
      currentDirectionBias = config.directionBiasOptions[randomIndex];
      scheduleNextDirectionSwitch();
    }

    // Check if it's time to switch discrete bias
    if (frameCount >= nextDiscreteSwitchFrame) {
      int randomIndex = (int) random(config.discreteBiasOptions.length); // Get a random index
      currentDiscreteBias = config.discreteBiasOptions[randomIndex];
      scheduleNextDiscreteSwitch();
    }

    for (Floyd floyd : floyds) {
      if (floyd.active) {
        applyDirectionBias(floyd);
        floyd.update(params, config, masterFloyd);
        floyd.display(hueOffset);
      }
    }
  }

  int getCurrentFloydCount() {
    int count = 0;
    for (Floyd floyd : floyds) {
      if (floyd.active) count++;
    }
    return count;
  }

  void adjustFloydCount(float[] bins) {
    float envelope = 0;
    for (float bin : bins) envelope += bin;
    envelope = constrain(envelope, 0, 1);

    // Apply moving average to envelope
    envelope = applyEnvelopeMovingAverage(envelope);

    int targetFloyds = (int) map(envelope, 0, 1, config.floydsRange[0], config.floydsRange[1]);
    int currentFloydCount = getCurrentFloydCount();

    if (currentFloydCount < targetFloyds) {
      activateRandomFloyd();
    } else if (currentFloydCount > targetFloyds) {
      deactivateRandomFloyd();
    }
  }

  // Moving average for the envelope
  float applyEnvelopeMovingAverage(float currentEnvelope) {
    int framesToAverage = config.movingAverageEnvelopeFrames;
    float averagedEnvelope = 0;

    for (int i = 0; i < framesToAverage; i++) {
      averagedEnvelope += currentEnvelope;
    }
    return averagedEnvelope / framesToAverage;
  }

  void activateRandomFloyd() {
    Floyd sourceFloyd = findRandomActiveFloyd();
    Floyd floydToActivate = findRandomInactiveFloyd();

    // Activate first Floyd without needing a source
    if (sourceFloyd == null) {
      floydToActivate.active = true;
    } else if (floydToActivate != null) {
      floydToActivate.activate(sourceFloyd);
    }
  }

  void deactivateRandomFloyd() {
    Floyd floydToDeactivate = findRandomActiveFloyd();
    if (floydToDeactivate != null) {
      floydToDeactivate.deactivate();
    }
  }

  Floyd findRandomActiveFloyd() {
    int count = getCurrentFloydCount();
    if (count == 0) return null;

    int startIndex = (int) random(count);
    for (int i = 0; i < floyds.length; i++) {
      int index = (startIndex + i) % floyds.length;
      if (floyds[index].active) return floyds[index];
    }
    return null;
  }

  Floyd findRandomInactiveFloyd() {
    int count = getCurrentFloydCount();
    if (count == floyds.length) return null;

    int startIndex = (int) random(floyds.length - count);
    for (int i = 0; i < floyds.length; i++) {
      int index = (startIndex + i) % floyds.length;
      if (!floyds[index].active) return floyds[index];
    }
    return null;
  }

  void applyDirectionBias(Floyd floyd) {
    float biasAdjustment = random(config.angularBiasFactor);
    floyd.angle += biasAdjustment * currentDirectionBias;

    if (currentDiscreteBias != 0) {
      int numDirections = (int) currentDiscreteBias;
      float angleIncrement = 360.0 / numDirections;

      float currentAngleDegrees = degrees(floyd.angle) % 360;
      float nearestDiscreteAngle = round(currentAngleDegrees / angleIncrement) * angleIncrement;

      floyd.angle = radians(nearestDiscreteAngle);
    }
  }

  void scheduleNextDirectionSwitch() {
    float intervalFrames = random(config.switchDirectionChanceRange[0], config.switchDirectionChanceRange[1]) * config.frameRate;
    nextDirectionSwitchFrame = frameCount + (int) intervalFrames;
  }

  void scheduleNextDiscreteSwitch() {
    float intervalFrames = random(config.switchDiscreteChanceRange[0], config.switchDiscreteChanceRange[1]) * config.frameRate;
    nextDiscreteSwitchFrame = frameCount + (int) intervalFrames;
  }

  ArrayList<Floyd> getFloyds() {
    return new ArrayList<Floyd>(Arrays.asList(floyds));
  }

  float getCurrentDirectionBias() { // For debug bins
    return currentDirectionBias;
  }

  float getCurrentDiscreteBias() { // For debug bins
    return currentDiscreteBias;
  }
}
