//First Step get the image, and it contour
//For this purpose we're gonna use OpenCV
PImage source_image;
PImage destination_image;

//VARS TO FIND CONTOURS------------------------
OpenCV opencv;
float approximation = 0.1;
boolean invert = false; //change to true if the information of the image is in black 
PShape figure;
Rectangle r_figure;
ArrayList<Contour> contours        = new ArrayList<Contour>();
Contour contour;
ArrayList<PVector> edges           = new ArrayList<PVector>();  
//Some models
CustomModelFrame original_fig;


//COUNTOUR METHODS-------------------------------
PShape getCountours(){
  PShape img_contours;
  opencv = new OpenCV(this, source_image);
  //convert to gray
  opencv.gray();
  //apply basic threshold
  if(invert) opencv.invert();
  opencv.threshold(10);
  source_image = opencv.getOutput();
  contours = opencv.findContours();  
  //save just the external countour
  contour = contours.get(0);
  for (Contour c : contours){
    contour = contour.numPoints() < c.numPoints() ? c : contour;
  }
  contour.setPolygonApproximationFactor(approximation);
  contour = contour.getPolygonApproximation();

  println("founded a contour with" + contour.numPoints() + " points");  
  //save the points
  edges = contour.getPoints();
  img_contours = getCountoursShape((PImage)null);
  return img_contours;
}

void getCountoursShape(PShape img_contours){
  getCountoursShape((PImage)null);
}

PShape getCountoursShape(PImage text){
  PShape figure = createShape();
  figure.beginShape();
  if(text != null){
    text.resize(all_width,2*all_height/3);
    figure.textureMode(IMAGE);    
    figure.texture(text);
  }
  
  for(int k = 0; k < edges.size();k++){
    figure.stroke(255,255,255); 
    figure.strokeWeight(1); 
    figure.fill(color(0,0,255,100));
    figure.vertex(edges.get(k).x, edges.get(k).y,edges.get(k).x, edges.get(k).y);
  }
  figure.endShape(CLOSE);
  return figure;
}

void getContours(PShape s, ArrayList<PVector> points){
  s = getContours(points, color(0,255,0,100));
}

PShape getContours(ArrayList<PVector> points, int col){
  PShape s = createShape();
  s.beginShape();
  for(int k = 0; k < points.size();k++){
    s.stroke(255,255,255); 
    s.strokeWeight(2); 
    s.fill(col);
    s.vertex(points.get(k).x, points.get(k).y );
  }
  s.endShape(CLOSE);
  return s;
}
//END COUNTOUR METHODS---------------------------


public void setupFigure(){
  source_image = loadImage("human6.png");  
  source_image.resize(0,400);   
  //get the countours
  figure = getCountours();
  r_figure = getBoundingBox(edges);  
  //associate the shape with the original shape frame
  original_fig = new CustomModelFrame(main_scene, figure);
  original_fig.translate(-r_figure.getCenterX()/2,-r_figure.getCenterY()/2);
  original_fig.scale(0.5);

}