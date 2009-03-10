use constants as C;

class Stone
   colour;
   a;
   x;
   y;
   id;
   sgf_x;
   sgf_y;
   surrounds;  
   liberties;
   checked;

   function init(a, x, y, colour)
      this.colour = colour;
      this.a = a;
      this.x = x;
      this.y = y;
      checked = false;
   end

   function isSurrounded()
      return liberties = 0;
   end

   function isChecked()
      return checked;
   end;

   function check(value)
      checked = value;
   end;

   function removeLiberty(place)
      surrounds[place] = false;
      liberties -= 1;
   end

   function setLiberty(place)
      surrounds[place] = true;
      liberties += 1;
   end

   function setIndex(i)
      id = i;
   end

   function getColour()
      return colour;
   end

   function getXY()
      return [this.x, this.y];
   end;

end
