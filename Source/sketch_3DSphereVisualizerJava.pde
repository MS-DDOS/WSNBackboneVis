float rotX = 0.0;
float rotY = 0.0;
boolean showMinMax = false;
int graphNumber = 0;
RandomSpherePoints rsp;

void setup(){
  size(1000, 1000, P3D);
  smooth();
  stroke(40, 166);
  strokeWeight(4.0);
  rsp = new RandomSpherePoints(round(width/2.5));
}

void draw(){
  background(0);
  translate(width*0.5, height*0.5);
  hint(ENABLE_DEPTH_TEST);
  hint(ENABLE_DEPTH_SORT);
  noStroke();
  colorMode(RGB);
  fill(30, 160);
  sphere(round(width/2.55));
  colorMode(HSB);
  rotateX(rotX);
  rotateY(rotY);
  rsp.draw();
  if(mousePressed){
      rotY += (pmouseX - mouseX) * -.002;
      rotX += (pmouseY - mouseY) * 0.002;
  } else {
     rotY += .002; 
  }
}

void keyPressed(){
   if(key == 'r'){
       graphNumber = 0;
   } else if(key == '1') {
       graphNumber = 1;
   } else if(key == '2') {
       graphNumber = 2; 
   } else if(key == 'm') {
       toggleMinMax(); 
   }
   rsp.setGraphNumber(graphNumber);
}

void toggleMinMax(){
   showMinMax = !showMinMax; 
   rsp.setShowMinMax(showMinMax);
}