class Client {
  
  String songfolder;
  ArrayList<String> songfiles;
  int sidx;
  
  String title = "";
  boolean hide = false;
  
  boolean skip = false;
  
  Visualizer viz;
  
  Client() {
  }
  
  void selectMusicFolder(File selection) {
    songfolder = selection.getAbsolutePath();
    
    songfiles = new ArrayList<String>();
    recurseDirMP3(songfiles,songfolder);
    Collections.shuffle(songfiles);
    
    sidx = -1;
    next();
  }
  
  void step() {
    if (viz != null) {
      if (skip) {
        viz.song.skip(5000);
      } else {
        pushMatrix();
        viz.step();
        popMatrix();
        
        if (!hide) {
          text(title,20,20);
        }
        
        if (viz.done) {
          next();
          background(0);
        }
      }
    }
  }
  
  void next() {
    if (viz != null) {
      viz.song.pause();
    }
    
    sidx = (sidx+1) % songfiles.size();
    viz = new Visualizer(songfiles.get(sidx));
    
    AudioMetaData metadata = viz.song.getMetaData();
    String t = metadata.title();
    String a = metadata.author();
    
    if (t != "" && a != "") {
      title = t+"\n"+a;
    } else {
      String[] splt = split(songfiles.get(sidx),'/');
      title = splt[splt.length-1];
    }
  }
  
  void keyPress() {
    if (viz != null) {
      if (key == CODED) {
        if (keyCode == RIGHT) {
          skip = true;
        }
      }
      if (key == TAB) {
        next();
        background(0);
      } else if (key == 'h') {
        hide = !hide;
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
