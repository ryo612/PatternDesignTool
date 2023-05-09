import android.os.Environment;
import android.content.Context; 
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import android.app.Activity;
import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorManager;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;

int i=0;
int j=0;
int page=0;

float r=35;//直径(○は35,四角は19)
int n=5000;//円の数
float interval;

//by tsuka
float lensSize = 15; // mm
float pysicalWidth =  680;// mm
//float pysicalHeight = 2500;//mmfloat lensSize = 15; // mm
float pysicalinterval =  2;// mm


int[][] pieceH= new int[n][14];//n個の丸と8個のピース、色保存の配列
int[][] pieceS= new int[n][14];//n個の丸と8個のピース、色保存の配列
int[][] pieceB= new int[n][14];//n個の丸と8個のピース、色保存の配列
color[][] c=new color[n][14];
color[] cimg=new color[n];//画像のピクセルデータ
int count=0;
int savecount=0;
int[] pagechk= {0, 0, 0, 0, 0, 0, 0, 0};//ページが記入済かどうか

int pageY=220;//ボタンのスペース
int button=80;//ボタンサイズ
int margin=40;//ボタン余白
int pieceDiv=8;
int div=2;

PImage img;
PImage mask;
PImage paint;
PImage eraser;
PImage col;
PImage pict;
PImage del;
PImage home;
PImage system;
PImage yajirushi;
PImage[] pic=new PImage[6];//画像一覧の画像

int xp=250;
int xe=xp+100+10;
int xc=xe+120;
int xpi=xc+120;
int xd=xpi+120;
int xsy=xd+120;

int PorE=0;//0でペイント、1で消しゴム
int palette=0;//カラーパレットのオン(1)オフ(0)
int setting=0;//設定画面切り替え、0オフ、1メニュー、2サイズ、3分割数
int Img=0;//画像オンオフ
int ImgPage=0;//画像表示してるページ

float positionX=-107;
float positionY=-134;
float positionXsave=0;
float positionYsave=0;
int xcount=-107;
int ycount=-134;

//----------カラーパレット-----------

int [] ccc={1, 0, 0};//hsvの配列

float c_box=6;//カラーパレットの大きさ

int centerX=xc+50;//カラーパレットの中心
int centerY=1100;

int touchX=centerX-int(c_box)*50-50;//カラーパレットのドラッグ可能範囲
int touchY=centerY-int(c_box)*50-50;
int touchW=int(c_box)*100+100;
int touchH=int(c_box)*100+130;
int border=centerY+int(c_box)*50+10;
int circle1X=centerX-int(c_box)*50;//カラーパレットの○
int circle1Y=centerY+int(c_box)*50;
int circle2X=centerX-int(c_box)*50;
int circle2Y=centerY+int(c_box)*50+70;
int circle3X=0;
int circle3Y=0;

//----------カラーパレット-----------

//----------画像一覧-----------

int pictsize=260;
int pictmargin=60;
int pictspace=35;
int pictx;
int picty;
int pictcount=0;
String[] savepict={};//保存した画像の名前

//----------画像一覧-----------

PImage[] images = new PImage[100]; //読み込んだ画像の保存先
String[] extensions = { //操作したいファイルの拡張子を登録
  ".jpg", ".gif", ".tga", ".png"
};

//----------保存した画像のファイル名取得----------
import java.io.File;
import java.io.FilenameFilter;

public class PngFileFilter implements FilenameFilter {
  @Override
    public boolean accept(File directory, String fileName) {
    if (fileName.endsWith(".png")) {
      return true;
    }
    return false;
  }
}

File[] imageFiles;
PngFileFilter filter;
String savetxt;
int save_num=0;
String[] save_col;

/*void loadImages(File selection) {
 File[] files = selection.listFiles();   //ディレクトリ内の全てのファイル(ディレクトリも含む)を取得
 for (int i = 0; i < files.length; i++) {
 for (String extension : extensions) {
 if (files[i].getPath().endsWith(extension)) { //ファイル名の末尾が拡張子と一致するか
 images[i] = loadImage(files[i].getAbsolutePath()); //絶対パスで画像を読み込む
 }
 }
 }
 }*/

/**
 * PROCESSING 加速度・地磁気センサーSample
 * @auther MSLABO
 * @version 2018/06 1.0
 */
//センサーから読み取った値
float[] accelerometerValues  = new float[3];
float[] magneticValues = new float[3];
Activity      act;
SensorManager mSensor = null;
SensorCatch   sensorCatch = null;
float         fontSize;

//センサー読み取りクラス
//別途用意するならSensorEventListenerを実装している事
class SensorCatch implements SensorEventListener {

  //センサーの値が変化した時呼ばれるイベントメソッド
  public void onSensorChanged(SensorEvent sensorEvent) {
    //それぞれのセンサーから値を取得する
    switch(sensorEvent.sensor.getType()) {
      //加速度センサー
    case Sensor.TYPE_ACCELEROMETER:
      accelerometerValues  = sensorEvent.values.clone();
      break;

      //地磁気センサー
    case Sensor.TYPE_MAGNETIC_FIELD:
      magneticValues  = sensorEvent.values.clone();
      break;
    }
  }

