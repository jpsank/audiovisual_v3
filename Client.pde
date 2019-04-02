class Client {
  
  String songfolder;
  ArrayList<String> songfiles;
  int sidx;
  
  String title = "";
  boolean hide = false;
  
  boolean skip = false;
  
  boolean searching = false;
  String search = "";
  String searchChoice = "";
  
  Visualizer viz;
  
  Client() {
  }
  
  void selectMusicFolder(File selection) {
    songfolder = selection.getAbsolutePath();
    
    songfiles = new ArrayList<String>();
    recurseDirMP3(songfiles,songfolder);
    Collections.shuffle(songfiles);
    
    sidx = 0;
    play(sidx);
  }
  
  void step() {
    if (viz != null) {
      if (searching) {
        
        background(0);
        if (search.equals("")) {
          textSize(72);
          textAlign(CENTER, CENTER);
          fill(100);
          text("search",0,0,width,height);
        } else {
          textSize(72);
          textAlign(CENTER, CENTER);
          fill(255);
          text(search,0,0,width,height);
          
          if (!search.equals(searchChoice)) {
            textSize(56);
            textAlign(CENTER, CENTER);
            fill(255);
            text(searchChoice,0,height/2,width,height/2);
          }
        }
      } else {
        if (skip) {
          viz.song.skip(5000);
        } else {
          pushMatrix();
          viz.step();
          popMatrix();
          
          if (!hide) {
            textSize(12);
            textAlign(LEFT, BASELINE);
            fill(255);
            text(title,20,20);
            textAlign(RIGHT, BASELINE);
            fill(255,255-50*(FPS-frameRate),255-50*(FPS-frameRate));
            text(frameRate,width-20,20);
            if (frameRate <= FPS-10) {
              println("frameRate warning:",frameRate);
            }
          }
          
          if (viz.done) {
            next();
          }
        }
      }
      //saveFrame("output/" + title + "_#####.png");
    }
  }
  
  void play(int idx) {
    if (viz != null) {
      viz.song.pause();
    }
    
    idx = idx % songfiles.size();
    String fn = songfiles.get(idx);
    viz = new Visualizer(fn);
    
    AudioMetaData metadata = viz.song.getMetaData();
    String t = metadata.title();
    String a = metadata.author();
    
    if (t != "" && a != "") {
      title = t+"\n"+a;
    } else {
      String[] splt = split(songfiles.get(idx),'/');
      title = splt[splt.length-1];
    }
    println("Playing",title);
  }
  
  void next() {
    sidx++;
    play(sidx);
    background(0);
  }
  
  ArrayList<String> getSongNames() {
    ArrayList<String> names = new ArrayList<String>();
    for (int i=0; i<songfiles.size(); i++) {
      String[] splt = split(songfiles.get(i),'/');
      String sn = splt[splt.length-1];
      names.add(sn.toLowerCase());
    }
    return names;
  }
  
  void searchKeyPress() {
    if (keyCode == BACKSPACE) {
      if (search.length() > 0) {
        search = search.substring(0, search.length()-1);
      }
    } else if (keyCode == DELETE) {
      search = "";
    } else if (keyCode != SHIFT && keyCode != CONTROL && keyCode != ALT && keyCode != ENTER) {
      search = search + key;
    }
    
    ArrayList<String> songnames = getSongNames();
    searchChoice = "";
    for (String sn: songnames) {
      if (sn.contains(search)) {
        searchChoice = sn;
        break;
      }
    }
    
    if (key == ENTER) {
      if (songnames.contains(search)) {
        sidx = songnames.indexOf(search);
        
        searching = false;
        search = "";
        play(sidx);
        background(0);
      } else {
        search = searchChoice;
      }
    }
  }
  
  void keyPress() {
    if (searching) {
      searchKeyPress();
    } else if (viz != null) {
      if (key == CODED) {
        if (keyCode == RIGHT) {
          skip = true;
        }
      }
      if (key == TAB) {
        next();
      } else if (key == 'h') {
        hide = !hide;
      } else if (key == ENTER) {
        searching = true;
        viz.song.pause();
      }
    }
  }
  void keyRelease() {
    if (viz != null) {
      if (key == CODED) {
        if (keyCode == RIGHT) {
          skip = false;
        }
      }
    }
  }
}  
