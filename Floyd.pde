class Floyd {
  PVector currentPos;
  PVector previousPos;
  float angle;
  float velocity;
  float angleRandomness;
  float sizeCircle1;
  float sizeCircle2;
  float lineWidth;
  int positionDelayFrames;
  Config config;
  boolean active;
  ArrayList<PVector> positionBuffer;

  Floyd(Config config) {
    this.config = config;
    float startX = config.parent.width / 2;
    float startY = config.parent.height / 2;
    currentPos = new PVector(startX, startY);
    previousPos = new PVector(startX, startY);
    angle = random(TWO_PI);
    positionBuffer = new ArrayList<PVector>();
    for (int i = 0; i < config.positionDelayFramesRange[0]; i++) {
      positionBuffer.add(new PVector(startX, startY));
    }
    active = false; // Initialize Floyd as inactive
  }

  void activate(Floyd sourceFloyd) {
    this.currentPos.set(sourceFloyd.currentPos);
    this.previousPos.set(sourceFloyd.previousPos);
    this.angle = sourceFloyd.angle + 0;
    this.active = true;

    // Deep copy the positionBuffer
    this.positionBuffer.clear();
    for (PVector pos : sourceFloyd.positionBuffer) {
      this.positionBuffer.add(pos.copy());
    }
  }

  void deactivate() {
    this.active = false;
  }

  void update(float[] params, Config config, MasterFloyd masterFloyd) {
    if (!active) return; // Ignore inactive Floyds

    // Calculate the distance between this Floyd and the Master Floyd
    float dx = 2 * abs(masterFloyd.currentPos.x - currentPos.x) / config.parent.width;
    float dy = 2 * abs(masterFloyd.currentPos.y - currentPos.y) / config.parent.height;

    // Calculate masterProximityBoost based on Manhattan norm (more performant)
    float masterProximityBoost = max(config.masterProximityBoostRange[0], config.masterProximityBoostRange[1] * (1 - dx - dy));

    // Map parameters to visualization variables and apply Master Floyd proximity boost
    velocity = map(params[0], 0, 1, config.velocityRange[0], config.velocityRange[1]) * masterProximityBoost;
    angleRandomness = map(params[1], 0, 1, config.angleRandomRange[0], config.angleRandomRange[1]) * masterProximityBoost;
    positionDelayFrames = (int) (map(params[2], 0, 1, config.positionDelayFramesRange[0], config.positionDelayFramesRange[1]));
    lineWidth = map(params[3], 0, 1, config.lineWidthRange[0], config.lineWidthRange[1]);
    sizeCircle1 = map(params[4], 0, 1, config.circleSizeRange1[0], config.circleSizeRange1[1]) * masterProximityBoost;
    sizeCircle2 = map(params[5], 0, 1, config.circleSizeRange2[0], config.circleSizeRange2[1]) * masterProximityBoost;

    // Rest of update logic
    float rawCohesion = constrain(params[8], 0, 1);
    float cohesion = map(rawCohesion, 0, 1, config.cohesionRange[0], config.cohesionRange[1]);

    PVector randomDirection = new PVector(cos(angle), sin(angle)).mult(velocity);
    PVector masterDirection = PVector.sub(masterFloyd.currentPos, currentPos).normalize().mult(velocity);
    PVector finalDirection = PVector.lerp(randomDirection, masterDirection, cohesion);

    angle += random(-angleRandomness, angleRandomness);
    currentPos.add(finalDirection);

    // Bounce off outer walls
    if (currentPos.x < 0 || currentPos.x > config.parent.width) {
      angle = PI - angle;
      currentPos.x = constrain(currentPos.x, 0, config.parent.width);
    }
    if (currentPos.y < 0 || currentPos.y > config.parent.height) {
      angle = -angle;
      currentPos.y = constrain(currentPos.y, 0, config.parent.height);
    }

    positionBuffer.add(currentPos.copy());
    while (positionBuffer.size() > positionDelayFrames) {
      previousPos = positionBuffer.remove(0);
    }
  }

  // Draw Floyd
  void display(float hueOffset) {
    if (!active) return; // Ignore inactive Floyd

    config.parent.stroke(config.lineColor[0], config.lineColor[1], config.lineColor[2]);
    config.parent.strokeWeight(lineWidth);
    config.parent.line(previousPos.x, previousPos.y, currentPos.x, currentPos.y);

    float saturation1 = random(config.circleSaturationRange[0], config.circleSaturationRange[1]);
    float brightness1 = random(config.circleBrightnessRange[0], config.circleBrightnessRange[1]);
    config.parent.fill((config.circleHue1 + hueOffset) % 360, saturation1, brightness1);
    config.parent.ellipse(previousPos.x, previousPos.y, sizeCircle1, sizeCircle1);

    float saturation2 = random(config.circleSaturationRange[0], config.circleSaturationRange[1]);
    float brightness2 = random(config.circleBrightnessRange[0], config.circleBrightnessRange[1]);
    config.parent.fill((config.circleHue2 + hueOffset) % 360, saturation2, brightness2);
    config.parent.ellipse(currentPos.x, currentPos.y, sizeCircle2, sizeCircle2);
  }
}