  //精度が変化した時呼ばれるイベントメソッド
  public void onAccuracyChanged(Sensor sensor, int i) {
    //処理なし
  }
}

//画面表示直前イベント
public void onResume() {
  super.onResume();
  //Activityの取得
  act = getActivity();

  //センサー管理オブジェクト取得
  mSensor = 
    (SensorManager)act.getSystemService(Context.SENSOR_SERVICE);

  //センサーリスナーオブジェクト生成
  sensorCatch = new SensorCatch();

  //センサーリスナーオブジェクトをリスナーとして登録する
  //加速度センサーのリスナー登録
  mSensor.registerListener(sensorCatch, 
    mSensor.getDefaultSensor(Sensor.TYPE_ACCELEROMETER), 
    SensorManager.SENSOR_DELAY_UI);

  //地磁気センサーのリスナー登録
  mSensor.registerListener(sensorCatch, 
    mSensor.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD), 
    SensorManager.SENSOR_DELAY_UI);
}

//画面非表示時イベント
public void onPause() {
  super.onPause();

  //リスナーへのイベント通知を解除する
  if (mSensor != null) {
    mSensor.unregisterListener(sensorCatch);
  }
}

PImage[] mug=new PImage[16];//マグ画像

void setup() {
  colorMode(HSB, 100, 100, 100);

  //by tsuka
  //fullScreen();
  size(displayWidth, displayHeight);
  println(displayWidth);
  println(displayHeight);
  r =  lensSize / pysicalWidth * float(displayWidth); // lensSize /pysicalWidth = r / displayWidth
  interval =  pysicalinterval / pysicalWidth * float(displayWidth); 
  println(r);  
  for (i=0; i<n; i++) {
    for (j=0; j<14; j++) {
      pieceH[i][j]=255;
      pieceS[i][j]=0;
      pieceB[i][j]=100;
      c[i][j]=color(255, 0, 100);
      /*if(j==8){
       c[i][j]=color(0,0,100);
       }*/
    }
  }
  img=loadImage("cat.png");
  paint=loadImage("paint.png");
  eraser=loadImage("eraser.png");
  col=loadImage("col.png");
  pict=loadImage("pict.png");
  del=loadImage("del.png");
  home=loadImage("home.png");
  system=loadImage("system.png");
  yajirushi=loadImage("yajirushi.png");

  circle3X=(30+yajirushi.width*(pageY+20)/yajirushi.height+70)+(int(r)-20)*15;
  circle3Y=height-70;

  //----------保存した画像のファイル名取得----------
  filter = new PngFileFilter();
  String directory_path = new String(getContext().getExternalFilesDir(null).getAbsolutePath()); //Environment.DIRECTORY_PICTURES
  //println(directory_path);
  imageFiles = new File(directory_path).listFiles(filter);
  for (File file : imageFiles) {
    //println(file.getName());
    savepict=append(savepict, file.getName());
    save_num++;
  }



  for (i=0; i<savepict.length; i++) {
    PImage image=loadImage(directory_path + "/"+ savepict[pictcount]);
    if (image.width>image.height) {
      if (image.width/image.height>width/height) {//画像のサイズ調整
        image.resize(width, 0);
      } else {
        image.resize(0, height-pageY);
      }
    } else {
      if (image.height/image.width>height/width) {
        image.resize(0, height-pageY);
      } else {
        image.resize(width, 0);
      }
    }
    pictcount++;
  }
  pictcount=0;

  savetxt=directory_path + "/"+"save.txt";
  //String[] list={"1"};
  //saveStrings(savetxt, list);
  String[] lines = loadStrings(directory_path + "/"+"save.txt");//保存枚数テキスト読み込み
  save_num+=int(lines[0]);
  lines[0]=save_num+int(lines[0])+"";
  saveStrings(savetxt, lines);
  println(int(lines[0])+2);

  //縦置き固定
  orientation(PORTRAIT);
  for (i=0; i<mug.length; i++) {
    mug[i]=loadImage(i+1+".png");//マグ画像
    if (mug[i].width>mug[i].height) {
      if (mug[i].width/mug[i].height>width/height) {//画像のサイズ調整
        mug[i].resize(width, 0);
      } else {
        mug[i].resize(0, height-pageY);
      }
    } else {
      if (mug[i].height/mug[i].width>height/width) {
        mug[i].resize(0, height-pageY);
      } else {
        mug[i].resize(width, 0);
      }
    }
  }
}

