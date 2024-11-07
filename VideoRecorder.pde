import com.hamoid.*;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.io.File;

class VideoRecorder {
  Config config;
  VideoExport videoExport;
  WaitBar waitBar;

  VideoRecorder(Config config) {
    this.config = config;

    if (config.recordVideo > 0) {
      try {
        waitBar = new WaitBar();

        String audioFileName = config.audioFile;
        String baseFileName = audioFileName.substring(audioFileName.lastIndexOf(File.separator) + 1, audioFileName.lastIndexOf("."));

        // Get date and time stamp for the file name
        String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String videoFileName = config.videoPath + baseFileName + "_" + timeStamp + ".mp4";
        printToConsole("Video file will be saved at: " + videoFileName);

        // Initialize VideoExport with settings
        videoExport = new VideoExport(config.parent, videoFileName);
        videoExport.setFfmpegPath(config.ffmpegPath);
        int crf = (int) map(config.videoQuality, 0, 100, 48, 1);
        printToConsole("Constant rate factor (CRF): " + crf);

        String[] ffmpegVideoSettings = {
          "[ffmpeg]", // ffmpeg executable
          "-y", // Overwrite old files without asking
          "-f", "rawvideo", // Input format
          "-vcodec", "rawvideo", // Input codec
          "-s", width + "x" + height, // Current resolution
          "-pix_fmt", "rgb24", // Input pixel format
          "-r", String.valueOf(frameRate), // Current frame rate
          "-i", "-", // Pipe input for raw video
          "-vcodec", "h264", // Output codec
          "-pix_fmt", "yuv420p", // Output pixel format
          "-preset", "slow", // Use slower preset for better quality
          "-crf", String.valueOf(crf), // Lower CRF for better quality (18-23 is a decent range)
          "-metadata", "comment=Generated with FAST FL0YD", // comment
          "[output]" // Placeholder for output file path
        };

        videoExport.setFfmpegVideoSettings(ffmpegVideoSettings); // Pass the settings as a single array

        // Set audio settings to default
        String[] ffmpegAudioSettings = {
          "[ffmpeg]", // ffmpeg executable
          "-y", // overwrite old file
          "-i", "[inputvideo]", // video file path
          "-i", "[inputaudio]", // audio file path
          "-filter_complex", "[1:0]apad", // pad with silence
          "-shortest", // match shortest file
          "-vcodec", "copy", // don't reencode vid
          "-acodec", "aac", // aac audio encoding
          "-b:a", "192k", // bit rate (quality)
          "-metadata", "comment=Generated with FAST FL0YD", // comment
          "-strict", "-2", // enable aac
          "[output]" // output file
        };

        videoExport.setFfmpegAudioSettings(ffmpegAudioSettings);
        videoExport.setAudioFileName(audioFileName);  // would require absolute path in ffmpegAudioSettings

        videoExport.startMovie();

        printToConsole("Start video recording: " + videoFileName);
      }
      catch (Exception e) {
        printToConsole("Error initializing video recording: " + e.getMessage());
      }
    }
  }

  void saveFrame(int currentFrame, int totalFrames) {
    if (config.recordVideo > 0) {
      try {
        // Update the wait bar before saving the frame
        int progress = (int) ((float) currentFrame / totalFrames * 100); // Calculate progress
        waitBar.updateProgress(progress);

        videoExport.saveFrame();
      }
      catch (Exception e) {
        printToConsole("Error while saving video frame: " + e.getMessage());
      }
    }
  }

  void finishRecording() {
    if (config.recordVideo > 0) {
      videoExport.endMovie();
      printToConsole("Finished video recording.");
    }
  }
}
