use graph;
use ui;
use math;
use array;
use io;

use stone;
use engine;
use debug;

class Board

   size;
   xleft;
   ytop;
   xright;
   ybottom;
   w;
   h;
   lx;
   h_names;
   cursor_x;
   cursor_y;
   bg;
   lastX;
   lastY;
   lastColour;
   inBoard: engine.InBoard;

   function clearCursor() forward;
   function drawCursor() forward;
   function drawPlayNumber(n, c) forward;

   function calculateLx()
      if size = 19 then
         lx   = math.round((w) / size);
      else
         lx   = math.round((w) / size);
      end;
   end
 
   // Method constructor
   function init()
      h_names = ["a", "b", "c", "d", "e", "f", "g", "h", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t"];
      graph.full(true);
      graph.scale(false);
      size = 19;
      xleft = 3;
      w = 240;
      h = 320;
      ybottom = 240;
      graph.size(w, h);
      calculateLx();
      cursor_x = xleft + math.round((size/2)*lx) - lx/2;
      cursor_y = cursor_x - xleft;
      bg = 0xEACE09;
      lastX = "";
   end

   function cursor2Board()
      x = math.round(cursor_x/lx);
      y = math.round(cursor_y/lx) - 1 ;
      return [x,y];
   end

   // Use this method to display the board
   function showBoard()
      graph.show();
   end;

   function setBoardSize(s)
      size = s;
      calculateLx();
   end;

   // Draw the board bacgground
   function setBackground()
      graph.pen (0xEACE09);
      graph.brush(0xEACE09);
      graph.rect(0, 0, w, ybottom+lx+ 5);
   end

   // Method to draw a black stone
   function drawBlackStone(a, y)
      x = array.index(h_names, a) ;
      y = y;
      graph.pen(graph.black);
      graph.brush(graph.black);
      graph.circle(x*lx - (lx/4), y*lx + (lx/2), lx-1);
      //graph.circle(x*lx + xleft + (lx/2), y*lx + (lx/2), lx-1);
      s : stone.Stone = stone.Stone(a, x, size - y , graph.black);
      inBoard.addStone(s);
   end

   // Method to draw a white stone
   function drawWhiteStone(a, y)
      x = array.index(h_names, a);
      y = y;
      graph.pen(graph.white);
      graph.brush(graph.white);
      //graph.circle(x*lx + xleft + (lx/2), y*lx + (lx/2), lx-1);
      graph.circle(x*lx - (lx/4), y*lx + (lx/2), lx-1);
      s : stone.Stone = stone.Stone(a, x, size - y , graph.white);
      inBoard.addStone(s);
   end

   function drawStoneAtCursor (colour, pNumber)
      clearCursor();
      xy = cursor2Board();
      if colour = graph.black then
         drawBlackStone(h_names[xy[0]], xy[1]);
         drawPlayNumber(pNumber, "black");
      else
         drawWhiteStone(h_names[xy[0]], xy[1]);
         drawPlayNumber(pNumber, "white");
      end;
      drawCursor();
      showBoard();
   end

   // This method removes the stone from from the
   // given coordinates by painting that stone with
   // the board bg and redrawing the line that
   // was occupated by the stone.
   // That function does not redraw the rest of the
   // board.
   function clearStone(a, y)
      x = array.index(h_names, a) ;
      y = y;
      // paint the stone with board bg color
      graph.pen(bg);
      graph.brush(bg);
      graph.circle(x*lx + xleft + (lx/2), y*lx + (lx/2), lx-1);

      graph.pen(graph.black);
      graph.brush(graph.black);

      // calculate X,Y from the stone centre
      X = x*lx + (lx/2) - (lx - 1)/2 -1;
      Y = y*lx + (lx/2) - (lx - 1)/2 -1;

      // redraw hor. and vert. line segment
      graph.line(X+lx, Y+lx/2, X+lx, Y+lx+lx/2);
      graph.line(X + lx/2, Y+lx, X+lx+lx/2, Y+lx);
      inBoard.removeStone(x,y);
   end

   function drawCoord(xy)
      graph.font(["SwissA", 16, true, false]);
      graph.text(xleft, ybottom + 35, io.format("%s%d", h_names[xy[0]],size - xy[1]));
   end

   function drawPlayNumber(n, c)
      xy = cursor2Board();
      graph.font(["SwissA", 16, true, false]);
      graph.pen(graph.white);
      graph.text(xleft + 60, ybottom + 35, io.format("Play Nr: %d", n-1));
      if lastX # "" then
         graph.text(xleft + 140, ybottom + 35, io.format("- %s%d - %s", h_names[lastX], size - lastY, lastColour));
      end;
      graph.pen(graph.black);
      graph.text(xleft + 60, ybottom + 35, io.format("Play Nr: %d", n));
      graph.text(xleft + 140, ybottom + 35, io.format("- %s%d - %s", h_names[xy[0]], size - xy[1], c));
      lastX = xy[0];
      lastY = xy[1];
      lastColour = c;
   end

   // This method clear the cursor by
   // redrawing with colour of current stone
   // if it was on a stone or with the colour
   // of the grid
   function clearCursor()
      xy = cursor2Board();
      //print io.format("clearCursor x=%d, y=%d", xy[0]-1, size-xy[1]);
      colour = inBoard.getStoneColour(xy[0], size - xy[1] );

      if colour = null then
         graph.pen(graph.black);
      else
         graph.pen(colour);
      end;

      //if cursor_x > (size * lx) - (2 * lx) then
      if xy[0] = size - 1 then
         graph.line(cursor_x - 1 - lx/4, cursor_y-1, cursor_x+lx/4, cursor_y-1);
         graph.line(cursor_x-1, cursor_y - 1 - lx/4, cursor_x-1, cursor_y+lx/2);
         if colour = null then
            graph.pen(bg);
            graph.line(cursor_x+1, cursor_y-1, cursor_x+lx/2+2, cursor_y-1);
         end;
         if size - xy[1] < 1 then
            graph.line(cursor_x-1, cursor_y-lx/2, cursor_x-1, cursor_y-1);
         end;
         if xy[1] = size - 1 then
            graph.line(cursor_x-1, cursor_y, cursor_x-1, cursor_y+lx/2);
         end;
      elsif size - xy[1] = size  then
         graph.line(cursor_x - lx/4 - 1, cursor_y-1, cursor_x+lx/2, cursor_y-1);
         graph.line(cursor_x-1, cursor_y - 1 - lx/4, cursor_x-1, cursor_y  + lx/2);
         if colour = null then
            graph.pen(bg);
            graph.line(cursor_x-1, cursor_y-2, cursor_x-1, cursor_y-lx/2);
         end;
         if xy[0] = 0 then
            graph.line(cursor_x - lx/4, cursor_y-1, cursor_x-1, cursor_y-1);
         end;
      elsif size - xy[1] = 1 then
         graph.line(cursor_x - 1 - lx/4, cursor_y-1, cursor_x+lx/2, cursor_y-1);
         graph.line(cursor_x-1, cursor_y -1- lx/2, cursor_x-1, cursor_y + lx/2);
         if colour = null then
            graph.pen(bg);
            graph.line(cursor_x-1, cursor_y, cursor_x-1, cursor_y+lx/2);
         end;
         if xy[0] = 0 then
            graph.line(cursor_x - lx/4, cursor_y-1, cursor_x-1, cursor_y-1);
         end;
      elsif xy[0] = 0 then
         graph.line(cursor_x-1, cursor_y-1, cursor_x+lx/2, cursor_y-1);
         graph.line(cursor_x-1, cursor_y - 1 - lx/4, cursor_x-1, cursor_y+lx/2);
         if colour = null then
            graph.pen(bg);
         else
            graph.pen(colour);
         end;
            graph.line(cursor_x - lx/4, cursor_y-1, cursor_x-1, cursor_y-1);
      else
         graph.line(cursor_x - 1 - lx/4, cursor_y-1, cursor_x+lx/2, cursor_y-1);
         graph.line(cursor_x-1, cursor_y - 1 - lx/4, cursor_x-1, cursor_y+lx/2);
      end;
      graph.pen(graph.white);
      drawCoord(xy);
      showBoard();
   end

   function drawCursor()
      xy = cursor2Board();
      graph.pen(graph.green);
      graph.line(cursor_x - 1 - lx/4, cursor_y-1, cursor_x+lx/2, cursor_y-1);
      graph.line(cursor_x-1, cursor_y - 1 - lx/4, cursor_x-1, cursor_y+lx/2);
      graph.pen(graph.black);
      drawCoord(xy);
      showBoard();
   end

   // This method setup the board background and
   // draws the horizontal and
   // vertical lines.
   // It does not display the board. See showBoard.
   function drawBoard ()
      setBackground();
      graph.pen(graph.black);
      y = 0;
      graph.font(["SwissA", 10, true, false]);

      // horizontal lines
      for x=0 to size-1 do
         y += lx;
         graph.line(xleft, y, ybottom-xleft, y);
      end;


      // vertical lines
      y = xleft;
      for x=0 to size-1 do
         graph.line(y, lx, y, ybottom+lx-2*xleft);
         y += lx;
      end;

      drawCursor();
   end;

   function moveCursorLeft()
      xy = cursor2Board();
      if xy[0] >= 1 then
         clearCursor();
         cursor_x -= lx;
         drawCursor();
      end
   end

   function moveCursorRight()
      xy = cursor2Board();
      if xy[0] < size - 1 then
         clearCursor();
         cursor_x += lx;
         drawCursor();
      end
   end

   function moveCursorUp()
      xy = cursor2Board();
      if size - xy[1] < size then
         clearCursor();
         cursor_y -= lx;
         drawCursor();
      end
   end

   function moveCursorDown()
      xy = cursor2Board();
      if size - xy[1] > 1  then
         clearCursor();
         cursor_y += lx;
         drawCursor();
      end
   end

   function setInBoard(b: engine.InBoard)
      this.inBoard = b;
   end
end;

// main entry function
function main()
   playNumber = 0;
   colour = graph.white;
   board:Board = Board();
   inBoard: engine.InBoard = engine.InBoard(board.size);
   board.setInBoard(inBoard);

   board.drawBoard();
   board.showBoard();
   //addBlackStone("c", 15);

   key = ui.keys(false);
   do
      //sleep(700);
      key = ui.cmd();
      case key
         in ui.upkey:
            board.moveCursorUp();
         in ui.downkey:
            board.moveCursorDown();
         in ui.leftkey:
            board.moveCursorLeft();
         in ui.rightkey:
            board.moveCursorRight();
         in ui.gokey:
            playNumber += 1;
            if colour = graph.white then
               board.drawStoneAtCursor(colour, playNumber);
               colour = graph.black;
            else
               board.drawStoneAtCursor(colour, playNumber);
               colour = graph.white;
            end;
         //in 52: // key :
            l = 0;
            s: stone.Stone = inBoard.getLast();
            gr : engine.Group = inBoard.getGroup(s);
            gr.clearAll();
            l = gr.calculateLibertiesOf(s,l);
            if s # null then
               debug.debug("%s%d %d",s.a, s.y, l);
            end;
         else
            print key;
      end;
   until key=65;
   graph.hide();
end

main();
