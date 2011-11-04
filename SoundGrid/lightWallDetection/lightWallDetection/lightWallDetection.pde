
import processing.net.*;

int port = 9001;
Server myServer;

//variables for sending







//variable d'affichage d'informations
boolean showGirdtransform=false;
boolean showGirdNormal=false;
boolean blob=true;
boolean showImgEtalonnage=false;


// blob detection et camera
import processing.video.*;
import blobDetection.*;
Capture cam;
BlobDetection theBlobDetection;

boolean newFrame=false;

//variable de capture de résultat de transformation
PImage img;
PImage img2;
PImage img3;

// image d'étalonnage
PImage Testcard;



//variable envoyé au serveur xml
byte zero = 0;
float centerBlobX;
float centerBlobY;
float widthBlob;
float heightBlob;
boolean blobDetection;

//variable nécessaire a la déformation de l image
int girdSize=10;

float lineHeight=480/girdSize;
float lineWidth= 640/girdSize;

float textureWidth;

int originPointNumber;
int pointNumberChange=0;

int NumberOfPoints= (girdSize+1)*(girdSize+1);

//array contenant tout les point de déformation
float[][] pointsArray= new float[NumberOfPoints][2];

//array contenant les coordonné de texture de l'image
float[][] pointsArrayTexture = new float [NumberOfPoints][2]; 


void setup()
{

  // initialisation de la déformation sauvegarder 
  float[][] pArray = {{8.0, -24.0}, {64.0, -12.0}, {128.0, -24.0}, {192.0, -16.0}, {256.0, -12.0}, {320.0, -16.0}, {384.0, -16.0}, {448.0, -12.0}, {512.0, -28.0}, {572.0, -36.0}, {640.0, 0.0}, {-16.0, -44.0}, {64.0, -44.0}, {128.0, -40.0}, {192.0, 0.0}, {256.0, 0.0}, {320.0, -4.0}, {384.0, 8.0}, {448.0, 0.0}, {512.0, 0.0}, {576.0, 8.0}, {636.0, -4.0}, {-28.0, 40.0}, {40.0, 32.0}, {112.0, 40.0}, {192.0, 40.0}, {256.0, 40.0}, {320.0, 40.0}, {372.0, 36.0}, {448.0, 28.0}, {512.0, 28.0}, {584.0, 24.0}, {648.0, 48.0}, {-40.0, 40.0}, {36.0, 44.0}, {108.0, 44.0}, {180.0, 48.0}, {240.0, 50.0}, {312.0, 52.0}, {372.0, 56.0}, {440.0, 49.0}, {508.0, 49.0}, {584.0, 48.0}, {672.0, 60.0}, {-44.0, 116.0}, {28.0, 116.0}, {103.0, 118.0}, {176.0, 119.0}, {240.0, 120.0}, {308.0, 120.0}, {371.0, 120.0}, {440.0, 120.0}, {512.0, 120.0}, {588.0, 119.0}, {676.0, 116.0}, {-48.0, 171.0}, {20.0, 168.0}, {97.0, 170.0}, {172.0, 169.0}, {240.0, 172.0}, {308.0, 172.0}, {372.0, 171.0}, {443.0, 171.0}, {518.0, 172.0}, {596.0, 172.0}, {684.0, 172.0}, {-48.0, 289.0}, {8.0, 225.0}, {89.0, 224.0}, {166.0, 224.0}, {236.0, 224.0}, {306.0, 224.0}, {375.0, 224.0}, {447.0, 224.0}, {524.0, 228.0}, {603.0, 228.0}, {699.0, 233.0}, {-24.0, 332.0}, {0.0, 288.0}, {81.0, 284.0}, {160.0, 284.0}, {233.0, 284.0}, {304.0, 284.0}, {378.0, 284.0}, {451.0, 288.0}, {530.0, 292.0}, {613.0, 296.0}, {708.0, 304.0}, {-36.0, 392.0}, {-12.0, 360.0}, {69.0, 356.0}, {153.0, 354.0}, {229.0, 352.0}, {304.0, 352.0}, {378.0, 352.0}, {458.0, 356.0}, {537.0, 360.0}, {626.0, 367.0}, {732.0, 368.0}, {-40.0, 428.0}, {-28.0, 444.0}, {57.0, 438.0}, {145.0, 432.0}, {224.0, 432.0}, {304.0, 432.0}, {381.0, 432.0}, {463.0, 436.0}, {548.0, 444.0}, {644.0, 456.0}, {743.0, 472.0}, {-52.0, 476.0}, {-44.0, 528.0}, {44.0, 516.0}, {134.0, 508.0}, {216.0, 508.0}, {300.0, 508.0}, {380.0, 512.0}, {468.0, 524.0}, {555.0, 536.0}, {656.0, 557.0}, {772.0, 476.0}};
  pointsArray = pArray;

  //size all
  size(640, 480, P3D);

  //server xml
  myServer = new Server(this , port);

  // Capture
  cam = new Capture(this, 640, 480, 15);

  // BlobDetection
  // img which will be sent to detection (a smaller copy of the cam frame);
  img = new PImage(640, 480); 
  img2 = new PImage(160, 120); 
  img3 = new PImage(640, 480);

  //image d'étallonage 
  Testcard = new PImage(640, 480);
  Testcard = loadImage("capture.jpg");

  //blob detection

  theBlobDetection = new BlobDetection(img2.width, img2.height);
  theBlobDetection.setPosDiscrimination(true);
  theBlobDetection.setThreshold(0.11f); // will detect bright areas whose luminosity > 0.2f
  //initiatlisation des points de textures
  initPoints();
}


