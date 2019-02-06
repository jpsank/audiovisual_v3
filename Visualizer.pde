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
  
  AudioPlayer song;
  FFT fft;
  
  int[] array1d;
  
  Line[] lines;
  int numLines = 18;
  float lineSize;
  
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
    
    float fftSum = 0;
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
    
    float red = avg1/maxavg*200;
    float green = avg2/maxavg*200;
    float blue = avg3/maxavg*200;
    
    lineSize = 1+sqrt(fftSum/fftLen);
    
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
      
      for (Line line: lines) {
        //float angle = line.a + ((float)idx/40) + fftSum/fftLen/2;
        float size = lineSize + avgs[i]*i/fftLen;
        float angle = line.a + ( (float)i/fftLen*fftSum/fftLen ) * (sin((float)idx/50)); // * ((i%2)*2-1)
        color fill = color(red + pow(avgs[i]*fftSum/fftLen,2), green + pow(fftSum/fftLen*(1+5*i/fftLen),2), blue + i);
        float weight = next[i]+pow(avgs[i],1.25+2*i/fftLen);
        stroke(fill,125);
        strokeWeight(weight);
        strokeCap(SQUARE);
        line(line.x+cos(angle)*i*size*2, line.y+sin(angle)*i*size*2, line.x+cos(angle)*(i+1)*size*2, line.y+sin(angle)*(i+1)*size*2);
        stroke(fill);
        strokeWeight(weight/2);
        strokeCap(SQUARE);
        line(line.x+cos(angle)*i*size, line.y+sin(angle)*i*size, line.x+cos(angle)*(i+1)*size, line.y+sin(angle)*(i+1)*size);
      }
    }
    array1d = next;
    
    for (Line line: lines) {
      float s = pow(fftSum/fftLen,2);
      line.x += cos(line.a)*s;
      line.y += sin(line.a)*s;
      line.update();
    }
    
    //brain.randomChange();
    
    idx++;
    
  }
  
}
