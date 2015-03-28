// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:math';

class Grid {
  num x;
  num y;
  
  Grid(this.x, this.y);
}

void main() {
  CanvasElement canvas = document.querySelector('#canvas');
  CanvasRenderingContext2D ctx = canvas.getContext('2d');
  
  var size = min(canvas.width, canvas.height);
  
  ctx.lineWidth = 4;
  ctx.fillStyle = 'black';
  
  //ctx.moveTo(0,0);
  //ctx.lineTo(size, size);
  
  ctx.fillRect(0, 0, size, size);
  

  var borderwidth = 10;  
  var scale = (size - 2*borderwidth) / size; 
  ctx.scale(scale, scale);
  ctx.translate(borderwidth, borderwidth);
  
  
  
  const boxLineColor = '#E8F1FA';
  const boxColor = '#BED1E6';
  
  ctx.fillStyle = boxLineColor;
  ctx.fillRect(0, 0, size, size);
  
  var gridSize = 10;
  //var g = new Grid(gridSize, gridSize);
  
  var boxBorderSize = 4;
  var stepSize = ((size - boxBorderSize) / gridSize); 
 
  
  ctx.fillStyle = boxColor;
  for (var x = boxBorderSize; x < size; x += stepSize) {
    for (var y = boxBorderSize; y < size; y += stepSize) {
      ctx.fillRect(x, y, stepSize - boxBorderSize, stepSize - boxBorderSize);

    }
  }
  
  
  ctx.stroke();
}
