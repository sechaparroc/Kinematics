//SOME CONSTANTS
int TOKEN_W = 5;
int TOKEN_H = 10;
int TOKEN_DIM = 1;
Bone last_selected_bone = null;
JoinControl join_control = null;


public class Skeleton{
  ArrayList<Bone> bones;
  Bone frame;//used just for translations
  
  public Skeleton(){
    bones = new ArrayList<Bone>();
  }

  public Skeleton(float x, float y){
    bones = new ArrayList<Bone>();
    Bone b = new Bone(main_scene);
    b.createBone(x, y, this);
    frame = b;
  }

  //Cause is expected a short list the exhaustive application of the method is not costly
  public void updateAngles(){
    //traverse the list
    for(Bone b : bones){
      b.updateAngle();
    }
  }
}

public class Join{
  float max_angle;
  float min_angle;  
  float stable_angle;
  float angle;  
  int pos = 0; //0 means to rot according to the upperbound, 1 according to the lowerbound
  public Join(){
    max_angle = PI;
    min_angle = -1*PI;
    stable_angle = 0.;
    angle = stable_angle;
  }
  public Join(float min, float max, float st){
    max_angle = max;
    min_angle = min;
    stable_angle = st;
    angle = stable_angle;
  }
  
  public void setMax(float a){
    max_angle = a < min_angle ? max_angle : a;
    angle = angle > max_angle ? max_angle : angle;  
    stable_angle = stable_angle > max_angle ? max_angle : stable_angle;  
  }
  
  public void setMin(float a){
    min_angle = a > max_angle ? min_angle : a;
    angle = angle < min_angle ? min_angle : angle;    
    stable_angle = stable_angle < min_angle ? min_angle : stable_angle;    
  }
  public void setStable(float a){
    stable_angle = a > max_angle || a < min_angle ? stable_angle : a;
  }
  public void setAngle(float a){
    angle = a > max_angle || a < min_angle ? angle : a;  
  }

}

//the angle of a bone is the angle btwn the bone and its parent
public class Bone extends InteractiveFrame{
  float radius = 10;
  int colour = color(0,255,0);
  Skeleton skeleton;
  ArrayList<Bone> children = new ArrayList<Bone>();
  Bone parent = null;  
  Join join = null;
  Vec model_pos;

  public Bone(Scene sc){
    super(sc);
    skeleton = new Skeleton(); 
    join = new Join();
  }
  public Bone(Scene sc, Bone b, boolean isChild){
    super(sc);
    join = new Join();
    if(!isChild){
      parent = b;
      b.children.add(this);
    }
    else{
      children.add(b);
      b.parent = this;
    } 
    join = new Join();    
  }
  public Bone(Scene sc, Bone p, Bone c){
    super(sc);
    join = new Join();
    children.add(c); parent = p; join = new Join();
    p.children.add(this);
  }  

  void updateMainFrame(Frame frame){
    setReferenceFrame(frame);
  }
  
  public void createBone(float pos_x, float pos_y, Skeleton sk){
      println("entra");
      //Set initial orientatuion
      float angle = 0;
      //update();
      //add to an empty skeleton
      sk.bones.add(this);
      //relate to a new unconstrained join
      join = new Join(-1.*PI,PI, angle);
      //relate to parent frame
      updateMainFrame(skeleton.frame);
      this.translate(pos_x, pos_y);
      //this.rotate(new Quat(new Vec(0, 0, 1), angle));
      //relate the skeleton
      skeleton = sk;
      //keep a track of all the bones in the scene
      bones.add(this);
      println("sale");      
  }

  //Update the angle of the bone given a translation on its final point
  public void updateAngle(){
    Vec aux = parent == null ? new Vec(0,0,0) : parent.inverseCoordinatesOf(new Vec(0,0,0));
    Vec diff = Vec.subtract(inverseCoordinatesOf(new Vec(0,0,0)), aux);    
    float angle = atan2(diff.y(), diff.x());
    join.angle = angle >= -1* PI && angle <= PI ? angle : join.angle;
  }
  
  public void angleToPos(){
    Vec diff = translation();        
    float dim = diff.magnitude();
    this.setTranslation(dim*cos(join.angle), dim*sin(join.angle),0);
    println(join.angle + " pos " + position());
  }


  //add a new bone to the skeleton 
  //modify the angle of the join of the related bone
  //TO DO - Add functionality to the change of hierarchy
  public void addBone(boolean asParent, Vec place){
      //create a bone as child
      float pos_x = place.x(); 
      float pos_y = place.y(); 
      float angle = 0.;
      Bone b = new Bone(main_scene, this, false);
      b.join = new Join(-1.* PI,PI, angle);
      //Apply transformations
      b.updateMainFrame(this);
      b.translate(pos_x, pos_y);
      //Relate the new bone with the corresponding lists
      b.skeleton = skeleton;
      skeleton.bones.add(b);
      bones.add(b);      
  }