// capture de la caméra
void captureEvent(Capture cam)
{
  cam.read();
  newFrame = true;
}


void draw()
{
   myServer.write(blobDetection+","+centerBlobX+","+centerBlobY+","+widthBlob+","+heightBlob);
   myServer.write(zero);
   
  if (newFrame)
  {
    background(0);

    img.copy(cam, 0, 0, cam.width, cam.height, 0, 0, cam.width, cam.height);

    //affichage de l'image déformé
    for (int j=0; j<girdSize;j++) {

      for (int k=0; k<girdSize;k++) {

        originPointNumber=(j*(girdSize+1))+k;
        textureWidth=100/girdSize;

        noStroke(); 


        textureMode(NORMALIZED);




        beginShape();

        //affichage de la capture de la caméro ou de l'image d'étalonnage

          if (showImgEtalonnage) {
          texture(Testcard);
        }
        else {
          texture(cam);
        }

        vertex(pointsArray[originPointNumber][0], pointsArray[originPointNumber][1], (((pointsArrayTexture[originPointNumber][0])*100)/640)/100, (((pointsArrayTexture[originPointNumber][1])*100)/480)/100);
        vertex(pointsArray[originPointNumber+1][0], pointsArray[originPointNumber+1][1], (((pointsArrayTexture[originPointNumber+1][0])*100)/640)/100, (((pointsArrayTexture[originPointNumber+1][1])*100)/480)/100);
        vertex(pointsArray[originPointNumber+2+girdSize][0], pointsArray[originPointNumber+2+girdSize][1], (((pointsArrayTexture[originPointNumber+2+girdSize][0])*100)/640)/100, (((pointsArrayTexture[originPointNumber+2+girdSize][1])*100)/480)/100);
        vertex(pointsArray[originPointNumber+1+girdSize][0], pointsArray[originPointNumber+1+girdSize][1], (((pointsArrayTexture[originPointNumber+1+girdSize][0])*100)/640)/100, (((pointsArrayTexture[originPointNumber+1+girdSize][1])*100)/480)/100);

        endShape();
      }
    }

    // on prend l'image déformation pour le blob detection    
    img3=get();
    img2.copy(img3, 0, 0, img.width, img.height, 0, 0, img2.width, img2.height);

    // on lisse l'image
    fastblur(img2, 2); 

    //on la passe au blob dection
    theBlobDetection.computeBlobs(img2.pixels);
    drawBlobsAndEdges(blob, blob);

    // affiche ou non de la grille de déformation et du points a déformer
    if (showGirdtransform) {


      fill(0, 255, 0);
      noStroke();
      ellipse(pointsArray[pointNumberChange][0], pointsArray[pointNumberChange][1], 10, 10);

      for (int c=0; c<girdSize;c++) {

        for (int v=0; v<girdSize;v++) {

          originPointNumber=(c*(girdSize+1))+v;        
          strokeWeight(1);
          stroke(100);

          line(pointsArray[originPointNumber][0], pointsArray[originPointNumber][1], pointsArray[originPointNumber+1][0], pointsArray[originPointNumber+1][1]);
          line(pointsArray[originPointNumber+1][0], pointsArray[originPointNumber+1][1], pointsArray[originPointNumber+2+girdSize][0], pointsArray[originPointNumber+2+girdSize][1]);
          line(pointsArray[originPointNumber+2+girdSize][0], pointsArray[originPointNumber+2+girdSize][1], pointsArray[originPointNumber+1+girdSize][0], pointsArray[originPointNumber+1+girdSize][1]);
          line(pointsArray[originPointNumber+1+girdSize][0], pointsArray[originPointNumber+1+girdSize][1], pointsArray[originPointNumber][0], pointsArray[originPointNumber][1]);

          line(pointsArray[originPointNumber+2+girdSize][0], pointsArray[originPointNumber+2+girdSize][1], pointsArray[originPointNumber][0], pointsArray[originPointNumber][1]);
        }
      }
    }


    //affichage ou non de la grille 

    if (showGirdNormal) {
      noFill();
      stroke(255, 0, 0);

      rect(0, 0, 640, 480);

      line(1*(640/11), 0, 1*(640/11), 480);
      line(2*(640/11), 0, 2*(640/11), 480);
      line(3*(640/11), 0, 3*(640/11), 480);
      line(4*(640/11), 0, 4*(640/11), 480);
      line(5*(640/11), 0, 5*(640/11), 480);
      line(6*(640/11), 0, 6*(640/11), 480);
      line(7*(640/11), 0, 7*(640/11), 480);
      line(8*(640/11), 0, 8*(640/11), 480);
      line(9*(640/11), 0, 9*(640/11), 480);
      line(10*(640/11), 0, 10*(640/11), 480);

      line(0, 1*(480/11), 640, 1*(480/11));
      line(0, 2*(480/11), 640, 2*(480/11));
      line(0, 3*(480/11), 640, 3*(480/11));
      line(0, 4*(480/11), 640, 4*(480/11));
      line(0, 5*(480/11), 640, 5*(480/11));
      line(0, 6*(480/11), 640, 6*(480/11));
      line(0, 7*(480/11), 640, 7*(480/11));
      line(0, 8*(480/11), 640, 8*(480/11));
      line(0, 9*(480/11), 640, 9*(480/11));
      line(0, 10*(480/11), 640, 10*(480/11));
    }

    // envoie des donnée au serveur xml
  }
}

