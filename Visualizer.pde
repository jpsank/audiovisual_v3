class Line {
  float x,y,a;
  Line(float x_, float y_, float a_) {
    x = x_;
    y = y_;
    a = a_;
  }
  
  void update() {
    if (x > width) {
      a = -a+PI;
      x = 2*width-x;
      //vX *= -1;
    } else if (x < 0) {
      a = -a+PI;
      x = -x;
      //vX *= -1;
    }
    if (y > height) {
      a *= -1;
      y = 2*height-y;
      //vY *= -1;
    } else if (y < 0) {
      a *= -1;
      y = -y;
      //vY *= -1;
    }
  }
  
}


class Visualizer {
  
  boolean done;
  int idx = 0;
  int fftLen = 128;
  float weightedIdx = 0;
  
  AudioPlayer song;
  FFT fft;
  
  Line[] lines;
  int numLines = 18;
  float lineSize;
  
  
  float fftSum;
  
  Visualizer(String fp) {
    
    lines = new Line[numLines];
    for (int i=0; i<lines.length; i++) {
      lines[i] = new Line(width/2,height/2,TWO_PI*i/lines.length);
    }
    
    song = minim.loadFile(fp);
    fft = new FFT(song.bufferSize(), song.sampleRate());
    fft.linAverages(fftLen);
    
    song.play();
    done = false;
  }
  
  void step() {
    if (!song.isPlaying()) {
      done = true;
    }
    
    fft.forward(song.mix);
    
    float lastSum = fftSum;
    fftSum = 0;
    float[] avgs = new float[fftLen];
    for(int i = 0; i < fftLen; i++) {
      float a = fft.getAvg(i);
      avgs[i] = a;
      fftSum += avgs[i];
    }
    
    
    int interval = floor(float(avgs.length)/3);
    float avg1 = sum(subset(avgs,0,interval))/interval;
    float avg2 = sum(subset(avgs,interval,interval))/interval;
    float avg3 = sum(subset(avgs,interval*2,interval))/interval;
    float maxavg = max(avg1,avg2,avg3);
    
    float red = avg1*(255/(1+maxavg*.2));
    float green = avg2*(255/(1+maxavg*.2));
    float blue = avg3*(255/(1+maxavg*.2));
    
    lineSize = 1+(fftSum/fftLen);
    
    if (abs(fftSum-lastSum)/fftLen > .75 || abs(fftSum-lastSum)/lastSum >= 1.75) {
      background(red/4,green/4,blue/4);
    } else {
      background(0);
    }
    
    
    float screenRotate = random(-1,1) * pow(fftSum/4000,2);
    translate(width/2,height/2);
    rotate(screenRotate);
    translate(-width/2,-height/2);
    
    float screenShake = 4*fftSum/fftLen;
    translate(random(-screenShake,screenShake),random(-screenShake,screenShake));
    
    for (int i=0;i<fftLen;i++) {
      
      float pos = (float)i/fftLen;
      
      float size = avgs[i]*(.2+4*pos);
      color fill = color(red, green, blue + i);
      float weight = pow(avgs[i]*(1+4*pos),1.5);
      float angle = TWO_PI*sin( weightedIdx/100. + sqrt(fftSum/fftLen)*pos );
      
      for (Line line: lines) {
        float a2 = line.a + angle;
        
        float x = line.x + cos(a2)*i*lineSize;
        float y = line.y + sin(a2)*i*lineSize;
        stroke(fill);
        strokeWeight(weight/2);
        strokeCap(SQUARE);
        line(x, y, x + cos(line.a)*(size/2), y + sin(line.a)*(size/2));
        stroke(fill,125);
        strokeWeight(weight);
        strokeCap(SQUARE);
        line(x, y, x + cos(line.a)*(size), y + sin(line.a)*(size));
        
        stroke(fill,10+10*avgs[i]);
        strokeWeight(100+avgs[i]*pos);
        strokeCap(SQUARE);
        line(x, y, x + cos(line.a)*(size), y + sin(line.a)*(size));
        
        x = line.x + cos(line.a)*i*(lineSize);
        y = line.y + sin(line.a)*i*(lineSize);
        stroke(fill,10+10*avgs[i]);
        strokeWeight(100+avgs[i]*pos);
        strokeCap(SQUARE);
        line(x, y, x + cos(line.a)*(size), y + sin(line.a)*(size));
        
        //if (i==fftLen-1) {
        //  int len = 4;
        //  noStroke();
        //  ellipseMode(CENTER);
        //  for (int j=0; j<len; j++) {
        //    float pos2 = (float)j/len;
        //    fill(red, green, blue, 255*pow(1-pos2,5/(avg1-avg3)));
        //    float rad = pow(.5+pos2,2)*50*fftSum/fftLen;
        //    ellipse(x,y, rad,rad);
        //  }
        //}
        
      }
    }
    
    for (int i=0; i<lines.length; i++) {
      Line line = lines[i];
      
      float s = pow(fftSum/fftLen,2)*2;
      line.x += cos(line.a)*s;
      line.y += sin(line.a)*s;
      line.update();
      
      int len = 4;
      ellipseMode(CENTER);
      for (int j=0; j<len; j++) {
        float pos = (float)j/len;
        float size = pow(.5+pos,2)*10*fftSum/fftLen;
        float x = line.x+cos(line.a)*(lastSum+fftSum)/2;
        float y = line.y+sin(line.a)*(lastSum+fftSum)/2;
        
        fill(red, green, blue, 255*pow(1-pos,5/(avg1-avg3)));
        strokeWeight(size*5);
        stroke(red, green, blue + 100, 10+fftSum/fftLen);
        
        ellipse(x,y, size,size);
      }
      
    }
    
    idx++;
    weightedIdx += fftSum/fftLen;
    
  }
  
}