  public boolean isAncester(Bone cur, Bone p){
    if(cur.parent == null) return false;
    if(cur.parent == p) return true;
    return isAncester(cur.parent, p);
  }

  public boolean isAncester(Bone p){
    return isAncester(this, p);
  }

  protected void spinExecution(){
    super.spinExecution();
    println("entra " + getCorrectAngle(rotation().angle()));
    println("entra g" + getCorrectAngle(orientation().angle()));
    join.angle = getCorrectAngle(orientation().angle());
    skeleton.updateAngles();
  }  
  public void align() {
    super.align();
    println("entra " + getCorrectAngle(rotation().angle()));
    println("entra g" + getCorrectAngle(orientation().angle()));
    join.angle = getCorrectAngle(orientation().angle());
    skeleton.updateAngles();
    //println("entra " +     rotation().normalize());
  }
  
  public float getCorrectAngle(float angle){
    float a = angle;
    //get Angle btwn -PI and PI
    while(a < -PI) a += 2*PI;
    while(a >  PI) a -= 2*PI;
    return a;
  }

  @Override
  public boolean checkIfGrabsInput(float x, float y){
    float threshold = radius;
    Vec proj = scene().eye().projectedCoordinatesOf(position());
    if((Math.abs(x - proj.vec[0]) < threshold) && (Math.abs(y - proj.vec[1]) < threshold)){
      return true;      
    }
    return false;
  }

  //scroll action will increase or decrease the detail of the shape
  @Override
  public void performCustomAction(DOF1Event event) {   
      gestureScale(event, wheelSensitivity());
  }

  
  @Override
  public void performCustomAction(ClickEvent event) {
    if(add_bone){
      if(event.id() == 39){
        removeSkeleton();
        return;
      }
      else{
        addBone(false, new Vec(50,0));
      }
    } 
    else{
      //change color and highlight as selected
      if(last_selected_bone != null){
        last_selected_bone.colour = color(0,255,0);
      }
      last_selected_bone = this;
      //update join control
      control_frame.setupControlShape();
      colour = color(0,0,255);
    }
  }
  
  @Override
  public void performCustomAction(DOF2Event event) {
    if(add_bone){
      translate(screenToVec(Vec.multiply(new Vec(isEyeFrame() ? -event.dx() : event.dx(),
          (scene.isRightHanded() ^ isEyeFrame()) ? -event.dy() : event.dy(), 0.0f), translationSensitivity())));    
      skeleton.updateAngles();
      return;
    }
    //Translate the skeleton Frame
    skeleton.frame.translate(skeleton.frame.screenToVec(Vec.multiply(new Vec(skeleton.frame.isEyeFrame() ? -event.dx() : event.dx(),
        (scene.isRightHanded() ^ skeleton.frame.isEyeFrame()) ? -event.dy() : event.dy(), 0.0f), skeleton.frame.translationSensitivity())));    
  }
  //CHECK SCENE
  public void drawShape(){
      Vec aux = parent == null ? null : parent.inverseCoordinatesOf(new Vec(0,0,0));
      Vec aux2 = inverseCoordinatesOf(new Vec(0,0,0));
      main_scene.pg().pushStyle();
      if(aux != null){
        main_scene.pg().stroke(255,255,255);        
        main_scene.pg().line(aux2.x(),aux2.y(),aux2.z(),aux.x(), aux.y(), aux.z());
      }
      main_scene.pg().strokeWeight(radius);
      main_scene.pg().stroke(colour);
      main_scene.pg().point(aux2.x(),aux2.y(),aux2.z());
      main_scene.pg().popStyle();
  }
}


//Token mods:
public void removeSkeleton(){
  Skeleton sk = null;
  for (int i = 0; i < bones.size(); i++){ 
    if (bones.get(i).grabsInput(main_scene.motionAgent())){
      sk = bones.get(i).skeleton;
      break;
    }
  }
  if(sk == null) return;
  for(Bone b : sk.bones){
    //main_scene.removeModel(b);
    bones.remove(b);
  }
  skeletons.remove(sk);  
  last_selected_bone = null;
}


//Join Interactive Class
public class JoinControl extends InteractiveModelFrame{
  public class Pointer{
    PShape shape;
    Vec position;
    float value;
    float radius;
    float size;
    
    public boolean isInside(float x, float y){
      if(abs(x - position.x()) <= size && abs(y - position.y()) <= size)
        return true;
      return false;      
    }
    
    public float getDist(float x, float y){
      float x_dist = x - position.x();
      x_dist = x_dist * x_dist; 
      float y_dist = y - position.y();
      y_dist = y_dist * y_dist;
      return sqrt(x_dist + y_dist);      
    }
    
  }  

