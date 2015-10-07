/*First approach in Inverse Kinematic*/
import papaya.*;

import java.util.Random;
//use preprocessing algorithms (find contours, threshold)
import gab.opencv.*;

//-----------------------------------------------
//Proscene
//Use InteractiveModelFrame and override actions
import remixlab.bias.core.*;
import remixlab.bias.event.*;
import remixlab.proscene.*;
import remixlab.dandelion.core.Constants.*;
import remixlab.dandelion.geom.*;
import remixlab.dandelion.core.*;

/*
Sebastian Chaparro
July 2 2015
*/

//Processing variables
//PGRAPHICS
PGraphics main_graphics;
PGraphics aux_graphics;
PGraphics control_graphics;


//SCENES------------------------------------------
/*Basically 2 scenes are required: one to draw the main Object,
the other one to control the world as an sphere */
Scene main_scene;
Scene aux_scene;
JoinControl control_frame;

final int all_width = 600;
final int all_height = 620;
boolean showAid = true;
final int aux_pos_x = all_width-all_width/4;
final int aux_pos_y = all_height-all_height/3;

//This is gonna be a serie of tokens to manipulate
ArrayList<Skeleton> skeletons = new ArrayList<Skeleton>();
ArrayList<Bone> bones = new ArrayList<Bone>();

public void setup(){
  size(600, 620, P2D);
  main_graphics = createGraphics(all_width,all_height,P2D);
  main_scene = new Scene(this, main_graphics);
  aux_graphics = createGraphics(all_width/4,all_height/3,P2D);
  aux_scene = new Scene(this, aux_graphics, aux_pos_x, aux_pos_y);    
  main_scene.setAxesVisualHint(false);
  main_scene.setGridVisualHint(false);
  aux_scene.setAxesVisualHint(true);
  aux_scene.setGridVisualHint(true);
  main_scene.setRadius(50);
  main_scene.mouseAgent().setButtonBinding(Target.FRAME, RIGHT, DOF2Action.CUSTOM);
  main_scene.mouseAgent().setButtonBinding(Target.FRAME, LEFT, DOF2Action.CUSTOM);
  main_scene.mouseAgent().setClickBinding(Target.FRAME, LEFT, ClickAction.CUSTOM);
  main_scene.mouseAgent().setClickBinding(Target.FRAME, RIGHT, ClickAction.CUSTOM);
  main_scene.mouseAgent().setWheelBinding(Target.FRAME, DOF1Action.CUSTOM);  
  aux_scene.mouseAgent().setButtonBinding(Target.FRAME, RIGHT, DOF2Action.CUSTOM);
  aux_scene.mouseAgent().setButtonBinding(Target.FRAME,  LEFT , DOF2Action.CUSTOM);
  control_frame = new JoinControl(aux_scene);
  setupFigure();
}

public void draw(){
  handleAgents();  
  main_graphics.beginDraw();
  main_scene.beginDraw();
  main_graphics.background(0);
  original_fig.draw();
  drawBones();
  main_scene.endDraw();
  main_graphics.endDraw();    
 image(main_graphics, main_scene.originCorner().x(), main_scene.originCorner().y());
  if (showAid) {
    aux_graphics.beginDraw();
    aux_scene.beginDraw();
    aux_graphics.background(125, 125, 125, 125);
    aux_scene.drawModels();
    aux_scene.endDraw();
    aux_graphics.endDraw();    
    image(aux_graphics, aux_scene.originCorner().x(), aux_scene.originCorner().y());
  }
  applyTransformations(modelBones);
}

int drag_mode = -1;
void handleAgents() {
  aux_scene.disableMotionAgent();
  aux_scene.disableKeyboardAgent();
  main_scene.disableMotionAgent();
  main_scene.disableKeyboardAgent();
  if ((mouseX >= all_width - aux_scene.width()) && mouseY >= all_height - aux_scene.height()) {
    aux_scene.enableMotionAgent();
    aux_scene.enableKeyboardAgent();
  }else if(drag_mode == -1) {
    main_scene.enableMotionAgent();
    main_scene.enableKeyboardAgent();
  }
}