void mousePressed() {//ボタン押したら
  if (setting==0) {
    if (palette==0) {
      //if (mouseY<height-button-margin-button/2||height-button-margin+button/2<mouseY||mouseX<button+margin-button/2||button+margin+button/2<mouseX) {
      if (mouseY>height-pageY) {
        if (button+margin<mouseX&&mouseX<button+margin+button*2.5/2) {//○の右半分
          PorE=0;
          if (mouseY<-mouseX+height) {
            page=2;
          } else if (mouseY>-mouseX+height&&mouseY<height-button-margin) {
            page=3;
          } else if (mouseY<mouseX+height-(button+margin)*2&&mouseY>height-button-margin) {
            page=4;
          } else {
            page=5;
          }
        } else if (mouseX<button+margin) {//○の左半分
          PorE=0;
          if (mouseY>-mouseX+height) {
            page=6;
          } else if (mouseY<-mouseX+height&&mouseY>height-button-margin) {
            page=7;
          } else if (mouseY>mouseX+height-(button+margin)*2&&mouseY<height-button-margin) {
            page=8;
          } else {
            page=1;
          }
          //}
        } else if (width-button-margin/2<mouseX&&mouseX<width-margin/2) {//ホーム
          if (height-button-margin/2<mouseY&&mouseY<height-margin/2) {
            String directory_path = new String(getContext().getExternalFilesDir(null).getAbsolutePath()); //Environment.DIRECTORY_PICTURES
            String time=System.currentTimeMillis()+"";
            save(directory_path + "/"+ "IMG"+ time + ".png");
            savepict=append(savepict, "");
            try {
              FileWriter fw = new FileWriter(directory_path + "/"+"save.txt", true );//テキストファイルに追加書き込み
              String msg="";
              for (i=0; i<n; i++) {
                msg+=c[i][page-1]+",";
              }
              msg+=time+'\n';
              fw.write(msg); 
              fw.close();
            } 
            catch (Exception ex) {
              //例外
              ex.printStackTrace();
            }
            page=0;
          }
        } else if (mouseY>height-100-margin/2) {
          if (xp<mouseX&&mouseX<xp+100) {//ペイントボタンの範囲
            PorE=0;
          } else if (xe<mouseX&&mouseX<xe+100) {//消しゴムボタンの範囲
            PorE=1;
          } else if (xc<mouseX&&mouseX<xc+100&&page!=0) {//カラーパレットボタン
            palette=1;
          } else if (xd<mouseX&&mouseX<xd+100) {//全消しボタン
            //Img=0;
            if (page!=0) {
              for (i=0; i<n; i++) {
                c[i][page-1]=color(255, 0, 100);
              }
            } else {
              for (i=0; i<n; i++) {
                for (j=0; j<9; j++) {
                  c[i][j]=color(255, 0, 100);
                }
              }
            }
          }
        }
        if (height-button-margin-button/2<mouseY&&mouseY<height-button-margin+button/2&&button+margin-button/2<mouseX&&mouseX<button+margin+button/2) {//ドーナツ
          if (div==1) {
            page=9;
          }
        }

        if (height-button-margin-button*1.4/2<mouseY&&mouseY<height-button-margin+button*1.4/2&&button+margin-button*1.4/2<mouseX&&mouseX<button+margin+button*1.4/2) {//中央に扇
          if (div==2) {
            if (button+margin<mouseX&&mouseX<button+margin+button*2.5/2) {//○の右半分
              PorE=0;
              if (mouseY<-mouseX+height) {
                page=10;
              } else if (mouseY>-mouseX+height&&mouseY<height-button-margin) {
                page=11;
              } else if (mouseY<mouseX+height-(button+margin)*2&&mouseY>height-button-margin) {
                page=11;
              } else {
                page=12;
              }
            } else if (mouseX<button+margin) {//○の左半分
              PorE=0;
              if (mouseY>-mouseX+height) {
                page=12;
              } else if (mouseY<-mouseX+height&&mouseY>height-button-margin) {
                page=13;
              } else if (mouseY>mouseX+height-(button+margin)*2&&mouseY<height-button-margin) {
                page=13;
              } else {
                page=10;
              }
            }
          }
        }
      }
    } else if (palette==1) {
      if (mouseX<touchX||touchX+touchW<mouseX||mouseY<touchY||touchY+touchH+100<mouseY) {//カラーパレット閉じる
        palette=0;
      }
    }

    if (Img==0) {
      if (mouseY>height-100-margin/2) {
        if (xpi<mouseX&&mouseX<xpi+100&&page!=0) {//画像ボタン
          ImgPage=page;
          Img=1;
        }
      }
    } else if (Img==1) {//画像一覧表示中

      for (j=0; j<4; j++) {
        for (i=0; i<3; i++) {
          if (pictcount<savepict.length) {
            String directory_path = new String(getContext().getExternalFilesDir(null).getAbsolutePath()); //Environment.DIRECTORY_PICTURES
            if (savepict[pictcount].contains("IMG")) {
              if (width/2-pictx+(pictsize+pictspace)*i<mouseX&&mouseX<width/2-pictx+(pictsize+pictspace)*i+pictsize) {
                if (height/2-picty-50+(pictsize+pictspace)*j<mouseY&&mouseY<height/2-picty-50+(pictsize+pictspace)*j+pictsize) {
                  String[] lines = loadStrings(directory_path + "/"+"save.txt");//保存枚数テキスト読み込み
                  String[] lineslColumn;
                  for (i=1; i<lines.length; i++) {
                    lineslColumn=split(lines[i], ",");
                    //println("IMG"+lineslColumn[n]+".png");
                    //println(savepict[pictcount]);
                    if (savepict[pictcount].equals("IMG"+lineslColumn[n]+".png")) {
                      println(lineslColumn[n]+"a");
                      for (j=0; j<n; j++) {
                        c[j][ImgPage-1]=int(lineslColumn[j]);
                      }
                    }
                    //println(lineslColumn[1000]);
                  }
                }
              }
              Img=0;
            } else {
              PImage image=loadImage(directory_path + "/"+ savepict[pictcount]);

              if (image.width>image.height) {
                if (image.width/image.height>width/height) {//画像のサイズ調整
                  image.resize(width, 0);
                } else {
                  image.resize(0, height-pageY);
                }
              } else {
                if (image.height/image.width>height/width) {
                  image.resize(0, height-pageY);
                } else {
                  image.resize(width, 0);
                }
              }

              image(image, width/2-pictx+(pictsize+pictspace)*i, height/2-picty-50+(pictsize+pictspace)*j, pictsize, pictsize);
              if (width/2-pictx+(pictsize+pictspace)*i<mouseX&&mouseX<width/2-pictx+(pictsize+pictspace)*i+pictsize) {
                if (height/2-picty-50+(pictsize+pictspace)*j<mouseY&&mouseY<height/2-picty-50+(pictsize+pictspace)*j+pictsize) {
                  image.loadPixels();
                  for (int jj = 0; jj < image.height; jj+=r) {  
                    for (int ii = 0; ii < image.width; ii+=r) {  
                      int centerH=((height-pageY-image.height)/2/int(r))*(width/int(r)+2);//真ん中にする処理
                      int centerW=(width-image.width)/2/int(r);//真ん中にする処理
                      if (height-pageY-image.height<0) {
                        centerH=0;
                      }
                      c[ii/int(r)+centerW+jj/int(r)*(width/int(r)+2)+centerH][ImgPage-1]= image.pixels[jj * image.width + ii];//真ん中にする処理とか

                      if (pieceDiv==4) {
                        if (ImgPage%2==0) {
                          c[ii/int(r)+centerW+jj/int(r)*(width/int(r)+2)+centerH][ImgPage-2]= image.pixels[jj * image.width + ii];//真ん中にする処理とか
                        } else {
                          c[ii/int(r)+centerW+jj/int(r)*(width/int(r)+2)+centerH][ImgPage]= image.pixels[jj * image.width + ii];//真ん中にする処理とか
                        }
                      }

                      Img=0;
                      //println(c[1000][ImgPage-1]);
                    }
                  }
                }
              }
            }
            pictcount++;
          }
        }
      }

      pictcount=0;
      pictx=(pictsize*3+pictspace*2+pictmargin*2)/2;
      picty=(pictsize*4+pictspace*3+pictmargin*2)/2;
      if (mouseX<width/2-pictx||width/2-pictx+pictx*2<mouseX||mouseY<height/2-picty-50||height/2-picty-50+picty*2<mouseY) {//画像一覧を閉じる
        Img=0;
      }
    }
  }

  if (setting==0) {
    if (mouseY>height-100-margin/2) {
      if (xsy<mouseX&&mouseX<xsy+100) {//設定ボタン
        setting=1;//設定メニュー表示
      }
    }
  } else if (setting==1) {
    if (xsy-150<mouseX&&mouseX<xsy-150+300) {
      if (height-pageY-300<mouseY&&mouseY<height-pageY-300+100) {
        setting=2;
        positionXsave=positionX;
        positionYsave=positionY;
      }
      if (height-pageY-300+100<mouseY&&mouseY<height-pageY-300+200) {
        setting=3;
      }
    }
  } else if (setting==2) {
    if (height-pageY+margin+40-30<mouseY&&mouseY<height-pageY+margin+40+30) {//xposi
      if (margin+100<mouseX&&mouseX<margin+150) {//left
        if (xcount<=0) {
          xcount-=1;
          positionX=/*r/10*/xcount;//左やじるし
        }
      }
      if (margin+300<mouseX&&mouseX<margin+100+120+130) {
        if (xcount<0) {
          xcount+=1;
          positionX=/*r/10*/xcount;//右やじるし
        }
      }
    } else if (height-margin-20-30<=mouseY&&mouseY<height-margin-20+30) {//yposi
      if (margin+100<mouseX&&mouseX<margin+150) {//left
        if (ycount<=0) {
          ycount-=1;
          positionY=/*r/10*/ycount;//左やじるし
        }
      }
      if (margin+300<mouseX&&mouseX<margin+100+120+130) {
        if (ycount<0) {
          ycount+=1;
          positionY=/*r/10*/ycount;//右やじるし
        }
      }
    }
    if (height-pageY+margin+40-30<mouseY&&mouseY<height-pageY+margin+40+30) {//size
      if (10<r) {
        if (width/2-margin<mouseX&&mouseX<width/2-margin+50) {//left
          r-=1;
        }
      }
      if (r<50) {
        if (width/2-margin+50+120+50<mouseX&&mouseX<width/2-margin+100+120+50) {//right
          r+=1;
        }
      }
    }

    if (width-30-120<mouseX) {//cancel, okボタンクリック
      if (height-pageY<mouseY&&mouseY<height-pageY+pageY/2) {
        positionX=positionXsave;//位置リセット
        positionY=positionYsave;
        setting=0;
      }
      if (height-pageY+pageY/2<mouseY) {
        setting=0;
      }
    }
  } else if (setting==3) {//division number
    if (height-pageY-100-200<mouseY&&mouseY<height-pageY+100+200) {
      if (width/2-400<mouseX&&mouseX<=width/2-200) {
        pieceDiv=4;
        div=0;
      }
      if (width/2-200<mouseX&&mouseX<=width/2) {
        pieceDiv=8;
        div=0;
      }
      if (width/2<mouseX&&mouseX<=width/2+200) {
        div=1;//ドーナツ
      }
      if (width/2+200<mouseX&&mouseX<=width/2+400) {
        div=2;//max12pices
      }
      setting=0;
    }
  }
}


