import java.util.Map;
import java.util.Arrays;
import java.util.ArrayList;
import java.util.Scanner;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

class RandomSpherePoints{
    boolean showMinMax;
    float sphereRad;
    float r;
    int graphNumber;
    int n;
    int avgDegree;
    int numColors;
    int minDegreeNode;
    int maxDegreeNode;
    String pathPrefix = "/Users/tylerspringer/Dropbox/ComputerProjects/WSN Java Port/Java Port/sketch_3DSphereVisualizerJava/";
    HashMap<Integer, PVector> points;
    HashMap<Integer, ArrayList<Integer>> adjList;
    HashMap<Integer, ArrayList<Integer>> colors;
    HashMap<Integer, Integer> slColoring;
    HashMap<Integer, ArrayList<Integer>> backbone1;
    HashMap<Integer, ArrayList<Integer>> backbone2;
    HashMap<Integer, HashMap<Integer, ArrayList<Integer>>> graphs;
    ArrayList<Integer> colorsToShow;
    
    RandomSpherePoints(float sphereRadius) {
       graphNumber = 0;
       sphereRad = sphereRadius;
       points = new HashMap<Integer, PVector>();
       adjList = new HashMap<Integer, ArrayList<Integer>>();
       slColoring = new HashMap<Integer, Integer>();
       backbone1 = new HashMap<Integer, ArrayList<Integer>>();
       backbone2 = new HashMap<Integer, ArrayList<Integer>>();
       colors = new HashMap<Integer, ArrayList<Integer>>();
       graphs = new HashMap<Integer, HashMap<Integer, ArrayList<Integer>>>();
       showMinMax = false;
       readGraphCSV();
       readAdjacencyList();
       try{
         readR(); //sets the values inside the method
       } catch (IOException e) {
          System.out.println("Something went wrong while reading r.csv");
          System.exit(1);
       }
       
       readSLColor();
       readBackbone1();
       readBackbone2();
       
       graphs.put(0, adjList);
       graphs.put(1, backbone1);
       graphs.put(2, backbone2);
       
       colorMode(HSB);
       float h = random(0.0,1.0);
       float golden_ratio_conjugate = 0.618033988749895;
       for(int i = 0; i < numColors; i++) {
          h += golden_ratio_conjugate;
          h = h % 1.0;
          colors.put(i, new ArrayList<Integer>(Arrays.asList((int)(h*255.0), (int)(.65*255.0), (int)(.8*255.0))));
       }
    }
    
    void draw(){
       strokeWeight(12);
       stroke(200, 20, 20);
       plotPoints();
       stroke(20);
       strokeWeight(1);
       plotEdges();
    }
    
    void plotEdges(){
        colorMode(RGB); //<>//
        if(graphNumber == 0){
           strokeWeight(.65); 
        } else {
           strokeWeight(1.75); 
        }
        stroke(255, 160);
        for( Map.Entry kv : adjList.entrySet()){ //<>//
          if(graphs.get(graphNumber).containsKey(kv.getKey())){
             if((showMinMax == true) && ((int)kv.getKey() == minDegreeNode)) {
                stroke(28, 198, 255);
                strokeWeight(2.0);
             } else if((showMinMax == true) && ((int)kv.getKey() == maxDegreeNode)) {
                stroke(255, 28, 28);
                strokeWeight(2.0);
             } else if(showMinMax) {
                continue; 
             } else if((graphNumber == 0) && (n > 4000)) {
                continue; //4000 is an abitrary number. With larger data sets the edges are not displayed for performance reasons
             }
             for (int val : graphs.get(graphNumber).get(kv.getKey())){
                line(points.get(kv.getKey()).x, points.get(kv.getKey()).y, points.get(kv.getKey()).z, points.get(val).x, points.get(val).y, points.get(val).z);
             }
          }
          
        }
        colorMode(RGB);
    }
    
    void plotPoints(){
       colorMode(HSB);
        for( Map.Entry kv : graphs.get(graphNumber).entrySet()){
           strokeWeight(7);
           if((showMinMax == true) && ((int)kv.getKey() == minDegreeNode)) {
             stroke(195, 89, 100);
           } else if((showMinMax == true) && ((int)kv.getKey() == minDegreeNode)) {
                stroke(0, 89, 100);
           } else if(showMinMax) {
                strokeWeight(4);
                stroke(195, 0, 100);
           } else {
                ArrayList<Integer> nodeColor = colors.get(slColoring.get(kv.getKey()));
                stroke(nodeColor.get(0), nodeColor.get(1), nodeColor.get(2));
           } 
           point(points.get(kv.getKey()).x, points.get(kv.getKey()).y, points.get(kv.getKey()).z);
        }
    }
    
