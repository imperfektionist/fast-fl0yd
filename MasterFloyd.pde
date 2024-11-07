class MasterFloyd {
  PVector currentPos;
  PVector previousPos;
  float angle;
  float velocity;
  float angleRandomness;
  Config config;

  MasterFloyd(Config config) {
    this.config = config;
    float startX = random(config.parent.width * config.masterFloydMargin[0], config.parent.width * (1 - config.masterFloydMargin[0]));
    float startY = random(config.parent.height * config.masterFloydMargin[1], config.parent.height * (1 - config.masterFloydMargin[1]));
    currentPos = new PVector(startX, startY);
    previousPos = currentPos.copy();
    angle = random(TWO_PI);
    angleRandomness = 0;
    velocity = config.velocityRange[0]; // Initial velocity
  }

  void update(float[] params, Config config) {
    // Map velocity based on params
    velocity = map(params[0], 0, 1, config.velocityRange[0], config.velocityRange[1]) * config.masterSpeedBoost;

    // Calculate movement
    previousPos.set(currentPos);
    angleRandomness = map(params[6], 0, 1, config.masterAngleRandomRange[0], config.masterAngleRandomRange[1]);
    angle += angleRandomness;
    currentPos.x += cos(angle) * velocity;
    currentPos.y += sin(angle) * velocity;

    // Define inner boundaries with padding on each side
    float leftBoundary = config.parent.width * config.masterFloydMargin[0];
    float rightBoundary = config.parent.width * (1 - config.masterFloydMargin[0]);
    float topBoundary = config.parent.height * config.masterFloydMargin[1];
    float bottomBoundary = config.parent.height * (1 - config.masterFloydMargin[1]);

    // Check and bounce off boundaries
    if (currentPos.x <= leftBoundary || currentPos.x >= rightBoundary) {
      angle = PI - angle; // Reverse horizontal direction
      currentPos.x = constrain(currentPos.x, leftBoundary, rightBoundary);
    }
    if (currentPos.y <= topBoundary || currentPos.y >= bottomBoundary) {
      angle = -angle; // Reverse vertical direction
      currentPos.y = constrain(currentPos.y, topBoundary, bottomBoundary);
    }
  }
}
