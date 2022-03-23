
float[][] kernel = {{ -1, -1, -1}, 
  { -1, 9, -1}, 
  { -1, -1, -1}};
int prev = 0;
float xoff=0.0,yoff=0.0;
/* adjustable */
int dr=0;//filter & draw = 1;filter only = 0
float ress=47; //some sort of resolution for filter
int ron = 1; //1 = random angles; 0 = noise angles
float noiz=0.001;//noise level

int lmax =15;//line length; (usually, your final screen width divided by 64 is optimal)
int lmin = 2;
int density=2; //smaller values = greater density of the drawing, NEVER lower than 1
float pressure=5; //"pen pressure"; (line length divided by 4 is mostly optimal)
float lthick=0.2; //line thicc-ness; (usually your line length divided by 20 is optimal)
int lpp=18; // lines per point; 1<= lpp <= 360

int fq=1; //filter quality, does the same thing as density but for the filter
                //you can change this but i usualyy have it match the density
                //, NEVER lower than 1
void setup() {
  PImage pic = loadImage("pic.jpeg") ;//put the image in the same folder as the sketch
  //and type its name in the field above
  println("Use these values in the SIZE function: "+pic.width+" x "+pic.height);

  size(960, 1280);//run the program once and find the correct values for
  //width and height in the command line
  image(pic, 0, 0,width,height);
  int[][] spoints = new int[width][height];
  float[] spixels = new float[height*width];
  colorMode(HSB, 360, 100, 100);
  loadPixels();
  for ( int y = 0; y<height; y++)
  {
    for ( int x = 0; x<width; x++)
    {
      float sum = 0;
      for (int ky = -1; ky <= 1; ky++) 
      {
        for (int kx = -1; kx <= 1; kx++) 
        {
          int pos = (y + ky*fq)*width + x + kx*fq;
          if((pos>=0)&&(pos<height*width))
          {
          float val = brightness(pixels[pos]);
          sum+= kernel[ky+1][kx+1] * val;
          }
          
        }
      }
      if (sum<=ress)
      {
        sum=0;
        spoints[x][y]=1;
      } else {
        sum=100;
        spoints[x][y]=0;
      }
      spixels[y*width + x] = sum;
    }
  }

  for ( int y = 0; y<height; y++)
  {
    for ( int x = 0; x<width; x++)
    {
      pixels[x + y*width]= color(100, 0, spixels[ x + y*width]);
    }
  }
  updatePixels();
  if(dr==1)
  {
  background(0, 0, 100);//change the colour as you wish; (hint: its in H S B form)
 //59, 10, 95
  println("loading... 0 %");
  for (int y = 0; y<height; y+=density)
  {
    xoff=0.0;
    for (int x = 0; x<width; x+=density)
    {
      if (spoints[x][y]==1)
      {
        for(int ln=lmax;ln>=lmin;ln-=1)
        {
        int drawn=0;
        int sa=0;
        if(ron==1)
        {
          sa=int(random(360)) + 1;
        }else{
        sa=int(map(noise(xoff,yoff),0,1,-180,540));
        }
        
        for (int a = sa; a<sa+360; a+=int(360/lpp))
        {
          if(drawn<=lpp-1)
          {
          int xx=0;
          int yy=0;
          xx= (int)(Math.cos(Math.toRadians(a))*float(ln));
          yy= (int)(Math.sin(Math.toRadians(a))*float(ln));
          float offx=0.0,offy=0.0,offxx=0.0,offyy=0.0;
          offx= random(2*density)+1-density;
          offy= random(2*density)+1-density;
          offxx= random(2*density)+1-density;
          offyy= random(2*density)+1-density;
          
          if((x+xx>0)&&(x+xx<width)&&(y+yy>0)&&(y+yy<height))
          {
          if(spoints[x+xx][y+yy]==1)
          {
            strokeWeight(lthick);
            stroke(0,0,0,pressure);//change the colour to whatever you choose
            //NB, it is in H S B format, with "pressure" in the as the alpha parameter
            //which can be changed at the top of the code
            //59,36,86
            line(x+offx,y+offy,x+xx+offxx,y+yy+offyy);
            drawn++;
          }
          }
          }
        }
      }
        spoints[x][y]=0;
      }
      xoff+=noiz;
    }
    int pp = 0;
    pp=(int)ceil(y*100/height);
    if(pp!=prev)
    {
    println("loading... "+pp+" %");
    }
    prev = pp;
    yoff+=noiz;
  }
  println("loading... 100 %");
  println("image load complete!");
  }
}

void draw()
{
}

void mouseClicked()
{
  save(str(year())+str(month())+str(day())+"/"+str(hour())+str(minute())+str(second())+".png");
}
