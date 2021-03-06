import KinectPV2.KJoint;
import KinectPV2.*;

KinectPV2 kinect;
PImage depthImg, cloudImg, canvas;
int [] rawData;
//Distance Threashold
int maxD = 2000; // 4.5mx
int minD = 50;  //  50cm

ArrayList<XYAverageZone> zones = new ArrayList<XYAverageZone>();
int xx=400;
int yy=400;

void setup() {
 
  fullScreen(P3D);
  colorMode(HSB, 100);
  kinect = new KinectPV2(this);
  kinect.enableDepthImg(true);
  kinect.enablePointCloud(true);
  kinect.init();
  for (int y = 0; y < height; y+=yy ) {
    for (int x = 0; x < width; x+=xx ) {
      zones.add(new XYAverageZone(x, y, x+xx, y+yy));
    }
  }
  println(zones.size());
}

void draw() {
  background(0, 0, 50);
  this.depthImg = kinect.getDepthImage();
  this.rawData = kinect.getRawDepthData();
  this.cloudImg = kinect.getPointCloudDepthImage();

  //image(cloudImg, 512, 0);

  cloudImg.loadPixels();
  for (XYAverageZone xy : zones) {
    xy.clearSample();
  }

  for (int y = 0; y < 424; y++ ) {
    for (int x = 0; x < 512; x++ ) {

      int i = x+y*512;

      int module = 3;

      if (y%module==0) {
        if (x%module==0) {
          int cx = round(map(x, 0, 512, 0, width));
          int cy = round(map(y, 0, 424, 0, (424*width)/512));

          int offset = ((424*width)/512 - height)/2;

          float h = hue(cloudImg.pixels[i]);
          float s = saturation(cloudImg.pixels[i]);
          float b = brightness(cloudImg.pixels[i]);
          float a = alpha(cloudImg.pixels[i]);

          colorMode(HSB);

          float d = map(b, 0, 100, 0, 50);

          if (b>5 && b<20) {

            //if (cy < height) {
            for (XYAverageZone xy : zones) {
              xy.gatheringSamples(cx, cy-offset);
            }
            //}

            //ellipse(cx, cy-offset, d, d);
          }
        }
      }
    }
  }
  cloudImg.updatePixels();
  for (XYAverageZone xy : zones) {
    xy.createXYAverage();
  }

  noStroke(); 
  fill(200, 50, 50);
  for (XYAverageZone xy : zones) {

    if (xy.IsAverageCreated()==true) {
      ellipse(xy.getAverageXY()[0], xy.getAverageXY()[1], 50, 50);
    }
  }

  //Threahold of the point Cloud.
  kinect.setLowThresholdPC(minD);
  kinect.setHighThresholdPC(maxD);
  noFill();
  stroke(255, 0, 0);
  for (int y = 0; y < height; y+=xx ) {
    for (int x = 0; x < width; x+=yy ) {
      rect(x, y, xx, yy);
    }
  }
}

void keyPressed() {
  if (key == '1') {
    minD += 10;
    println("Change min: "+minD);
  }

  if (key == '2') {
    minD -= 10;
    println("Change min: "+minD);
  }

  if (key == '3') {
    maxD += 50;
    println("Change max: "+maxD);
  }

  if (key == '4') {
    maxD -=50;
    println("Change max: "+maxD);
  }
}
