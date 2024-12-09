## Pose Event Detection

We detect time windows where the user's posture deviates from the normal. For each angle, we calculate the mean and standard deviation over the entire session. Time windows where the mean of any Euler angle is either lower or higher than: 

$$mean_{global} \pm (std_{global} \times n)$$ 

are labeled as events.

To implement this, we define the following function in the file [events.py](https://github.com/BiDAlab/IMPROVE/blob/main/Code/Pose%20Event%20Detection/events.py):  

```python
def pose_events_detection(ID, n, w, fps):
  
```
Input Parameters:

- **ID**: The user ID. Example: `"1"`.
- **n**: Multiplier for the standard deviation to identify an event.
- **w**: Time window in seconds to search for events.
- **fps**: Frames per second of the video.

The detected events are saved in the file `events.csv`, indicating the start and end frame of each event.

![Ejemplo de evento de pose detectado](https://github.com/BiDAlab/IMPROVE/blob/main/Code/Pose%20Event%20Detection/Video/Event.gif)
|:--:|
|Example of a Detected Pose Event|
