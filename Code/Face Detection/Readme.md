Face Detection
===============
It provides the location of faces in 2D images. The location is represented using a bounding box known as a "*bounding box*," and it is described as follows:

$$(x_{min}, y_{min}, width, height)$$

This module takes a sequence of images (video) as input and provides the face location as output, if one is present. The outputs are recorded in a CSV file:

- **box.csv**: This file is the output of the facial detection module. It contains two distinct columns (*Frame* and *Box*). The *Frame* field indicates the video frame analyzed, while the *Box* column records the 2D coordinates of the detected face positions.

This module is developed using state-of-the-art technology based on Deep Learning. In particular, we utilize the facial detector from the [MediaPipe](https://developers.google.com/mediapipe/solutions/vision/face_detector#blazeface_full-range) library due to its recognized reliability and speed.

| &nbsp; &nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;![Detección Facial](https://github.com/BiDAlab/IMPROVE/blob/main/Code/Face%20Detection/Videos/Face_Detection.gif)&nbsp; &nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |
|:--:|
|Example of facial detection displaying the *bounding box*.|

# Code

The code is available at the following [link](https://github.com/BiDAlab/BIOPROCTORING/blob/main/Modules/Face_Detection/Detector%20Facial/code_main.py). 

```python
ID = "1"
video = "example.mp4"
see_box = True
main(video, ID, see_box)
```

- **Inputs:** This function is designed for facial detection and includes the following inputs:
  - **ID**: The user's identifier.
  - **video**: Specifies the session to be processed for that user.
  - **see_box**: Enables the video to be displayed with the *bounding boxes* drawn if set to `True`.

In this example, user "1" and the video "example.mp4" have been selected.


# Package Installation

The required packages for this module to work are **mediapipe** and **opencv**.

```plaintext
Python== 3.10.11
mediapipe==0.10.1
opencv-python==4.7.0.72
```
All packages can be installed using the pip package manager.

```p
pip install mediapipe
pip install opencv-python
```
