# FAST FL0YD Visualizer - README
November 4th, 2024 - Anton Hoyer



## Overview

The FAST FL0YD Visualizer is an interactive audio visualization tool created using the Processing coding language. It processes audio files and generates dynamic visual patterns, allowing you to experience sound in a new dimension. The visualizer leverages the power of FFmpeg for video processing, allowing you to export high-quality visual animations to create low-effort music videos.



## Features

- **Audio Analysis**: The visualizer uses FFT (Fast Fourier Transform) to analyze audio data in real-time, translating sound frequencies into visual elements.

- **Customizable Parameters**: You can adjust various settings for a personalized experience by editing `data/PARAMETERS.ini`. Most parameters can be changed during runtime by saving the INI file.

- **Video Export**: Capture your visualizations in video format, powered by FFmpeg, enabling high-quality video output for sharing and archiving (MP4 with h264 codec).



## Installation

**IMPORTANT**: If you are using the standalone executable `Main.exe` (Windows) or `Main` (Linux), you may skip steps 1. and 2.

1. **Download Processing**: Ensure you have the latest version of the Processing IDE from [https://processing.org/download/]. The latest version tested with the visualizer was Processing 4.3.

2. **Install Required Libraries**: Install the packages `Sound` by The Processing Foundation and `Video Export` by Abe Pazos. This can be done by simply opening Processing -> Sketch -> Import Library... -> Manage Libraries -> Install.

3. **Install FFmpeg**: In case you want to use the video export functionality, download and install FFmpeg from [https://ffmpeg.org/download.html]. If you are a dummy, refer to [https://phoenixnap.com/kb/ffmpeg-windows]. Adding FFmpeg to your system's PATH is not required, but you do need to specify its path by adjusting the variable `ffmpegPath` in `data/PARAMETERS.ini` (see step 4.).

4. **Set Up Parameters**: Modify the `data/PARAMETERS.ini` file to configure your audio file path, output video settings, and other preferences. The parameters are commented, but in absence of a detailed documentation, you may simply change them and watch what happens. It is pretty difficult to brick the program as most variables are constrained and set to default if something goes wrong. When it does, you most likely need to correct one of the three path variables `audioFile`, `ffmpegPath`, and `videoPath`. In case you trash `data/PARAMETERS.ini`, just copy the contents from `data/DEFAULT_PARAMETERS.ini`, which is read-only.

5. **Run FAST FL0YD Visualizer**: Execute the program or run it from the Processing IDE. You can edit and save `data/PARAMETERS.ini` while the program is running, it will check for changes every second.



## Noteworthy Features

- **Dynamic Adjustments**: The visualizer can be customized on-the-fly. Modify the parameters during execution to see immediate effects on the visualization. Some general parameters, marked by [§], cannot be changed during runtime.

- **Floyds**: The visualization particles each consist of two circles connected by one line, effectively making them tiny dumbbells. The current position (circle 2) is moved by `velocity` each frame using polar coordinates. Therefore, the Floyds also have an `angle` to which an `angleRandom` is added every frame. The previous position (circle 1) may lie several frames back, the number of which is determined by `positionDelayFrames`.

- **Master Floyd**: If the cohesion is high enough, the Floyds stray from their current random path and start following the Master Floyd. This one is not only invisible but also independent. It also is limited to a smaller box inside the visualization window to avoid cluttering of Floyds at the window boundaries.

- **Parameter Ranges**: Many parameters, such as `floydsRange` and `velocityRange`, allow you to define min-max ranges for greater flexibility in visual behavior.

- **Direction Bias**: Every few seconds, the program draws randomly from `directionBiasOptions`, the outcome of which is added to the `angle`. Positive numbers lead to counter-clockwise rotations, negative numbers to clockwise rotations, and 0 adds no rotation. Analogously, a discrete bias can be drawn from `discreteBiasOptions`, which allows only a specific number of directions or angles to move by (0 allows all directions).

- **Custom Mappings**: The mappings between the FFT bins and the visual parameters (`param0` to `param8`) can be specified in a custom matrix. The columns are the octaves from low to high, while the rows are the effects on `velocity`, `angleRandom`, `positionDelayFrames`, `lineWidth`, `circleSize1`, `circleSize2`, `masterAngleRandom`, `fadeOpacity`, and `cohesion`. Every song is different, so get creative with the mappings.

- **Debugging Options**: Enable debugging features in `PARAMETERS.ini` to monitor FFT bins and visual parameters in real-time, aiding in fine-tuning. By default, `debugConsole` is on and `debugBins` is off.



## Acknowledgments

FAST FL0YD Visualizer uses several libraries and tools:

- **Processing**: [https://processing.org] - An open-source graphical library and IDE for creative coding.

- **FFmpeg**: [https://ffmpeg.org] - A powerful multimedia framework for video and audio processing.

- **Video Export by Hamoid**: [https://funprogramming.org/VideoExport-for-Processing/] - A Processing library that facilitates video export capabilities.

- **Sound Library**: [https://processing.org/reference/libraries/sound/index.html] - Provides essential tools for audio playback and visualization within Processing.



## Contribution

Contributions to FAST FL0YD are welcome! Feel free to fork the repository, make your enhancements, and submit pull requests. Please ensure you follow the guidelines set out in the LICENSE file when distributing modified versions of the visualizer.



## Conclusion

The FAST FL0YD Visualizer offers a unique blend of audio analysis and visual artistry. With its customizable parameters and video export functionality, it is an ideal tool for artists, musicians, and anyone interested in exploring the interplay between sound and visual experience. Enjoy creating mesmerizing visualizations!
