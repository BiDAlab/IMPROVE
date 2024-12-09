# -*- coding: utf-8 -*-
"""
Created on Tue Oct 10 12:33:04 2023

@author: rober
"""

# Event detection
import numpy as np
import cv2

def pose_events_detection(ID, n, w, fps):
    
    path_inform = ID + "/csv"
    event = open(path_inform + "/events.csv", "w")
    event.write("Event" + "\n")
    yaw = np.loadtxt(path_inform + "/head_pose.csv", delimiter=' ', dtype=float, skiprows=1, usecols=(1,)).tolist()
    pitch = np.loadtxt(path_inform + "/head_pose.csv", delimiter=' ', dtype=float, skiprows=1, usecols=(2,)).tolist()
    roll = np.loadtxt(path_inform + "/head_pose.csv", delimiter=' ', dtype=float, skiprows=1, usecols=(3,)).tolist()
    frames_csv = np.loadtxt(path_inform + "/head_pose.csv", delimiter=' ', dtype=int, skiprows=1, usecols=(0,)).tolist()
    
    mean_yaw_global = np.mean(yaw)
    std_yaw_global = np.std(yaw)
    mean_pitch_global = np.mean(pitch)
    std_pitch_global = np.std(pitch)
    mean_roll_global = np.mean(roll)
    std_roll_global = np.std(roll)
    
    high_threshold_yaw = mean_yaw_global + (n * std_yaw_global)
    low_threshold_yaw = mean_yaw_global - (n * std_yaw_global)
    high_threshold_pitch = mean_pitch_global + (n * std_pitch_global)
    low_threshold_pitch = mean_pitch_global - (n * std_pitch_global)
    high_threshold_roll = mean_roll_global + (n * std_roll_global)
    low_threshold_roll = mean_roll_global - (n * std_roll_global)
    
    # Window in frames
    w_pose = int(w * fps)
    length = len(frames_csv)
    cont = 0  # To track the current frame in the video
    frame = 0  # Pointer in the CSV file to read the frame
    
    while (cont + w_pose <= frames_csv[length - 1]):
        # Check if the frames are consecutive
        
        frame_sum = 0
        correct = False
        for p in range(cont, cont + w_pose):  # Verify values are available for all frames in the window
            if p == frames_csv[frame + frame_sum]:
                correct = True
                frame_sum += 1
            else:
                correct = False
                cont = frames_csv[frame + frame_sum]  # Skip to the next frame
                frame += frame_sum  # Update pointer
                break
        
        if correct:        
            yaw_w = yaw[frame:frame + w_pose + 1]
            pitch_w = pitch[frame:frame + w_pose + 1]
            roll_w = roll[frame:frame + w_pose + 1]
            mean_yaw_w = np.mean(yaw_w)
            mean_pitch_w = np.mean(pitch_w)
            mean_roll_w = np.mean(roll_w)
        
            if (mean_yaw_w > high_threshold_yaw or mean_yaw_w < low_threshold_yaw or 
                mean_pitch_w > high_threshold_pitch or mean_pitch_w < low_threshold_pitch or 
                mean_roll_w > high_threshold_roll or mean_roll_w < low_threshold_roll):
                
                event.write(str([cont, cont + w_pose]).replace(' ', '') + "\n")
                
            cont += 1
            frame += 1
    
    # Filter events
    event.close() 
    event = np.loadtxt(path_inform + "/events.csv", delimiter=' ', dtype=str, skiprows=1, usecols=(0,)).tolist()
    event_fil = []
    sum = 0
    for i in range(0, len(event)):
        i = sum + i
        for j in range(i, len(event)):
            if j + 1 < len(event):
                event_vector = eval(event[j])
                event_vector1 = eval(event[j + 1])
                if event_vector[1] < event_vector1[0]:
                    event_vector = eval(event[i])
                    event_vector1 = eval(event[j])
                    event_fil.append([event_vector[0], event_vector1[1]])
                    sum = j - i + sum
                    break
            else:
                event_vector = eval(event[i])
                event_vector1 = eval(event[j])
                event_fil.append([event_vector[0], event_vector1[1]])
                sum = j - i + sum

    event = open(path_inform + "/events.csv", "w")
    event.write("Event" + "\n")                
    for t in range(0, len(event_fil)):        
        event.write(str(event_fil[t]).replace(' ', '') + "\n")
            
    event.close() 
    
# Read event    

def pose_shows(video, ID):
    
    path = ID + "/" + video
    path_inform = ID + "/csv"
    event = np.loadtxt(path_inform + "/events.csv", delimiter=' ', dtype=str, skiprows=1, usecols=(0,)).tolist()
    cap = cv2.VideoCapture(path)
    # Uncomment the next line to save the video output
    # output = cv2.VideoWriter('videoOutput.mp4', cv2.VideoWriter_fourcc(*'MP4V'), 30, (960, 540))
    for i in range(0, len(event)):
        event_vector = eval(event[i])
        for frame in range(event_vector[0], event_vector[1] + 1):
            cap.set(1, frame)
            success, image = cap.read()
            # Uncomment the next line to write the video frame
            # output.write(image)
            cv2.imshow('Pose Detection', image)
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
            if event_vector[1] == frame:
                cv2.destroyAllWindows()
                break
            
    # Uncomment the next line to release the video writer
    # output.release()
