/*Contains methods to apply IK
more info look at 
http://www.math.ucsd.edu/~sbuss/ResearchWeb/ikmethods/iksurvey.pdf
http://www.math.ucsd.edu/~sbuss/ResearchWeb/ikmethods/SdlsPaper.pdf
*/
ArrayList<ModelBone> modelBones;

//public  class InverseKinematics{
  //s : end effector position
  //theta: rotation joint (1DOF) for each axis
  //s(theta): end effectors are functions of theta
  //v: Vector pointing to the axis of rot
  //P: position of the join
  //D(S)/D(theta) =  Vj X (Si - Pj)
  //Vj for 2d is (0,0,1), for 3D could take 3 values
  public Vec calculateDiff(Vec Pj, Vec Si, Vec Vj){
    Vec sub = new Vec(0,0,0); 
    Vec.subtract(Si, Pj, sub);
    Vec diff = new Vec(0,0,0);
    Vec.cross(Vj, sub, diff);
    return diff;
  }
  
  //Calculate 
  public float[][] calculateJacobian(ArrayList<Bone> joints, ArrayList<Bone> end_effectors){
    float[][] jacobian = new float[end_effectors.size()*3][joints.size() -1];
    //calc 3 rows corrsponding to a end effector    
    int i = 0;
    for(Bone s_i : end_effectors){
      int j = 0;
      for(Bone theta_j : joints){
        //check if the joint could move the end effector
        if(!s_i.isAncester(theta_j) || theta_j.parent == null){
          jacobian[i][j] = 0;
          jacobian[i+1][j] = 0;
          jacobian[i+2][j] = 0;         
        }else{
          Vec Pj = theta_j.parent.position();
          Pj = new Vec(Pj.x(), Pj.y(), 0.0);  
          Vec Si = s_i.position();
          Si = new Vec(Si.x(), Si.y(), 0.0);  
          Vec res = calculateDiff(Pj, Si, new Vec(0,0,1));        
          jacobian[i][j] = res.x();
          jacobian[i+1][j] = res.y();
          jacobian[i+2][j] = res.z();
        }          
        j++;
      }
      i+=3;
    }  
    return jacobian;
  } 
  
  public float[] calculateError(ArrayList<Bone> s, ArrayList<Vec> t){
    float[] e = new float[3*s.size()];
    for(int i = 0; i < s.size(); ){
      Vec ti = t.get(i);
      Vec si = s.get(i).position();
      e[i++] = ti.x() - si.x();
      e[i++] = ti.y() - si.y();
      e[i++] = ti.z() - si.z();
    }
    return e;
  }
  
  public static float[] getDeltaTheta(float alpha, float[] e){
    float[] deltaTheta = new float[e.length];
    //
    return deltaTheta;
  }  
  public float getDistance(Vec vv, Bone b){
    if(b.parent == null) return 99999;
    //is the distance btwn line formed by b and its parent and v
    Vec line = Vec.subtract(b.position(), b.parent.position());
    Vec va = Vec.subtract(vv, b.parent.position());
    float dot = Vec.dot(va, line);
    float mag = line.magnitude();
    float u  = dot*1./(mag*mag);
    Vec aux = new Vec();
    if(u >= 0 && u <=1){
      aux = new Vec(b.parent.position().x() + u*line.x(), b.parent.position().y() + u*line.y()); 
      aux = Vec.subtract(aux, vv);
    }
    if(u < 0){
      aux = Vec.subtract(b.parent.position(), vv); 
    }
    if(u > 1){
      aux = Vec.subtract(b.position(), vv); 
    }
    return aux.magnitude();
  }

  //Skinning algorithm
  public class Vertex{
    PVector v;
    int idx;
    public Vertex(int i, PVector vv){
      idx = i;
      v = vv;
    }
  }
  
  public void applyTransformations(ArrayList<ModelBone> ms){
    if(ms == null) return;
    for(ModelBone m : ms){
      m.applyTransformation();    
    }  
  }
  
  public class ModelBone{
    CustomModelFrame model;
    ArrayList<Vertex> vertices;
    Bone bone;    
    Vec initial_pos;
    float initial_angle;
    
    public void applyTransformation(){
      if(bone.parent == null) return; 
      float rot_angle = bone.join.angle - initial_angle;      
      //if(abs(rot_angle) < 0.001) return;      
      PShape p = model.shape();
      Vec mov = Vec.subtract(bone.parent.model_pos, initial_pos);
      for(Vertex v : vertices){        
        //do all transformations in model space
        Vec vec = new Vec(v.v.x,v.v.y,v.v.z);
        Vec rot = Vec.subtract(vec, bone.parent.model_pos);
        rot.rotate(rot_angle);
        Vec new_pos = Vec.add(rot,bone.parent.model_pos);        
        //apply translation
        new_pos.add(mov);
        v.v = new PVector(new_pos.x(),new_pos.y(),new_pos.z());        
        p.setVertex(v.idx, v.v);        
      }
      initial_pos = bone.parent.model_pos;
      Vec rot = Vec.subtract(bone.model_pos, bone.parent.model_pos);
      rot.rotate(rot_angle); rot.add(bone.parent.model_pos);
      //apply translation
      rot.add(mov);
      bone.model_pos = rot;
      initial_angle = bone.join.angle;
    }
  }      
  
  public ArrayList<ModelBone> execSimpleSkinning(CustomModelFrame model, ArrayList<Bone> bones){
    ArrayList<ModelBone> relations = new ArrayList<ModelBone>(); 
    for(int i = 0; i < bones.size(); i++){
      ModelBone m = new ModelBone();
      m.vertices = new ArrayList<Vertex>();
      m.model = model;
      m.bone = bones.get(i);
      //m.end = model.coordinatesOf(bones.get(i).position().get());
      //m.initial = bones.get(i).parent == null ? null : model.coordinatesOf(bones.get(i).parent.position().get());
      m.bone.model_pos = model.coordinatesOf(bones.get(i).position().get());
      m.initial_pos = bones.get(i).parent == null ? null : model.coordinatesOf(bones.get(i).parent.position().get());
      m.initial_angle = bones.get(i).join.angle;
      relations.add(m);
    }
    PShape s = model.shape();
    for(int c = 0; c < s.getVertexCount(); c++){
      PVector v = s.getVertex(c);
      int i = 0, n = -1;
      float  nearest = 9999;
      for(Bone b : bones){
        Vec vv = model.inverseCoordinatesOf(new Vec(v.x,v.y,v.z));
        if(b.parent != null)println("dist vec : " + vv + " bone : " + Vec.subtract(b.position(), b.parent.position()) + " dist : " + getDistance(vv,b));
        float new_dist = getDistance(vv,b);
        if(new_dist < nearest){
          n = i;
          nearest = new_dist;
        }
        i++;
      }
      relations.get(n).vertices.add(new Vertex(c,v));
    }
    return relations;  
  }  
//}
