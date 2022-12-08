// PARAMETERS TO ALTER DRAWING
//parameters for function
float amp = 30;               // height of function
float convergence = -0.02;    // how long until converges, closer to zero -> longer
float period = 0.2;           // distance of one wave

int ifr = 120;                // frame rate int
float ffr = 120.0;            // frame rate float

boolean userInputEnabled = true;

//starting coordinates
float x = 30;                 // where drawing starts
float y = 30;

//range for drawing
float max = 30;               // highest possible y value for line
float min = 1050;             // lowest possible y value for line

// FOR CODE
//for function plotting
float fx, fy;                 // x and y coords for function
float px, py;                 // plotted x and y

//toggles for turning properly
boolean isTop;                // true if at top, false otherwise
int atCorner;               
float direction = 1;          // start going down

//tracks which second we are on
int secIndex;

//store final image
int month;
int day;
int year;
String filename;

//read in times
String taskTimesFile = "TaskTimes.csv";
String[] taskTimes;           // will store times as string list
int taskIndex;                // index for which task we are on
int curTaskTime;              // total time spent on current task
int minPassed;                // minutes passed in this task


void setup() {
  size(1920, 1080);
  background(255);
  frameRate(ifr);

  if(!userInputEnabled){
    taskIndex = 0;
    taskTimes = loadStrings(taskTimesFile);
    curTaskTime = int(taskTimes[taskIndex]);
  }
}


void draw() {
  strokeWeight(1);
  stroke(0, 0, 0);

  // UPDATE COORDINATES
  if (secIndex != second()) {
    // update second we are on
    secIndex = second();

    // continue horizontally
    if (atExtremum(y)) {
      horizontalLine(px, py);
    }
    // continue vertically
    else {
      y = y + direction;
    }

    // use input to toggle activity
    toggleTasks(taskTimes);
    
    // take screenshot at end
    if(x==1890 && y==min){
      noLoop();
      day = day();
      month = month();
      year = year();
      filename = day + "-" + month + "-" + year + "_" + "Final.png";
      saveFrame(filename);
    }
  }

  // calculate function constantly
  fx = fx + 1.0/ffr;
  // past four minutes, draw straight line
  fy = (fx < 240) ? (amp * exp(convergence*fx) * sin(period*fx)) : 0;

  // scale by x and y
  px = x + fy;
  py = y;

  point(px, py);
}


void keyPressed() {
  if (userInputEnabled) {
    fx = 0;
  }
}

//
void toggleTasks(String[] taskTimes) {
  if (second()==0) {
    minPassed++;
    if (minPassed==curTaskTime) {
      //reset
      fx = 0;
      minPassed = 0;
      //move on to next task
      taskIndex++;
      curTaskTime = int(taskTimes[taskIndex]);
    }
  }
}

// returns whether we are at end of range
// sets topBottom to true if at top, false if at bottom
boolean atExtremum(float y) {
  if (y==max) {
    isTop = true;
    return true;
  } else if (y==min) {
    isTop = false;
    return true;
  }
  return false;
}

// returns true if should draw line, at beginning corner
// returns false if at end of corner, move on to vertical
boolean drawLine(float x) {
  // corners are at x%30=0
  if (x%30==0) {
    if (x%60==0) {
      // if top at beginning of turn, if bottom end
      return (isTop) ? true : false;
    } else {
      // if bottom at end of turn, if top beginning
      return (isTop) ? false : true;
    }
  }
  return false;
}

//must be at extremum, draws horizontal line and changes direction
void horizontalLine(float px, float py) {
  if (drawLine(x)) {
    x += 30;
    direction = -1*direction;
    y += direction;
    line(px, py, px+30, py);
  } else {
    y += direction;
  }
}
