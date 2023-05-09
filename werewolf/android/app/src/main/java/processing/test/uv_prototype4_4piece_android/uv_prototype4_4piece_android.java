package processing.test.uv_prototype4_4piece_android;

import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class uv_prototype4_4piece_android extends PApplet {

int i=0;
int j=0;
int page=9;

int r=16;//直径
int n=3000;//円の数
int[][] piece= new int[n][8];//n個の丸と8個のピース、色保存の配列
int count=0;

int pageY=40;//ボタンのスペース
int button=30;//ボタンサイズ

public void setup() {
  //size(320, 568);//352,624
  
  for (i=0; i<n; i++) {
    for (j=0; j<8; j++) {
      piece[i][j]=/*j*30*/255;
    }
  }
}

public void draw() {
  background(255);
  noStroke();

  if (page==9) {
    for (i=0; i<(height-pageY)/r; i++) {
      for (j=0; j<width/r; j++) {
        for (int u=0; u<8; u++) {
          fill(piece[count][u]);
          arc(r/2+j*r, r/2+i*r, r, r, radians(270+u*45), radians(315+u*45), PIE);//扇
        }
        if (count<n-1) {
          count++;
        }
      }
    }
    count=0;
  }

  /*if (mousePressed==true) {//色ぬり
   for (i=0; i<height/r; i++) {
   for (j=0; j<width/r; j++) {
   if (r*i<mouseY&&mouseY<r+r*i) {
   if (r*j<mouseX&&mouseX<r+r*j) {
   for (int u=0; u<8; u++) {
   piece[i*(width/r)+j][u]=0;
   }
   }
   }
   }
   }
   }*/


  if (page!=9) {
    background(200);
    drawPage(page);
  }

  for (i=0; i<9; i++) {
    fill(255);
    rect(10+i*(button+5), height-pageY+5, button, button);//8つのボタン表示
    fill(0);
    text(i+1, 10+i*(button+5), height-pageY+30);//ボタンの数字
  }
}

public void mouseClicked() {//ボタン押したら
  if (mouseY>height-pageY) {
    for (i=0; i<9; i++) {
      if (10+i*(button+5)<mouseX&&mouseX<10+i*(button+5)+button) {
        page=i+1;//ページ切り替え
      }
    }
  }
}

public void drawPage(int p) {//引数pはpage
  for (i=0; i<(height-pageY)/r; i++) {
    for (j=0; j<width/r; j++) {
      if (p==1) {
        fill(piece[count][0]);
      } else if (p==2) {
        fill(piece[count][2]);
      } else if (p==3) {
        fill(piece[count][4]);
      } else if (p==4) {
        fill(piece[count][6]);
      }
      ellipse(r/2+j*r, r/2+i*r, r, r);
      if (count<n-1) {
        count++;
      }
    }
  }
  count=0;

  if (mousePressed==true) {//色ぬり
    for (i=0; i<height/r; i++) {
      for (j=0; j<width/r; j++) {
        if (r*i<mouseY&&mouseY<r+r*i) {
          if (r*j<mouseX&&mouseX<r+r*j) {
            if (p==1) {
              piece[i*(width/r)+j][0]=0;
              piece[i*(width/r)+j][7]=0;
            } else if (p==2) {
              piece[i*(width/r)+j][1]=0;
              piece[i*(width/r)+j][2]=0;
            } else if (p==3) {
              piece[i*(width/r)+j][3]=0;
              piece[i*(width/r)+j][4]=0;
            } else if (p==4) {
              piece[i*(width/r)+j][5]=0;
              piece[i*(width/r)+j][6]=0;
            }
          }
        }
      }
    }
  }
}
  public void settings() {  fullScreen(); }
}
