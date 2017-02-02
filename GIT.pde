import ddf.minim.*;
import static javax.swing.JOptionPane.*;

float d, X, Y;  //Circle Diameter, X and Y Positions
float r, g, b;  //Circle Color when not selected
float R, G, B;  //Circle Color when hovered over

PImage img;  //image file for Trump E-Egg

//Sound Effect Variables
Minim minim;
AudioSnippet SF_Click, SF_Hover, SF_Miss;

PFont font     ;
int   score    ;
int   missclick;
float startTime;
float time     ;

int UserID = -1;

void setup()
{
  
  size        (900,720);
  background  (50)     ;
  
  UserID = Integer.parseInt(showInputDialog("Please enter new ID", "24601"));
  
  NewTarget   (  )     ;
  
  r = 150; g = 150; b = 150;
  R = 100; G = 200; B = 100;
  
  score     = 0;
  missclick = 0;
  
  font = createFont("Calibri",20,true);
  
  startTime = 60;
  
  minim = new Minim(this);
  
  SF_Hover = minim.loadSnippet("Blip_Select35.wav");
  SF_Click = minim.loadSnippet("Pickup_Coin15.wav");
  SF_Miss  = minim.loadSnippet("Laser_Shoot3.wav" );
  
}

void draw()
{
  if ( UserID < 0 )   randomCircles();
  background(50);
  DrawCircle();
  //DrawTrump();
  ShowScore() ;
  ShowTimer() ;
  CheckTime() ;
}

void mousePressed()
{
  if ( time > 0.0f)
  {
    if ( CheckMouseOver() ) 
    {
      NewTarget();
      score++;
      SF_Click.rewind();
      SF_Click.play();
    }
    else
    {
      missclick++;
      SF_Hover.rewind();
      SF_Hover.play();
    }
  }
}

boolean CheckMouseOver()
{
  float disX = X - mouseX;
  float disY = Y - mouseY;
  
  if (sqrt(sq(disX) + sq(disY)) < d/2 ) 
       return true ; 
  else return false;
  
}

//Defines a new Circle at a random location
void NewTarget()
{
  //Diameter of the circle
  d = random(20, 200);
  
  //X and Y values within the screen + offset for the size of the circle
  X = random((d/2) , width  - (d/2));
  Y = random((d/2) , height - (d/2));
}


private boolean hovering = false;
void DrawCircle()
{
  if ( time > 0.0f)
  {
    if ( CheckMouseOver() && !hovering )
    {
      hovering = true;
      SF_Miss.rewind();
      SF_Miss.play();
    }
    else if ( !CheckMouseOver() && hovering )
    {
      hovering = false;
    }
    if ( CheckMouseOver() ) fill(R, G, B); else fill(r, g, b);
    ellipse(X,Y,d,d);
  }
}

void DrawTrump()
{
  if ( time > 0.0f)
  {
    if ( CheckMouseOver() ) img = loadImage("competitor-head-trump.png"); else img = loadImage("unnamed.png");;
  
    image(img, X-(d/2),Y-(d/2),d,d);
  }
}

void ShowScore()
{
  textFont(font, 20);               
  fill(220);
  text("Targets Hit [ " + score + " ] ", 25,50); 
  
  if ( missclick > 0 )
  {
    fill(200, 100, 100);
    text(" [ " + missclick + " : missed ] ", 175,50); 
  }
}

void ShowTimer()
{
  textFont(font, 20);               
  fill(220);
  text(time,   width-100,50); 
  text("time", width-95 ,30); 
}

void CheckTime()
{
  time = startTime - (millis()/1000.0f);
  
  if ( time <= 0.0f )
  {
    time = 0;
    
  textFont(font, 50);               
  fill(220, 50, 50);
  text("GAME OVER", width/2,height/2); 
  }
}




void randomCircles()
{
  float rX = random(0, width);
  float rY = random(0, height);
  float rd = random(10,400);
  
  float rR = random(0,255);
  float rG = random(0,255);
  float rB = random(0,255);
  
  fill(rR, rG, rB);
  ellipse(X,Y,d,d);
}