//initialisition des points de texture
void initPoints() {

  int i=0;
  for (int n=0 ; n<girdSize+1 ; n++)
  {
    for (int m=0; m<girdSize+1;m++) {


      //pointsArray[i][0] = m*lineWidth;
      //pointsArray[i][1] = n*lineHeight;

      pointsArrayTexture[i][0] = m*lineWidth;
      pointsArrayTexture[i][1] = n*lineHeight;
      i++;
    }
  }
}

//affichage du blob le plus grand
void drawBlobsAndEdges(boolean drawBlobs, boolean drawEdges)
{
  noFill();
  Blob b;
  EdgeVertex eA, eB;
  for (int n=0 ; n<1 ; n++)
  {
    b=theBlobDetection.getBlob(n);
    if (b!=null)
    {
      
      blobDetection=true;

      // Blobs
     
       

        //on cherche le centre du blob
        centerBlobX=b.xMin*width+(b.w*width/2);
        centerBlobY=b.yMin*height+(b.h*height/2);

        widthBlob=b.w*width;
        heightBlob=b.h*height;
        //on cherche la largeur et la hauteur du blob
        

        noFill();
        strokeWeight(2);
        stroke(255, 0, 0);
       
         if (drawBlobs)
      {
        
         strokeWeight(1);
        stroke(0, 0, 255);
        fill(0, 0, 255);
       rect(centerBlobX-2.5, centerBlobY-2.5, 5, 5);
       noFill();
        strokeWeight(2);
        stroke(255, 0, 0);
        rect(b.xMin*width, b.yMin*height, widthBlob, heightBlob);
      }
    }else{
       
       blobDetection=false;

      }
    }
  }



// evenement clavier