    void readGraphCSV(){
      int lineCounter = 0;
      File file = new File(pathPrefix + "graph.csv");
      try{
         Scanner fin = new Scanner(file);
         while(fin.hasNextLine()){
           String line = fin.nextLine();
           if(lineCounter == 0) {
              lineCounter += 1;
              continue;
           }
           String[] splitUp = line.split(",");
           PVector newVec = new PVector(Float.parseFloat(splitUp[1])*sphereRad, Float.parseFloat(splitUp[2])*sphereRad, Float.parseFloat(splitUp[3])*sphereRad);
           this.points.put(Integer.parseInt(splitUp[0]),newVec);
           
         }
         fin.close();
      } catch(FileNotFoundException e) {
         System.out.println("graph.csv not found in working directory");
         System.exit(1);
      }
    }
    
    void readAdjacencyList(){
      int lineCounter = 0;
      File file = new File(pathPrefix + "adjListCompressed.csv");
      try{
         Scanner fin = new Scanner(file);
         while(fin.hasNextLine()){
           String line = fin.nextLine();
           if(lineCounter == 0) {
              lineCounter += 1;
              continue;
           }
           String[] splitUp = line.split(",");
           ArrayList<Integer> neighbors = new ArrayList<Integer>();
           int lineCounter2 = 0;
           for(String item : splitUp) {
             if(lineCounter2 == 0) {
                lineCounter2 += 1;
                continue;
             }
             neighbors.add(Integer.parseInt(item.trim()));
           }
           adjList.put(Integer.parseInt(splitUp[0]), neighbors);
           
         }
         fin.close();
      } catch(FileNotFoundException e) {
         System.out.println("adjListCompressed.csv not found in working directory");
         System.exit(1);
      }
    }
    
    void readR() throws IOException {
       String r = new String(Files.readAllBytes(Paths.get(pathPrefix + "r.csv")));
       String[] vals = r.split("\n");
       String[] minDegree = vals[6].split(",");
       String[] maxDegree = vals[8].split(",");
       this.r = Float.parseFloat(vals[0]);
       n = Integer.parseInt(vals[1]);
       avgDegree = Integer.parseInt(vals[2]);
       numColors = Integer.parseInt(vals[3]);
       minDegreeNode = Integer.parseInt(minDegree[0]);
       maxDegreeNode = Integer.parseInt(maxDegree[0]);
    }
    
    void readSLColor(){
       File file = new File(pathPrefix + "slColoring.csv");
       try {
          Scanner fin = new Scanner(file);
          while(fin.hasNextLine()){
             String line = fin.nextLine();
             String[] splitUp = line.split(",");
             slColoring.put(Integer.parseInt(splitUp[0]), Integer.parseInt(splitUp[1].trim()));
          }
          fin.close();
       } catch(FileNotFoundException e) {
          System.out.println("slColoring.csv not found in working directory");
          System.exit(1);
       }
    }
    
    void readBackbone1(){
      File file = new File(pathPrefix + "backbone1.csv");
      try{
         Scanner fin = new Scanner(file);
         while(fin.hasNextLine()){
           String line = fin.nextLine();
           String[] splitUp = line.split(",");
           ArrayList<Integer> neighbors = new ArrayList<Integer>();
           int lineCounter = 0;
           for(String item : splitUp) {
             if(lineCounter == 0) {
                lineCounter += 1;
                continue;
             }
             neighbors.add(Integer.parseInt(item.trim()));
           }
           backbone1.put(Integer.parseInt(splitUp[0]), neighbors);
           
         }
         fin.close();
      } catch(FileNotFoundException e) {
         System.out.println("backbone1.csv not found in working directory");
         System.exit(1);
      }
    }
    
    void readBackbone2(){
      File file = new File(pathPrefix + "backbone2.csv");
      try{
         Scanner fin = new Scanner(file);
         while(fin.hasNextLine()){
           String line = fin.nextLine();
           String[] splitUp = line.split(",");
           ArrayList<Integer> neighbors = new ArrayList<Integer>();
           int lineCounter = 0;
           for(String item : splitUp) {
             if(lineCounter == 0) {
                lineCounter += 1;
                continue;
             }
             neighbors.add(Integer.parseInt(item.trim()));
           }
           backbone2.put(Integer.parseInt(splitUp[0]), neighbors);
           
         }
         fin.close();
      } catch(FileNotFoundException e) {
         System.out.println("backbone2.csv not found in working directory");
         System.exit(1);
      }
    }
    
    void setGraphNumber(int num){
       graphNumber = num; 
    }
    
    void setShowMinMax(boolean val){
       showMinMax = val; 
    }
}