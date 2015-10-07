# Kinematics
Kinematics Application with ProScene
Implementation of Forward and Inverse Kinematics using  in processing (2D).

This is an implementation in Processing of forward and inverse kinematics using a skeleton composed by hierarchical relations between joints as suggested in: 

http://www.math.ucsd.edu/~sbuss/ResearchWeb/ikmethods/iksurvey.pdf
http://www.math.ucsd.edu/~sbuss/ResearchWeb/ikmethods/SdlsPaper.pdf

So, the idea is that a image is loaded and preprocessed to get just its contour (a list of vertices) and according to the contour the user creates a "Skeleton" locating some joints where the user consider appropriate.

The order of the insertion of the joints matter, that is, the next added joint is gonna be the child of the latest one. By this we guarantee that the skeleton is a tree structure which nodes are frames with local coordinates.

When the user finish to establish the joints of the models then is used a simple skinning algorithm, that will relate the joints of the skeleton with some vertices from the image. By establishing this relation the shape will be modified if the joints change their positions.

The Scene that is shown is composed by a single shape (the contours of the loaded image) and the joints are added according to the user preference.

There are two main dependences:

•	Papaya: Provides useful matrices functions. Will be used for the inverse kinematics behvior.

•	ProScene: Provides useful tools to handle interactions in a scene.

__Some controls__:

__Behaviors:__

- Add bones: Use the mouse left click to add bones. If the mouse is over a joint creates a bone child. 

- Editing: If a bone is selected,  its related joint can be handle by the control located in the lower right side of the screen.

__Keys:__

- 'b' : change between add bones behavior and editing behavior.

- 'z' : execute a skinning algorithm, so it will relate the last selected skeleton with the model in the screen. Needs to be in editing behavior.

__Example Videos:__

https://www.youtube.com/watch?v=QQCOi27bKjM
https://www.youtube.com/watch?v=AwsnGQggrkU
https://www.youtube.com/watch?v=CDlRB59dIFI
https://www.youtube.com/watch?v=-zl4fcuDEIo
