// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:math';

class GridPoint {
    final int x, y;
    GridPoint(this.x, this.y);

    bool operator ==(p) {
        return (p is GridPoint && p.x == x && p.y == y);
    }
}

class Grid {
    final int x, y;

    Grid(this.x, this.y);
}

void prSquare(sq) {
    if (sq == null) {
        print(sq);
    } else {
        print([sq.x, sq.y]);
    }
}

class DrawnGrid {
    static const boxColor     = '#E8F1FA';
    static const boxLineColor = '#BED1E6';
    static const boxBorderSize = 10;

    Grid grid;
    num xsize, ysize;
    CanvasRenderingContext2D ctx;
    var hlSquare = null; // current highlighted square

    num stepSizeX, stepSizeY;
    num boxDimX, boxDimY;

    DrawnGrid(this.grid, this.xsize, this.ysize, this.ctx) {
        stepSizeX = ((xsize - boxBorderSize) / grid.x);
        stepSizeY = ((ysize - boxBorderSize) / grid.y);
        boxDimX = stepSizeX - boxBorderSize;
        boxDimY = stepSizeY - boxBorderSize;
    }

    void drawGrid() {
        // background (borders)
        ctx.fillStyle = boxLineColor;
        ctx.fillRect(0, 0, xsize, ysize);
        // boxes
        ctx.fillStyle = boxColor;
        for (var x = boxBorderSize; x < xsize; x += stepSizeX) {
            for (var y = boxBorderSize; y < ysize; y += stepSizeY) {
                ctx.fillRect(x, y, boxDimX, boxDimY);
            }
        }
    }

    void highlightSq(GridPoint sq) {
        ctx.fillStyle = 'rgba(32,32,2,.1)';
        var x = boxBorderSize + (sq.x*stepSizeX);
        var y = boxBorderSize + (sq.y*stepSizeY);
        ctx.fillRect(x, y, boxDimX, boxDimY);
    }

    void unhighlightSq(GridPoint sq) {
        ctx.fillStyle = boxColor;
        var x = boxBorderSize + (sq.x*stepSizeX);
        var y = boxBorderSize + (sq.y*stepSizeY);
        ctx.fillRect(x, y, boxDimX, boxDimY);
    }

    getSquareDims(num x, num y) {
        var gx = x / stepSizeX;
        var ox = x % stepSizeX;
        if (gx >= grid.x || ox <= boxBorderSize) {
            return null;
        }

        var gy = y / stepSizeY;
        var oy = y % stepSizeY;
        if (gy >= grid.y || oy <= boxBorderSize) {
            return null;
        }

        return new GridPoint(gx.floor(), gy.floor());
    }

    void HlSquare(num x, num y) {
        var sq = getSquareDims(x,y);
        prSquare(sq);

        if (sq == hlSquare) {
            return;
        }

        if (sq != null) {
            highlightSq(sq);
        }

        if (hlSquare != null) {
            unhighlightSq(hlSquare);
        }

        hlSquare = sq;
    }

    void UnHlSquare() {
        if (hlSquare != null) {
            unhighlightSq(hlSquare);
            hlSquare = null;
        }
    }
}

void main() {

    CanvasElement canvas = document.querySelector('#canvas');
    CanvasRenderingContext2D ctx = canvas.getContext('2d');

    ctx.lineWidth = 4;
    // const bgColor = '#B8D6D3';
    // ctx.fillStyle = bgColor;
    // ctx.fillRect(0, 0, size, size);
    // var borderwidth = 20;
    // var scale = (size - 2*borderwidth) / size;
    // ctx.scale(scale, scale);
    // ctx.translate(borderwidth, borderwidth);

    DrawnGrid dg = new DrawnGrid(new Grid(6,6), canvas.width, canvas.height, ctx);
    dg.drawGrid();

    canvas.onMouseMove.listen( (e) {
        dg.HlSquare(e.client.x, e.client.y);
    });

    canvas.onMouseOut.listen( (e) {
        dg.UnHlSquare();
    });

    // TODO: add click support
    // TODO: match 3 mechanic
}