void mouseDragged() {
  if (palette==1) {
    if (touchX<mouseX&&mouseX<touchX+touchW) {
      if (touchY<mouseY&&mouseY<border) {//四角のほう
        ccc[1]=(mouseX-(centerX-int(c_box)*50))/int(c_box);
        ccc[2]=(-mouseY+(centerY+int(c_box)*50))/int(c_box);
        if (0<=ccc[1]&&ccc[1]<=100) {
          circle1X=mouseX;
        }
        if (0<=ccc[2]&&ccc[2]<=100) {
          circle1Y=mouseY;
        }
      } else if (border+70<mouseY&&mouseY<border+200) {//バーのほう
        ccc[0]=(mouseX-(centerX-int(c_box)*50))/int(c_box);
        if (0<=ccc[0]&&ccc[0]<=100) {
          circle2X=mouseX;
        }
      }
    }
  }
  if (setting==2) {//サイズ変更のバー
    if (height-pageY+margin+40-30<mouseY&&mouseY<height-pageY+margin+40+30) {
      if (/*30+yajirushi.width*(pageY+20)/yajirushi.height+70*/width/2-100<mouseX&&mouseX<30+yajirushi.width*(pageY+20)/yajirushi.height+70+700) {
        if (10<r) {
          if (pmouseX>mouseX) {
            r-=1;
          }
        }
        if (r<50) {
          if (pmouseX<mouseX) {
            r+=1;
          }
        }
        positionX=r/10*xcount;
        positionY=r/10*ycount;
      }
    }
    if (height-pageY+margin+40-30<mouseY&&mouseY<height-pageY+margin+40+30) {//xposi
      if (mouseX<width/2-100) {
        //if (0<xcount+10) {
        if (pmouseX>mouseX) {
          xcount-=1;
          //}
        }
        if (xcount+10<10) {
          if (pmouseX<mouseX) {
            xcount+=1;
          }
        }
        positionX=r/10*xcount;
      }
    }
    if (height-margin-20-30<=mouseY&&mouseY<height-margin-20+30) {//yposi
      if (mouseX<width/2-100) {
        //if (0<ycount+10) {
        if (pmouseX>mouseX) {
          ycount-=1;
          //}
        }
        if (ycount+10<10) {
          if (pmouseX<mouseX) {
            ycount+=1;
          }
        }
        positionY=r/10*ycount;
      }
    }
  }
}

