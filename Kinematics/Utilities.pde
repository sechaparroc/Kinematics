public class Rectangle{
  float x,y,w,h;  
  public Rectangle(float xx, float yy, float ww, float hh){
    x = xx;
    y = yy;
    w = ww; 
    h= hh; 
  }
  float getCenterX(){
    return x + w/2;
  }
  float getCenterY(){
    return y + h/2;
  }
  @Override
  public String toString(){
    String s = "Rectangle: \n";
    s += "UL : x = " + x + ", y = " + y; 
    s += "width = " + w + ", height = " + h; 
    s += "centerX = " + getCenterX() + ", centerY = " + getCenterY(); 
    return s;
  }
}

//UTIL ALGORITHMS--------------------------------
ArrayList<PVector> quickSort(ArrayList<PVector> list, PVector comp, int size){
  if(size < 2) return list;
  Random rand = new Random();
  int pivot = rand.nextInt(size);
  int p1 = 0,p2 = 0;
  ArrayList<PVector>list1 = new ArrayList<PVector>();
  ArrayList<PVector>list2 = new ArrayList<PVector>();  
  //reorganize list
  for(int k = 0; k < size; k++){
    if(list.get(k).dist(comp) < list.get(pivot).dist(comp)){
      list1.add(list.get(k));
      p1++;
    }else{
      if(k != pivot){
        list2.add(list.get(k));
        p2++;
      }
    }
  }
  //recursion
  list1 = quickSort(list1, comp, p1);
  list2 = quickSort(list2, comp, p2);
  PVector num_pivot = list.get(pivot);
  //return the list in the right order
  for(int k = 0; k < p1; k++){
    list.set(k,list1.get(k));
  }
  list.set(p1, num_pivot);
  for(int k = 0; k < p2; k++){
    list.set(p1 + k + 1, list2.get(k));
  }
  return list;
}

public Rectangle getBoundingBox(ArrayList<PVector> points){
  PVector top = new PVector(9999,9999);
  PVector bottom = new PVector(-9999,-9999);
  for(PVector p : points){
    if(p.x < top.x) top.x = p.x;  
    if(p.y < top.y) top.y = p.y;  
    if(p.x > bottom.x) bottom.x = p.x;  
    if(p.y > bottom.y) bottom.y = p.y;  
  }
  return new Rectangle(top.x, top.y , bottom.x - top.x, bottom.y - top.y);
} 

public Rectangle getBoundingBox(PShape sh){
  PVector top = new PVector(9999,9999);
  PVector bottom = new PVector(-9999,-9999);
  for(int j = 0; j < sh.getChildCount(); j++){
    PShape shc = sh.getChild(j);
    for(int i = 0; i < shc.getVertexCount(); i++){
      PVector p = shc.getVertex(i);
      if(p.x < top.x) top.x = p.x;  
      if(p.y < top.y) top.y = p.y;  
      if(p.x > bottom.x) bottom.x = p.x;  
      if(p.y > bottom.y) bottom.y = p.y;    
    }
  }
  return new Rectangle(top.x, top.y , bottom.x - top.x, bottom.y - top.y);
} 
//-----------------------------------------------
public class CustomModelFrame extends InteractiveFrame{
  PShape shape;
  public CustomModelFrame(Scene sc, PShape s){
    super(sc);
    shape = s;
  }
  
  public PShape shape(){
    return shape;
  }
  
  public void draw(){
    main_scene.pg().pushMatrix();
    //root.applyWorldTransformation();
    main_scene.applyWorldTransformation(this);
    main_scene.drawAxes(40);    
    main_scene.pg().shape(shape);    
    main_scene.pg().popMatrix();
  }
    
  @Override
  public void performCustomAction(DOF2Event event) {
      translate(screenToVec(Vec.multiply(new Vec(isEyeFrame() ? -event.dx() : event.dx(),
        (scene().isRightHanded() ^ isEyeFrame()) ? -event.dy() : event.dy(), 0.0f), this.translationSensitivity())));
  }
}


