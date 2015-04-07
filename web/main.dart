// Copyright (c) 2015, Kornilios Kourtis. All rights reserved.
// This file is distributed under the terms of the MIT Licece (see the LICENSE
// file).

import 'dart:html';

class GridPoint {
    final int x, y;
    GridPoint(this.x, this.y);

    GridPoint.fromMove(GridPoint p, List<int> m)
        : x = p.x + m[0],
          y = p.y + m[1];

    bool operator ==(p) {
        return (p is GridPoint) && (p.x == x) && (p.y == y);
    }

    String toString() {
        return "GridPont(" + x.toString() + "," + y.toString() + ")";
    }

    int get hashCode {
        return (x + y);
    }
}

prGridPoint(p) {
    if (p == null)
        print(p);
    else if (p is GridPoint)
        print([p.x,p.y]);
    else assert(false);
}


class Elem {
    int level;

    Elem(this.level);

    bool isEmpty() {
        return level == 0;
    }

    // apparently if you want to override ==, you need to implement
    // hashCode() :/ Moreover, equality is used by default in things like sets
    // and maps, so you cannot distinguish between two equal (yet different)
    // objects in a (default) map.
    bool equal(Elem e) {
        return (e.level == level);
    }

    String toString() {
        return level.toString();
    }
}

// A match3 grid
class Grid {
    static const up    = const  [ 0,-1];
    static const down  = const  [ 0, 1];
    static const left  = const  [-1, 0];
    static const right = const  [ 1, 0];
    static const moves = const [up,down,left,right];

    final int x, y;
    List<Elem> elems;

    Grid(this.x, this.y) {
        elems = new List<Elem>.generate(x*y, (int _) => new Elem(0));
    }

    Elem getElem(GridPoint p) {
        return elems[p.y*x + p.x];
    }

    bool validPoint(GridPoint p) {
        return (p.x >= 0 && p.x < x && p.y >= 0 && p.y < y);
    }

    Iterable<GridPoint> neighbors(GridPoint p) {
        return moves.map((m) => new GridPoint.fromMove(p,m))
                    .where(validPoint);
    }

    Set<GridPoint> matchingPoints(GridPoint p) {
        Elem e = getElem(p);
        Set<GridPoint> s = new Set.from([p]);
        Set<GridPoint> boundary = s;
        while (true) {
            Set<GridPoint> s_new = new Set();
            for (GridPoint o in boundary)
                s_new.addAll(neighbors(o).where(
                        (x) => getElem(x).equal(e) && !s.contains(x)
                ));

            if (s_new.length == 0)
                break;

            s.addAll(s_new);
            boundary = s_new;
        }

        return s;
    }

    // set an element in the grid, return the updated points that need to be
    // redrawn
    Set<GridPoint> setPoint(GridPoint p) {
        int level = 1;
        Elem e = elems[p.y*x + p.x];
        assert(e.isEmpty());

        var ret = new Set();
        while (true) {
            e.level = level;

            var matchedPs = matchingPoints(p);
            ret.addAll(matchedPs);
            if (matchedPs.length < 3)
                break;

            for (GridPoint mp in matchedPs)
                elems[mp.y*x + mp.x].level = 0;

            level++;
        }

       return ret;
    }

    void incElem(int xi, int yi, int lvl) {
       elems[yi*x + xi].level += 1;
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
    GridPoint hlSquare = null; // current highlighted square

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
        prGridPoint(p);

        if (p == hlSquare)
            return;

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

    void setPoint(num x, num y) {
        GridPoint p = getGridCoords(x,y);
        if (p == null)
            return;

        if (!grid.getElem(p).isEmpty())
            return;

        var updated = grid.setPoint(p);
        for (var u in updated)
            drawGridElem(u);

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
        dg.setPoint(e.client.x, e.client.y);
    });
}
