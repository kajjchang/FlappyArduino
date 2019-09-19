import processing.serial.*;
import cc.arduino.*;

Arduino arduino;
float x, y;
float velocity;
float dt = 1.0 / 60.0;
float lastSound = 0.0;
float gravity = 50.0;
float pipeX, pipeY;
float pipeOpening = 150.0;
float pipeWidth = 50.0;
float pipeSpeed = 1.0;
float birdSize = 50.0;
int score;
boolean inGame;

public void setup() {
  size(750, 500);
  initGame();
  println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[Arduino.list().length - 1], 57600);
}

public void initGame() {
  y = height / 2;
  x = width / 8;
  velocity = 0.0;
  pipeX = width;
  pipeY = height / 2 - pipeOpening / 2;
  inGame = false;
  score = 0;
}

public void draw() {
  background(200);
  fill(0, 255, 0);
  rect(pipeX - pipeWidth, 0, pipeWidth, pipeY);
  rect(pipeX - pipeWidth, pipeY + pipeOpening, pipeWidth, height - pipeY - pipeOpening);
  pipeX -= pipeSpeed;
  if (pipeX <= 0) {
    pipeX = width;
    if (inGame) {
      pipeY = random(150, height - 150);
      score++;
    } else {
      pipeY = height / 2 - 50.0;
    }
  }
  fill(50);
  ellipse(x, y, birdSize, birdSize);
  if (inGame) {
    int sound = arduino.analogRead(4);
    if (lastSound > 0) {
      float acceleration = gravity - Math.max(sound - lastSound, 0);
      velocity += (acceleration * dt);
      y += (velocity * dt);
      // println(acceleration + "\t" + velocity + "\t" + y);
    }
    lastSound = sound;
    textSize(32);
    text("Score: " + score, width / 8, height / 8);
  } else {
    textAlign(CENTER);
    textSize(32);
    text("Press a Button to Start, Make Sound to Flap", width / 2, height / 4);
  }
  if (arduino.analogRead(1) > 500 || arduino.analogRead(6) > 500) {
    inGame = true;
  }
  if (y - birdSize / 2 < 0 || y + birdSize / 2 > height) {
    initGame();
  }
  if (x + birdSize >= pipeX - pipeWidth / 2 && x - birdSize <= pipeX + pipeWidth / 2) {
    if (y + birdSize / 2 >= pipeY + pipeOpening || y - birdSize / 2 <= pipeY) {
      initGame();
    }
  }
}
