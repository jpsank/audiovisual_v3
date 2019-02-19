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
  int fftLen = 256;
  float weightedIdx = 0;
  
  AudioPlayer song;
  FFT fft;
  
  int[] array1d;
  
  Line[] lines;
  int numLines = 18;
  float lineSize;
  
  
  float fftSum;
  
  Visualizer(String fp) {
    
    array1d = new int[fftLen];
    //for (int i=0; i<array1d.length; i++) {
    //  array1d[i] = (int)random(2);
    //}
    array1d[(int)(array1d.length/2)] = 1;
    
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
      fftSum += a;
    }
    
    
    int interval = floor(float(avgs.length)/3);
    float avg1 = sum(subset(avgs,0,interval))/interval;
    float avg2 = sum(subset(avgs,interval,interval))/interval;
    float avg3 = sum(subset(avgs,interval*2,interval))/interval;
    float maxavg = max(avg1,avg2,avg3);
    
    float red = avg1/maxavg*255;
    float green = avg2/maxavg*255;
    float blue = avg3/maxavg*255;
    
    lineSize = 1+(fftSum/fftLen);
    
    if (abs(fftSum-lastSum)/fftLen > .25 || abs(fftSum-lastSum)/lastSum >= 1.25 || fftSum/fftLen < 1) {
      background(0);
    }
    
    float screenShake = 4*fftSum/fftLen;
    translate(random(-screenShake,screenShake),random(-screenShake,screenShake));
    
    float screenRotate = random(-1,1) * pow(fftSum/4000,2);
    rotate(screenRotate);
    
    int[] ruleset = new int[8];
    for (int i=0; i<8; i++) {
      int subsize = avgs.length/8;
      ruleset[i] = (int)sum(subset(avgs,subsize*i,subsize))/subsize/3;
      ruleset[i] = constrain(ruleset[i],0,1);
    }
    
    array1d[(int)(array1d.length/2)] = 1;
    
    int[] next = new int[array1d.length];
  
    for (int i=1;i<array1d.length-1;i++) {
      next[i] = array1d[i];
      
      int a,b,c;
      if (i == 0) {
        a = array1d[array1d.length-1];
      } else {
        a = array1d[i-1];
      }
      b = array1d[i];
      if (i == array1d.length-1) {
        c = array1d[0];
      } else {
        c = array1d[i+1];
      }
      
      if (a==1&&b==1&&c==1) next[i] = ruleset[4]; // (int)random(8)
      else if (a==1&&b==1&&c==0) next[i] = ruleset[2];
      else if (a==1&&b==0&&c==1) next[i] = ruleset[5];
      else if (a==1&&b==0&&c==0) next[i] = ruleset[0];
      else if (a==0&&b==1&&c==1) next[i] = ruleset[3];
      else if (a==0&&b==1&&c==0) next[i] = ruleset[6];
      else if (a==0&&b==0&&c==1) next[i] = ruleset[1];
      else if (a==0&&b==0&&c==0) next[i] = ruleset[7];
      
      // 0,1,0,1,1,0,1,0
      
      float pos = (float)i/fftLen;
      
      float size = avgs[i]*(.2+4*pos);
      color fill = color(red, green, blue + i);
      float weight = pow(avgs[i]*(.4+2*pos),2);
      float angle = TWO_PI*sin( weightedIdx/100. + sqrt(fftSum/fftLen)*pos );
      
      for (Line line: lines) {
        float a2 = line.a + angle;
        
        float x = line.x + cos(a2)*i*lineSize - cos(a2)*avgs[i];
        float y = line.y + sin(a2)*i*lineSize - sin(a2)*avgs[i];
        stroke(fill);
        strokeWeight(weight/2);
        strokeCap(SQUARE);
        line(x, y, x + cos(line.a)*(size/2), y + sin(line.a)*(size/2));
        stroke(fill,125);
        strokeWeight(weight);
        strokeCap(SQUARE);
        line(x, y, x + cos(line.a)*(size), y + sin(line.a)*(size));
        
        //stroke(fill,125);
        //strokeWeight(size);
        //strokeCap(SQUARE);
        //line(x, y, x + cos(line.a)*(weight/2), y + sin(line.a)*(weight/2));
      }
    }
    array1d = next;
    
    for (int i=0; i<lines.length; i++) {
      Line line = lines[i];
      float s = pow(fftSum/fftLen,2)*2;
      line.x += cos(line.a)*s;
      line.y += sin(line.a)*s;
      line.update();
    }
    
    idx++;
    weightedIdx += fftSum/fftLen;
    
  }
  
}
