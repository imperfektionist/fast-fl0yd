import javax.swing.*;
import java.awt.*;

class WaitBar {
    private JFrame frame;
    private JProgressBar progressBar;

    WaitBar() {
        // Create a new frame for the wait bar
        frame = new JFrame("Exporting Video...");
        progressBar = new JProgressBar(0, 100);
        progressBar.setStringPainted(true); // Show percentage text
        progressBar.setValue(0); // Initial value

        // Set layout and add the progress bar to the frame
        frame.setLayout(new BorderLayout());
        frame.add(progressBar, BorderLayout.CENTER);
        
        frame.setSize(400, 100); // Set size of the frame
        frame.setLocationRelativeTo(null); // Center the frame on the screen
        frame.setDefaultCloseOperation(JFrame.DO_NOTHING_ON_CLOSE);
        frame.setVisible(true); // Show the frame
    }

    void updateProgress(int value) {
        progressBar.setValue(value); // Update the progress value
        progressBar.setString(value + "%"); // Update the string
    }

    void close() {
        frame.dispose(); // Close the frame
    }
}
