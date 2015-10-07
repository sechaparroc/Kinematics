//HANDLE SOME MOUSE AND KEYBOARD ACTIONS
boolean add_bone = false;
//Bone.add_bone = false;
void mousePressed(){
  /*for(Bone f : bones){
    if(f.grabsInput(main_scene.motionAgent())){
      last_selected_bone = f;          
      return;
    }
  }*/
  if(add_bone){
    if ((mouseX >= all_width - aux_scene.width()) && mouseY >= all_height - aux_scene.height()) return;
    if(mouseButton == LEFT){
      for(Bone f : bones){
        if(f.checkIfGrabsInput(mouseX,mouseY)){
          return;
        }
      }
      Vec point_world = main_scene.eye().unprojectedCoordinatesOf(new Vec(mouseX, mouseY));
      skeletons.add(new Skeleton(point_world.x(), point_world.y()));
    }
    if(mouseButton == RIGHT){
      //removeSkeleton();
    }
  }
}
boolean temp = false;
void keyPressed(){  
  //if(key == 'x' || key== 'X'){
  //  temp = !temp;
  //  if(temp) main_scene.removeModel(original_fig);
  //  else main_scene.addModel(original_fig);
  //}
  
  if(key=='b' || key=='B'){
    add_bone = !add_bone;
    if(last_selected_bone != null){
      last_selected_bone.colour = color(0,255,0);
    }
    last_selected_bone = null;
  }
  
  if(key == 'z' || key == 'Z'){
    if(last_selected_bone != null)
      modelBones = execSimpleSkinning(original_fig,last_selected_bone.skeleton.bones);
  }
}

//change by a deph search
void drawBones(){
  for(Skeleton s : skeletons){
    drawBones(s.frame);
  }
}

void drawBones(Bone root){
    main_scene.pg().pushMatrix();
    //root.applyWorldTransformation();
    main_scene.applyWorldTransformation(root);
    //main_scene.drawAxes(40);    
    main_scene.pg().popMatrix();
    root.drawShape();    
    for(Bone child : root.children) drawBones(child);
}


