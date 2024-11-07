import java.io.File;
import javax.swing.*;
import java.awt.*; // Import AWT classes for Font
PFont monoFont;
JFrame consoleFrame; // Declare as global for console frame
JTextArea consoleArea; // Declare as global for console text area

void createConsole() {
  consoleFrame = new JFrame("Debug Console");

  // Create the JTextArea with a specified height and width
  consoleArea = new JTextArea(40, 80); // 20 rows, 50 columns
  consoleArea.setEditable(false);

  // Set the background color to black and text color to white
  consoleArea.setBackground(Color.BLACK);
  consoleArea.setForeground(Color.WHITE);

  // Optionally, set a monospace font for the console
  consoleArea.setFont(new Font("Courier", Font.PLAIN, 14)); // Adjust size as needed

  // Add the JTextArea to a JScrollPane for scrolling
  JScrollPane scrollPane = new JScrollPane(consoleArea);
  consoleFrame.add(scrollPane);

  consoleFrame.pack();

  // Get screen dimensions
  Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();

  // Calculate the position to place the console in the upper right corner
  int x = screenSize.width - consoleFrame.getWidth(); // Right edge
  int y = 100; // Top edge

  // Set the location of the console window
  consoleFrame.setLocation(x, y);

  consoleFrame.setVisible(true);
  consoleFrame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
}

void printToConsole(String message) {
  // Print to the Processing console (IDE)
  System.out.println(message);

  // Append the message to the JTextArea in the Swing console
  if (consoleArea != null) {
    consoleArea.append(message + "\n");
  } else {
    System.err.println("Console area is not initialized.");
  }
}

void closeConsole() {
  if (consoleFrame != null) {
    consoleFrame.setVisible(false); // Hide the frame
    consoleFrame.dispose(); // Release resources
    consoleFrame = null; // Clear the reference
  }
}

void updateWaitBar(float progress) {
  // Constrain the progress value to the range [0, 1]
  progress = constrain(progress, 0, 1);

  // Create the wait bar string
  int totalBars = 50; // Total length of the wait bar
  int filledBars = (int) (progress * totalBars); // Calculate filled bars
  StringBuilder waitBar = new StringBuilder("["); // Start of the wait bar

  // Append filled and unfilled parts
  for (int i = 0; i < totalBars; i++) {
    if (i < filledBars) {
      waitBar.append("="); // Filled part
    } else {
      waitBar.append(" "); // Unfilled part
    }
  }

  waitBar.append("] " + nf(progress * 100, 0, 2) + "%"); // Append percentage

  // Move the cursor to the beginning of the line
  System.out.print("\r" + waitBar.toString()); // Update the same line
  System.out.flush(); // Ensure the output is shown immediately
}


String getCurrentDateTime() {
  // Format the current date and time as a string
  java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
  return sdf.format(new java.util.Date());
}

void changeConsoleFont(PFont pFont) {
  // Convert PFont to AWT Font
  Font awtFont = convertPFontToAWTFont(pFont);
  consoleArea.setFont(awtFont); // Set the new font to the console area
}

Font convertPFontToAWTFont(PFont pFont) {
  String fontName = pFont.getName(); // Get the font name
  int fontSize = pFont.getSize(); // Get the font size

  // Create and return a new AWT Font
  return new Font(fontName, Font.PLAIN, fontSize);
}

void debugBins(float[] params, float[] smoothedBins, Config config, int floydCount, float currentDirectionBias, float currentDiscreteBias) {
  int numBars = params.length;
  int barWidth = 20;
  int graphHeight = 160; // Adjusted height for space within the box
  int xOffset = 10;
  int yOffset = (config.parent.height - graphHeight) / 2;

  // Draw background rectangle for the graph
  config.parent.fill(255, 200);
  config.parent.noStroke();
  config.parent.rect(xOffset - 5, yOffset - 10, barWidth * numBars + 10, graphHeight + 60); // Adjusted height for text space

  // Adjusted grid lines at 0 and 1 to provide extra space for the text within the box
  float zeroLineY = yOffset + graphHeight - 10;
  float oneLineY = yOffset;

  config.parent.stroke(150);
  config.parent.strokeWeight(1);
  config.parent.line(xOffset - 5, zeroLineY, xOffset + barWidth * numBars + 5, zeroLineY);
  config.parent.line(xOffset - 5, oneLineY, xOffset + barWidth * numBars + 5, oneLineY);

  // Draw params bars
  config.parent.fill(120, 1, 1); // Green bar color (HSI)
  for (int i = 0; i < numBars; i++) {
    float param = constrain(params[i], 0, 1); // Constrain each param
    float barHeight = map(param, 0, 1, 0, graphHeight);
    float barYPos = zeroLineY - barHeight;
    config.parent.rect(xOffset + i * barWidth, barYPos, barWidth - 4, barHeight);
  }

  // Draw smoothedBins as a black line graph with filled black circles at each node
  config.parent.stroke(0); // Black color for line graph
  config.parent.strokeWeight(2);
  config.parent.noFill();
  config.parent.beginShape();
  for (int i = 0; i < smoothedBins.length; i++) {
    float binValue = constrain(smoothedBins[i], 0, 1); // Constrain each smoothed bin between 0 and 1
    float y = map(binValue, 0, 1, zeroLineY, oneLineY); // Map bin values to graph height
    float x = xOffset + i * barWidth + barWidth / 2; // Center each point in its bar
    config.parent.vertex(x, y);
  }
  config.parent.endShape();

  // Draw black filled circles at each node
  for (int i = 0; i < smoothedBins.length; i++) {
    float binValue = constrain(smoothedBins[i], 0, 1);
    float y = map(binValue, 0, 1, zeroLineY, oneLineY);
    float x = xOffset + i * barWidth + barWidth / 2;
    config.parent.noStroke();
    config.parent.fill(0); // Black fill for circles
    config.parent.ellipse(x, y, 5, 5); // Filled circle at each node
  }

  // Display additional information within the box
  config.parent.fill(0);
  config.parent.textAlign(LEFT, TOP);
  config.parent.text("FPS: " + round(frameRate), xOffset, oneLineY + 10);
  config.parent.text("Num floyds: " + floydCount, xOffset, zeroLineY + 10);
  config.parent.text("Direx bias: " + nf(currentDirectionBias, 1, 1), xOffset, zeroLineY + 25);
  config.parent.text("Discretize: " + (int) currentDiscreteBias, xOffset, zeroLineY + 40);
}