void keyPressed() {
  //println("pressed " + int(key) + " " + keyCode);
  //--------------------- Les touche 1,2,3,4 pour savoir quel coin on modifie
  if (keyCode == 49) {
    if (blob) {
      blob=false;
    }
    else {
      blob=true;
    }
  }
  if (keyCode == 50) {
    if (showGirdtransform) {
      showGirdtransform=false;
    }
    else {
      showGirdtransform=true;
    }
  }
  if (keyCode == 51) {
    if (showGirdNormal) {
      showGirdNormal=false;
    }
    else {
      showGirdNormal=true;
    }
  }

  if (keyCode == 52) {
    if (showImgEtalonnage) {
      showImgEtalonnage=false;
    }
    else {
      showImgEtalonnage=true;
    }
  }




  if (key == 'w' || key == 'W') {
    if (pointNumberChange-(girdSize+1)>=0) {
      pointNumberChange-=(girdSize+1);
    }
  }

  if (key == 's' || key == 'S') {
    if (pointNumberChange+(girdSize+1)<NumberOfPoints) {
      pointNumberChange+=(girdSize+1);
    }
  }
  if (key == 'a' || key == 'A') {
    if (pointNumberChange-1>=0) {
      pointNumberChange-=1;
    }
  }
  if (key == 'd' || key == 'D') {
    if (pointNumberChange+1<NumberOfPoints) {
      pointNumberChange+=1;
    }
  }

  if (key == 'p' || key == 'P') {

    for (int u=0; u<pointsArray.length; u++) {
      print("{"+pointsArray[u][0]+", "+pointsArray[u][1]+"}, ");
    }
  }

  //--------------------- Le touches pour faire bouger les coins
  if (keyCode == UP) {
    pointsArray[pointNumberChange][1]-=1;
  }
  if (keyCode == DOWN) {
    pointsArray[pointNumberChange][1]+=1;
  }
  if (keyCode == LEFT) {
    pointsArray[pointNumberChange][0]-=1;
  }
  if (keyCode == RIGHT) {
    pointsArray[pointNumberChange][0]+=1;
  }
}





// ==================================================
// Super Fast Blur v1.1
// by Mario Klingemann 
// <http://incubator.quasimondo.com>
// ==================================================
void fastblur(PImage img, int radius)
{
  if (radius<1) {
    return;
  }
  int w=img.width;
  int h=img.height;
  int wm=w-1;
  int hm=h-1;
  int wh=w*h;
  int div=radius+radius+1;
  int r[]=new int[wh];
  int g[]=new int[wh];
  int b[]=new int[wh];
  int rsum, gsum, bsum, x, y, i, p, p1, p2, yp, yi, yw;
  int vmin[] = new int[max(w, h)];
  int vmax[] = new int[max(w, h)];
  int[] pix=img.pixels;
  int dv[]=new int[256*div];
  for (i=0;i<256*div;i++) {
    dv[i]=(i/div);
  }

  yw=yi=0;

  for (y=0;y<h;y++) {
    rsum=gsum=bsum=0;
    for (i=-radius;i<=radius;i++) {
      p=pix[yi+min(wm, max(i, 0))];
      rsum+=(p & 0xff0000)>>16;
      gsum+=(p & 0x00ff00)>>8;
      bsum+= p & 0x0000ff;
    }
    for (x=0;x<w;x++) {

      r[yi]=dv[rsum];
      g[yi]=dv[gsum];
      b[yi]=dv[bsum];

      if (y==0) {
        vmin[x]=min(x+radius+1, wm);
        vmax[x]=max(x-radius, 0);
      }
      p1=pix[yw+vmin[x]];
      p2=pix[yw+vmax[x]];

      rsum+=((p1 & 0xff0000)-(p2 & 0xff0000))>>16;
      gsum+=((p1 & 0x00ff00)-(p2 & 0x00ff00))>>8;
      bsum+= (p1 & 0x0000ff)-(p2 & 0x0000ff);
      yi++;
    }
    yw+=w;
  }

  for (x=0;x<w;x++) {
    rsum=gsum=bsum=0;
    yp=-radius*w;
    for (i=-radius;i<=radius;i++) {
      yi=max(0, yp)+x;
      rsum+=r[yi];
      gsum+=g[yi];
      bsum+=b[yi];
      yp+=w;
    }
    yi=x;
    for (y=0;y<h;y++) {
      pix[yi]=0xff000000 | (dv[rsum]<<16) | (dv[gsum]<<8) | dv[bsum];
      if (x==0) {
        vmin[y]=min(y+radius+1, hm)*w;
        vmax[y]=max(y-radius, 0)*w;
      }
      p1=x+vmin[y];
      p2=x+vmax[y];

      rsum+=r[p1]-r[p2];
      gsum+=g[p1]-g[p2];
      bsum+=b[p1]-b[p2];

      yi+=w;
    }
  }
}