  ArrayList<Pointer> pointers = new ArrayList<Pointer>();  
  Join current_join; //This is an independent scene which related join is gonna be the last chosen
  float main_radius = 100;
  
  public JoinControl(Scene sc){
    super(sc);
    float[] values = {-1.*PI,0, 0, PI};
    setupControlShape(values);
  }
  
  
  public Pointer setupPointer(float r, float v){
    //create the shape
    Pointer p = new Pointer();
    p.value = v;
    p.radius = r;
    p.position = getPosition(v,r);
    float c_r = 15;
    p.size = c_r; 
    PShape s = createShape(ELLIPSE, p.position.x() - c_r*1./2., p.position.y() - c_r*1./2., c_r,c_r);
    s.fill(255,255,255);
    p.shape = s;
    return p;
  }
  
  public Vec getPosition(float v, float r){
    float v_to_rad = v;
    return new Vec(r*cos(v_to_rad), r*sin(v_to_rad));
  }
  
  public void setupControlShape(){
    if(last_selected_bone == null) return;
    Join j = last_selected_bone.join;
    updatePointer(pointers.get(0), j.min_angle);  
    updatePointer(pointers.get(1), j.stable_angle);  
    updatePointer(pointers.get(2), j.angle);  
    updatePointer(pointers.get(3), j.max_angle);  
  }
  
  public void setupControlShape(float[] values){
    float radius_step = main_radius*1./(values.length + 1);
    float rad = 0.;
    PShape p = createShape(GROUP);
    for(int i = 0; i < values.length; i++){
      PShape circ = createShape(ELLIPSE,-main_radius + radius_step*i, - main_radius + radius_step*i, 2*(main_radius - radius_step*i),2*(main_radius - radius_step*i));
      circ.setFill(color((int)random(255),(int)random(255),(int)random(255)));            
      p.addChild(circ);
    }
    rad= radius_step;
    for(int i = 0; i < values.length; i++){
      rad += radius_step;
      //create the appropiate pointer
      Pointer pointer = setupPointer(rad, values[i]);
      pointers.add(pointer);
      p.addChild(pointer.shape);
    }    
    setShape(p); 
  }
  
  public int getNearestPointer(float x, float y){
    float min_dist = 9999;
    int pos = -1;
    int cur = 0;
    for(int i = 0; i < pointers.size(); i++){
      if(pointers.get(i).isInside(x,y)) return i;
    }
    return -1;
    /*
    for(Pointer p : pointers){
      if(p.isInside(x,y)) return cur;
      float dist = p.getDist(x,y);
      if(dist < min_dist){
        min_dist = dist;
        pos = cur;
      }
      cur++;
    }
    return pos;*/
  }
  
  

  @Override
  public void performCustomAction(DOF2Event event) {    
      if(last_selected_bone == null) return;
      Vec point_world = aux_scene.eye().unprojectedCoordinatesOf(new Vec(event.x(), event.y()));
      Vec point_shape = coordinatesOf(point_world);
      int p = getNearestPointer(point_shape.x(), point_shape.y());      
      if(p == -1) return;
      Pointer pointer = pointers.get(p);      
      //move the angle to the place where the mouse is
      float new_angle = atan2(point_shape.y(), point_shape.x());
      println("-- new_angle -- " + new_angle);      
      updatePointer(pointer, new_angle);
      //update current join value
      current_join = last_selected_bone.join; 
      updateJoinValue(p, pointer);
  }
  
  public void updatePointer(Pointer p, float new_angle){
    //reset
    p.shape.translate(-p.position.x() + p.size*1./2., -p.position.y() + p.size*1./2.);             
    p.position = getPosition(new_angle,p.radius);
    p.value = new_angle;
    p.shape.translate(p.position.x() - p.size*1./2., p.position.y() - p.size*1./2.);          
  }
  
  public void updateJoinValue(int i, Pointer p){
    if(last_selected_bone.parent == null) return;
    if(i == 0){
      current_join.setMin(p.value); 
    }
    else if(i == 1){
      current_join.setStable(p.value); 
    }
    else if(i == 2){
      current_join.setAngle(p.value); 
    }
    else if(i == 3){
      current_join.setMax(p.value); 
    }   
    last_selected_bone.angleToPos();//setOrientation(new Quat(new Vec(0, 0, 1), p.value));
    last_selected_bone.skeleton.updateAngles();
    setupControlShape();
    println("join min: " + current_join.min_angle);
    println("join max: " + current_join.max_angle);
    println("join ang: " + current_join.angle);
    println("join sta: " + current_join.stable_angle);
  }
} 
/*

draw circle

dof2 -> according to rad move 1 point to the place where intersect with a ray
click reset
update vals:according to the selected bone <- call when a bone has the focus
use constrains

  float max_angle;
  float min_angle;  
  float stable_angle;
  float angle;  
  int pos = 0; //0 means to rot according to the upperbound, 1 according to the lowerbound

*/