void drawPage(int p) {//引数pはpage
  for (i=0; i<(height-pageY)/int(r)+2; i++) {
    for (j=0; j<width/int(r)+2; j++) {
      fill(c[count][p-1]);
      ellipse(r/2+j*r+positionX+interval*j, r/2+i*r+positionY+interval*i, r, r);
      if (count<n-1) {
        count++;
      }
    }
  }
  count=0;

  if (palette==0) {
    if (mousePressed==true) {//色ぬり
      if (mouseY<height-pageY) {
        for (i=0; i<height/int(r)+2; i++) {
          for (j=0; j<width/int(r)+2; j++) {
            if ((r+interval)*i<mouseY&&mouseY<(r+interval)+(r+interval)*i) {
              if ((r+interval)*j<mouseX&&mouseX<(r+interval)+(r+interval)*j) {
                if (PorE==0) {//ペイント
                  if (pieceDiv==8||pieceDiv==4&&p>=10) {
                    c[i*(width/int(r)+2)+j][p-1]=color(ccc[0], ccc[1], ccc[2]);
                  } else {
                    if (p%2==0) {
                      c[i*(width/int(r)+2)+j][p-2]=color(ccc[0], ccc[1], ccc[2]);
                      c[i*(width/int(r)+2)+j][p-1]=color(ccc[0], ccc[1], ccc[2]);
                    } else {
                      if (p!=0) {
                        c[i*(width/int(r)+2)+j][p]=color(ccc[0], ccc[1], ccc[2]);
                        c[i*(width/int(r)+2)+j][p-1]=color(ccc[0], ccc[1], ccc[2]);
                      }
                    }
                  }
                } else {//消しゴム
                  if (pieceDiv==8) {
                    c[i*(width/int(r)+2)+j][p-1]=color(255, 0, 100);
                  } else {
                    if (p%2==0) {
                      c[i*(width/int(r)+2)+j][p-2]=color(255, 0, 100);
                      c[i*(width/int(r)+2)+j][p-1]=color(255, 0, 100);
                    } else {
                      c[i*(width/int(r)+2)+j][p]=color(255, 0, 100);
                      c[i*(width/int(r)+2)+j][p-1]=color(255, 0, 100);
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}


void draw() {
  background(206, 3, 88);
  noStroke();


  if (page==0) {//ホーム
    for (i=0; i<4/*mug.length*/; i++) {
      if (accelerometerValues[1]>=5) {
        mug[i].loadPixels();
        mug[i+4].loadPixels();
        for (int jj = 0; jj < mug[i].height; jj+=r) {  
          for (int ii = 0; ii < mug[i].width; ii+=r) {  
            int centerH=((height-pageY-mug[i].height)/2/int(r))*(width/int(r)+2);//真ん中にする処理
            int centerW=(width-mug[i].width)/2/int(r);//真ん中にする処理
            if (height-pageY-mug[i].height<0) {
              centerH=0;
            }
            c[ii/int(r)+centerW+jj/int(r)*(width/int(r)+2)+centerH][i+i]= mug[i].pixels[jj * mug[i].width + ii];//真ん中にする処理とか
            c[ii/int(r)+centerW+jj/int(r)*(width/int(r)+2)+centerH][i+1+i]= mug[i].pixels[jj * mug[i].width + ii];//真ん中にする処理とか

            c[ii/int(r)+centerW+jj/int(r)*(width/int(r)+2)+centerH][i+9]= mug[i+4].pixels[jj * mug[i].width + ii];//真ん中にする処理とか
          }
        }
      } else {
        mug[i+8].loadPixels();
        mug[i+4+8].loadPixels();
        for (int jj = 0; jj < mug[i].height; jj+=r) {  
          for (int ii = 0; ii < mug[i].width; ii+=r) {  
            int centerH=((height-pageY-mug[i].height)/2/int(r))*(width/int(r)+2);//真ん中にする処理
            int centerW=(width-mug[i].width)/2/int(r);//真ん中にする処理
            if (height-pageY-mug[i].height<0) {
              centerH=0;
            }
            c[ii/int(r)+centerW+jj/int(r)*(width/int(r)+2)+centerH][i+i]= mug[i+8].pixels[jj * mug[i].width + ii];//真ん中にする処理とか
            c[ii/int(r)+centerW+jj/int(r)*(width/int(r)+2)+centerH][i+1+i]= mug[i+8].pixels[jj * mug[i].width + ii];//真ん中にする処理とか

            c[ii/int(r)+centerW+jj/int(r)*(width/int(r)+2)+centerH][i+9]= mug[i+4+8].pixels[jj * mug[i].width + ii];//真ん中にする処理とか
          }
        }
      }
    }


    for (i=0; i<(height-pageY)/int(r)+2; i++) {
      for (j=0; j<width/int(r)+2; j++) {
        for (int u=0; u<8; u++) {
          fill(c[count][u]);
          arc(r/2+j*r+positionX+interval*j, r/2+i*r+positionY+interval*i, r, r, radians(225+u*45), radians(270+u*45), PIE);//扇
        }
        if (count<n-1) {
          count++;
        }
      }
    }
    count=0;
  }

  if (page!=0) {
    background(206, 3, 88);
    drawPage(page);
  }

  if (div==1&&page==0) {//ドーナツ
    for (i=0; i<(height-pageY)/int(r)+2; i++) {
      for (j=0; j<width/int(r)+2; j++) {
        fill(c[count][8]);
        ellipse(r/2+j*r+positionX+interval*j, r/2+i*r+positionY+interval*i, r*0.5, r*0.5);
        if (count<n-1) {
          count++;
        }
      }
    }
    count=0;
  }

  if (div==2&&page==0) {//中央に扇
    for (i=0; i<(height-pageY)/int(r)+2; i++) {
      for (j=0; j<width/int(r)+2; j++) {
        for (int u=0; u<4; u++) {
          fill(c[count][9+u]);
          //fill(0,0,0);
          arc(r/2+j*r+positionX+interval*j, r/2+i*r+positionY+interval*i, r*0.5, r*0.5, radians(225+u*90), radians(315+u*90), PIE);
        }
        if (count<n-1) {
          count++;
        }
      }
    }
    count=0;
  }


  //------------- UI(ボタンとか) ----------------------------------
  fill(206, 3, 88);
  rect(0, height-pageY-20, width, pageY+20);
  for (int u=0; u<8; u++) {//ページのボタン
    noStroke();
    for (i=0; i<n; i++) {
      if (c[i][u]!=color(255, 0, 100)) {
        pagechk[u]++;
      }
    }
    if (pagechk[u]==0) {
      fill(255, 0, 100);
    } else {
      fill(173, 41, 88);
    }
    arc(button+margin, height-button-margin, button*2.5+20, button*2.5+20, radians(225+u*45), radians(270+u*45), PIE);//描写済ページのチェック
    for (i=0; i<pagechk.length; i++) {
      pagechk[i]=0;
    }

    if (pieceDiv==8) {//選択中
      if (u+1==page) {
        fill(206, 3, 85);
      } else {
        fill(0, 0, 100);
      }
    } else {
      if ((u+1)%2!=0) {
        if (u+2==page) {
          fill(206, 3, 85);
        } else {
          fill(0, 0, 100);
        }
        if (u+1==page) {
          fill(206, 3, 85);
        }
      } else {
        if (u+1==page) {
          fill(206, 3, 85);
        } else {
          fill(0, 0, 100);
        }
        if (u==page) {
          fill(206, 3, 85);
        }
      }
    }

    stroke(206, 3, 88);
    strokeWeight(5);
    arc(button+margin, height-button-margin, button*2.5, button*2.5, radians(225+u*45), radians(270+u*45), PIE);//base

    if (div==1) {//ドーナツ
      if (page==9) {
        fill(206, 3, 85);
      } else {
        fill(0, 0, 100);
      }
      ellipse(button+margin, height-button-margin, button, button);
    }

    if (div==2) {
      for (i=0; i<4; i++) {
        if (page==10+i) {
          fill(206, 3, 85);
        } else {
          fill(0, 0, 100);
        }
        arc(button+margin, height-button-margin, button*1.4, button*1.4, radians(225+i*90), radians(315+i*90), PIE);
      }
    }
  }

  image(home, width-100-margin/2, height-100-margin/2);//ホームボタン
  fill(206, 2, 80);
  if (PorE==0) {
    ellipse(xp+50, height-100-margin/2+50, 100, 100);
  } else {
    ellipse(xe+50, height-100-margin/2+50, 100, 100);
  }
  image(paint, xp, height-100-margin/2);//ペイント
  image(eraser, xe, height-100-margin/2);//消しゴム
  image(pict, xpi, height-100-margin/2);//画像
  image(del, xd, height-100-margin/2);//ゴミ箱
  image(system, xsy, height-100-margin/2);//設定
  tint(ccc[0], ccc[1], ccc[2]);
  image(col, xc, height-100-margin/2);//色
  noTint();
  //------------- UI(ボタンとか) ----------------------------------

  //----------カラーパレット-----------
  if (palette==1) {
    fill(206, 3, 88);
    strokeWeight(1);
    stroke(0, 0, 100);
    rect(touchX, touchY, touchW, touchH+100, 30);

    for (i=0; i<100; i++) {//彩度、明度
      for (j=0; j<100; j++) {
        fill(ccc[0], i, j);
        noStroke();
        rect(centerX-c_box*50+c_box*i, centerY+c_box*50-c_box*j, c_box, c_box);//centerX, centerYのとこには中心を
      }
      fill(i, 100, 100);
      rect(centerX-c_box*50+c_box*i, centerY+c_box*50+60, 6, 20);//色
    }

    fill(ccc[0], ccc[1], ccc[2]);
    stroke(0, 0, 100);
    ellipse(circle1X, circle1Y, 35, 35);
    noStroke();
    fill(ccc[0], 100, 100);
    ellipse(circle2X, circle2Y, 45, 45);
  }

  //----------カラーパレット-----------

  //----------画像一覧-----------
  if (Img==1) {
    fill(206, 3, 88);
    noStroke();
    rectMode(CORNER);
    pictx=(pictsize*3+pictspace*2+pictmargin*2)/2;
    picty=(pictsize*4+pictspace*3+pictmargin*2)/2;
    rect(width/2-pictx, height/2-picty-50, pictx*2, picty*2, 30);//背景
    pictx=(pictsize*3+pictspace*2)/2;
    picty=(pictsize*4+pictspace*3)/2;
    fill(0, 0, 100);

    /*for (j=0; j<4; j++) {
     for (i=0; i<3; i++) {
     if (pictcount<pic.length) {
     if (pic[pictcount].width>pic[pictcount].height) {
     image(pic[pictcount], width/2-pictx+(pictsize+pictspace)*i, height/2-picty-50+(pictsize+pictspace)*j, pictsize, pictsize);
     } else {
     image(pic[pictcount], width/2-pictx+(pictsize+pictspace)*i, height/2-picty-50+(pictsize+pictspace)*j, pictsize, pictsize);
     }
     }
     pictcount++;
     }
     }
     pictcount=0;*/

    //----------保存した画像のファイル名取得----------
    filter = new PngFileFilter();
    String directory_path = new String(getContext().getExternalFilesDir(null).getAbsolutePath()); //Environment.DIRECTORY_PICTURES
    imageFiles = new File(directory_path).listFiles(filter);
    int l=0;
    for (File file : imageFiles) {
      savepict[l]=file.getName();
      l+=1;
    }
    //println(savepict);

    for (j=0; j<4; j++) {
      for (i=0; i<3; i++) {
        if (pictcount<savepict.length) {
          //String directory_path = new String(getContext().getExternalFilesDir(null).getAbsolutePath()); //Environment.DIRECTORY_PICTURES
          //println(directory_path);
          PImage image=loadImage(directory_path + "/"+ savepict[pictcount]);
          image(image, width/2-pictx+(pictsize+pictspace)*i, height/2-picty-50+(pictsize+pictspace)*j, pictsize, pictsize);
        }
        pictcount++;
      }
    }
    pictcount=0;
  }

  //----------画像一覧-----------

  //----------設定画面-----------
  if (setting==1) {
    fill(206, 3, 88);
    noStroke();
    rect(xsy-150, height-pageY-300, 300, 200, 30);//背景
    stroke(255, 0, 100);
    line(xsy-150, height-pageY-300+100, xsy-150+300, height-pageY-300+100);//ボタン中央線
    textSize(40);
    fill(255, 0, 100);
    text("Position & Size", xsy-150+13, height-pageY-300+65);//ボタンテキスト
    textSize(38);
    text("Division Number", xsy-150+10, height-pageY-300+162);//ボタンテキスト
  } else if (setting==2) {//大きさと位置の設定
    fill(206, 3, 88);
    noStroke();
    rect(0, height-pageY-20, width, pageY+20);
    //image(yajirushi, 30, height-pageY-20, yajirushi.width*(pageY+20)/yajirushi.height, pageY+20);//やじるしアイコン
    fill(255, 0, 100);
    textSize(40);
    text("Cancel", width-30-120, height-150);//キャンセル
    text("OK", width-30-120, height-50);//ok
    text("Position", margin, height-pageY+margin-20);
    text("Size", width/2-margin, height-pageY+margin-20);
    textSize(60);
    text("X          "+int(xcount), margin, height-pageY+margin+60);//数値
    text("Y          "+int(ycount), margin, height-margin);
    text(int(r), width/2+margin+20, height-pageY+margin+60);
    fill(255, 0, 100);
    triangle(margin+100, height-pageY+margin+40, margin+150, height-pageY+margin+40-30, margin+150, height-pageY+margin+40+30);//←position
    fill(255, 0, 100);
    triangle(margin+100, height-margin-20, margin+150, height-margin-20-30, margin+150, height-margin-20+30);
    if (xcount+10>=10) {
      fill(255, 3, 92);
    } else {
      fill(255, 0, 100);
    }
    triangle(margin+100+120+130, height-pageY+margin+40, margin+150+150, height-pageY+margin+40-30, margin+150+150, height-pageY+margin+40+30);//→position
    if (ycount+10>=10) {
      fill(255, 3, 92);
    } else {
      fill(255, 0, 100);
    }
    triangle(margin+100+120+130, height-margin-20, margin+150+150, height-margin-20-30, margin+150+150, height-margin-20+30);//
    if (r<=10) {
      fill(255, 3, 92);
    } else {
      fill(255, 0, 100);
    }
    triangle(width/2-margin, height-pageY+margin+40, width/2-margin+50, height-pageY+margin+40-30, width/2-margin+50, height-pageY+margin+40+30);//←size
    if (r>=50) {
      fill(255, 3, 92);
    } else {
      fill(255, 0, 100);
    }
    triangle(width/2-margin+120+100+50, height-pageY+margin+40, width/2-margin+50+120+50, height-pageY+margin+40-30, width/2-margin+50+120+50, height-pageY+margin+40+30);//→size
  } else if (setting==3) {//division number
    fill(206, 3, 88);
    noStroke();
    rectMode(CENTER);
    rect(width/2, height-pageY-200, 800, 200, 30);//背景
    rectMode(CORNER);
    fill(255, 0, 100);
    stroke(255, 0, 100);
    //line(width/2-300, height-pageY-300, width/2+300, height-pageY-300);//横
    line(width/2, height-pageY-200-100, width/2, height-pageY-200+100);//縦
    line(width/2-200, height-pageY-200-100, width/2-200, height-pageY-200+100);//縦
    line(width/2+200, height-pageY-200-100, width/2+200, height-pageY-200+100);//縦
    textSize(60);
    stroke(206, 3, 88);
    for (int u=0; u<4; u++) {
      arc(width/2-300, height-pageY-200, button*1.5, button*1.5, radians(270+u*90), radians(360+u*90), PIE);//4pices
    }
    for (int u=0; u<8; u++) {
      arc(width/2-100, height-pageY-200, button*1.5, button*1.5, radians(270+u*45), radians(315+u*45), PIE);//8pices
    }
    for (int u=0; u<8; u++) {
      arc(width/2+100, height-pageY-200, button*1.5, button*1.5, radians(270+u*90), radians(360+u*90), PIE);//ドーナツ
    }
    ellipse(width/2+100, height-pageY-200, button*1.5/2, button*1.5/2);
    for (int u=0; u<4; u++) {
      arc(width/2+300, height-pageY-200, button*1.5, button*1.5, radians(270+u*90), radians(360+u*90), PIE);//max12pices
    }
    noFill();
    ellipse(width/2+300, height-pageY-200, button*1.5/2, button*1.5/2);
  }

  //----------設定画面-----------
  //Save();
}
