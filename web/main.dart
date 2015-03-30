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


class Elem {
    int level;

    Elem(this.level);

    bool isEmpty() {
        return level == 0;
    }

    String toString() {
        return level.toString();
    }
}

class Grid {
    final int x, y;
    List<Elem> elems;

    Grid(this.x, this.y) {
        elems = new List<Elem>.generate(x*y, (int _) => new Elem(0));
    }

    Elem getElem(GridPoint p) {
        return elems[p.y*x + p.x];
    }

    void setElem(GridPoint p, Elem e) {
       elems[p.y*x + p.x] = e;
    }

    void incElem(int xi, int yi, int lvl) {
       elems[yi*x + xi].level += 1;
    }
}

void prSquare(sq) {
    if (sq == null) {
        print(sq);
    } else {
        print([sq.x, sq.y]);
    }
}

class DrawnGrid {
    static const boxColor      = '#E8F1FA';
    static const boxLineColor  = '#BED1E6';
    static const boxBorderSize = 10;
    static const hlColor       = 'rgba(32,32,2,.1)';

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

    GridPoint getGridCoords(num x, num y) {
        var gx = x / stepSizeX;
        var ox = x % stepSizeX;
        if (gx >= grid.x || ox <= boxBorderSize)
            return null;

        var gy = y / stepSizeY;
        var oy = y % stepSizeY;
        if (gy >= grid.y || oy <= boxBorderSize)
            return null;

        return new GridPoint(gx.floor(), gy.floor());
    }

    void drawGrid() {
        // background (borders)
        ctx.fillStyle = boxLineColor;
        ctx.fillRect(0, 0, xsize, ysize);
        // boxes
        ctx.fillStyle = boxColor;
        for (var x = boxBorderSize; x < xsize; x += stepSizeX)
            for (var y = boxBorderSize; y < ysize; y += stepSizeY)
                ctx.fillRect(x, y, boxDimX, boxDimY);
    }

    void drawGridElem(GridPoint p) {

        ctx.fillStyle = boxColor;
        var x = boxBorderSize + (p.x*stepSizeX);
        var y = boxBorderSize + (p.y*stepSizeY);
        ctx.fillRect(x, y, boxDimX, boxDimY);

        var elem = grid.getElem(p);
        if (!elem.isEmpty()) {
            x += boxDimX/2;
            y += boxDimY/2;
            ctx.fillStyle = "black";
            ctx.fillText(elem.toString(), x, y);
            //print(lvl.toString());
        }
    }

    void HlSquare(num x, num y) {
        var p = getGridCoords(x,y);
        prSquare(p);

        if (p == hlSquare) {
            return;
        }

        if (p != null) {
            ctx.fillStyle = hlColor;
            var x = boxBorderSize + (p.x*stepSizeX);
            var y = boxBorderSize + (p.y*stepSizeY);
            ctx.fillRect(x, y, boxDimX, boxDimY);
        }

        if (hlSquare != null) {
            drawGridElem(hlSquare);
        }

        hlSquare = p;
    }

    void UnHlSquare() {
        if (hlSquare != null) {
            drawGridElem(hlSquare);
            hlSquare = null;
        }
    }

    void updateElem(GridPoint p, int lvl) {
        grid.setElem(p, new Elem(lvl));
        if (lvl != 0) {
            var x = boxBorderSize + (p.x*stepSizeX) + (boxDimX/2);
            var y = boxBorderSize + (p.y*stepSizeY) + (boxDimY/2);
            ctx.fillStyle = "black";
            ctx.fillText(lvl.toString(), x, y);
            print(lvl.toString());
        }
    }

    void addItem(num x, num y) {
        GridPoint sq = getGridCoords(x,y);

        if (sq == null)
            return;

        if (!grid.getElem(sq).isEmpty())
            return;

        updateElem(sq, 1);
    }
}

void main() {

    CanvasElement canvas = document.querySelector('#canvas');
    CanvasRenderingContext2D ctx = canvas.getContext('2d');

    ctx.lineWidth = 4;
    ctx.font = "40pt Calibri";
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";
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

    canvas.onMouseDown.listen( (e) {
        dg.addItem(e.client.x, e.client.y);
    });

    // TODO: match 3 mechanic
}
