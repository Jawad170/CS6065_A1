import ddf.minim.*;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.util.Date;
import java.text.SimpleDateFormat;
import static javax.swing.JOptionPane.*;

float d, X, Y;  //Circle Diameter, X and Y Positions
float r, g, b;  //Circle Color when not selected
float R, G, B;  //Circle Color when hovered over

PImage img;  //image file for Trump E-Egg

BufferedWriter dataFile = null;

//Sound Effect Variables
Minim minim;
AudioSnippet SF_Click, SF_Hover, SF_Miss;

PFont font     ;
int   score    ;
int   missclick;
int   LastMissC;
float startTime;
float time     ;

int UserID = -1;

void setup()
{
  
  size        (900,720);
  background  (50)     ;
  
  String pwd = sketchPath();
  String[] files = listFileNames(pwd);
  String dataFileBaseName = "data";
  int duplicateDataFileCounter = 0;
  
  SimpleDateFormat ft = new SimpleDateFormat("yyyy-MM-dd");
  String today = ft.format(new Date());
  
  for( String file: files ) {
    if( file.matches( dataFileBaseName + "-" + today + "(.*)" ) ) {
          duplicateDataFileCounter++;
    }
  }
  
  String dataFileName = dataFileBaseName + today + duplicateDataFileCounter + ".csv";
  try {
    System.out.println( "Creating: " + dataFileName );
    System.out.println( "In directory: " + pwd );
    dataFile = new BufferedWriter( new FileWriter( dataFileName ) );
    dataFile.write("user, block, trial, targetRadius, targetDistance, elapsedTime, numberOfErrors");
    dataFile.flush();
  } catch( Exception e ){
    System.out.println( e );
    exit();
  } finally {
    if( dataFile != null ) {
      try {
        dataFile.close();
      } catch( IOException e ) {
        println( e );
        exit();
      }
    }
  }
    
  //TODO jwuertz Add a check to make sure that we actually entered a number.
  String userInput = showInputDialog("Please enter your ID");
  try {
    UserID = Integer.parseInt(userInput); 
  } catch( Exception e ) {
    System.out.println(e);
    exit();
  }
  
  System.out.println("Game Trial Started For USER ID: " + UserID + " . . . \n\n");
  
  NewTarget   (  )     ;
  
  r = 150; g = 150; b = 150;
  R = 100; G = 200; B = 100;
  
  score     = 0;
  missclick = 0;
  LastMissC = 0;
  
  font = createFont("Calibri",20,true);
  
  startTime = 60;
  
  minim = new Minim(this);
  
  SF_Hover = minim.loadSnippet("Blip_Select35.wav");
  SF_Click = minim.loadSnippet("Pickup_Coin15.wav");
  SF_Miss  = minim.loadSnippet("Laser_Shoot3.wav" );
  
}

void draw()
{
  background(50);
  DrawCircle();
  //DrawTrump();
  ShowScore() ;
  ShowTimer() ;
  CheckTime() ;
}

private float LastTime = 0;
void mousePressed()
{
  if ( time > 0.0f)
  {
    if ( CheckMouseOver() ) 
    {
      String T = String.format("%.02f", ((millis()/1000.0f)-LastTime));
      String D = String.format("%.02f", (GetDistance()));
      System.out.println(UserID+ "\t" + (GameCount+1) + "\t" + ++score + "\t"+ D +"\t" + T + "\t" + LastMissC );
      LastTime = (millis()/1000.0f);
      LastMissC = 0;
      
      NewTarget();
      SF_Click.rewind();
      SF_Click.play();
      
      if ( score >= 10 )
      {
        score = 0;
        startTime+=60;
        Continue();
      }
    }
    else
    {
      missclick++;
      LastMissC++;
      SF_Hover.rewind();
      SF_Hover.play();
    }
  }
}

private int TotalGames = 2;
private int GameCount = 0;
void Continue()
{
  GameCount++;
  if ( GameCount < TotalGames) 
  {
    showMessageDialog(null, GameCount + " Game(s) Done, " + (TotalGames-GameCount) + " Left.\n\nContinue?", "[ "+ GameCount + " / " + (TotalGames) + " ]", INFORMATION_MESSAGE);
  }
  else 
  {
    showMessageDialog(null, GameCount + " Game Done, Thanks For Playing.", "Game Over", INFORMATION_MESSAGE); startTime = 0;
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
  
  if ( time <= 0.0f ) {
    time = 0;
    
    textFont(font, 50);               
    fill(220, 50, 50);
    text("GAME OVER", width/2,height/2); 
    if( dataFile != null ) {
      try { 
        dataFile.close();
      } catch( IOException e ) {
        println( e );
        exit();
      }
    }
  }
}

// This function returns all the files in a directory as an array of Strings  
String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}

private float LastY = -1;
private float LastX = -1;
float GetDistance()
{
  if ( LastX == -1 ) 
  {
    LastY = Y;
    LastX = X;
    return 0;
  }
  
  float D = 0;
  double distance = Math.hypot(X - LastX, Y - LastY);
  D = (float) distance;
  
  LastY = Y;
  LastX = X;
  
  return D;
}