void displayTimeline(AudioProcessor audioProcessor, Config config) {
  if (config.recordVideo <= 0 && mouseY > height * 0.90) {
    float duration = audioProcessor.soundFile.duration();
    float currentTime = audioProcessor.soundFile.position();
    float progress = map(currentTime, 0, duration, 0, width);
    float margin = 100;

    // Draw timeline
    stroke(0);
    strokeWeight(1);
    line(0, height - margin, width, height - margin); // Thin black line

    // Draw position marker
    fill(0, 0, 255);
    stroke(0);
    ellipse(progress, height - margin, 10, 10); // Gray circle with black stroke

    // Adjust time if mouse is clicked
    if (mousePressed) {
      float clickedTime = map(mouseX, 0, width, 0, duration);
      audioProcessor.soundFile.jump(clickedTime); // Set new position in audio file
    }
  }
}

// Parse a comma-separated range string for floats (e.g., "0.2, 1")
float[] parseRange(String input) {
  String[] tokens = input.split(",");
  float[] range = new float[tokens.length];
  for (int i = 0; i < tokens.length; i++) {
    range[i] = Float.parseFloat(tokens[i].trim());
  }
  return range;
}

// Parse a comma-separated range string for integers (e.g., "1, 5")
int[] parseIntRange(String input) {
  String[] tokens = input.split(",");
  int[] range = new int[tokens.length];
  for (int i = 0; i < tokens.length; i++) {
    range[i] = Integer.parseInt(tokens[i].trim());
  }
  return range;
}

float[] expandShorthand(String input) {
  String[] tokens = input.split(",");
  ArrayList<Float> values = new ArrayList<>();

  for (String token : tokens) {
    token = token.trim();

    // Check for shorthand notation
    if (token.contains("*")) {
      String[] parts = token.split("\\*");
      int count = Integer.parseInt(parts[0].trim());
      float value = Float.parseFloat(parts[1].trim());

      for (int i = 0; i < count; i++) {
        values.add(value); // Add the value count times
      }
    } else {
      values.add(Float.parseFloat(token)); // Add the regular value
    }
  }

  // Convert ArrayList to float[]
  float[] result = new float[values.size()];
  for (int i = 0; i < values.size(); i++) {
    result[i] = values.get(i);
  }

  return result;
}

float[] parseMapping(String input) {
  String[] tokens = input.split(",");
  float[] mapping = new float[tokens.length];
  for (int i = 0; i < tokens.length; i++) {
    mapping[i] = Float.parseFloat(tokens[i].trim());
  }
  return mapping;
}

int nextPowerOfTwo(int n) {
  // Constrain n to be within the range [1, 2048]
  n = constrain(n, 1, 2048);

  // Check if n is a power of 2
  if ((n & (n - 1)) == 0) {
    return n; // n is a power of 2
  } else {
    // Calculate the next power of 2
    int power = 1;
    while (power < n) {
      power *= 2;
    }
    return power; // Return the next higher power of 2
  }
}

float[] constrainFloats(float[] array, float min, float max) {
  for (int i = 0; i < array.length; i++) {
    array[i] = constrain(array[i], min, max); // Constrain each value in the array
  }
  return array; // Return the modified array
}

int[] constrainInts(int[] array, int min, int max) {
  for (int i = 0; i < array.length; i++) {
    array[i] = constrain(array[i], min, max); // Constrain each value in the array
  }
  return array; // Return the modified array
}

static String ossify(String inPath) {
  // Replace all forward slashes with the system's file separator
  return inPath.replace("/", File.separator);
}
