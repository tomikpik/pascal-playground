program sokoban;
uses crt,dos;
type stav=record
             sx,sy,bx,by:-1..12;
             pred:0..9900;
          end;
     mapa=array[1..10,1..10] of 0..9;
     histstavu=array[0..9900] of stav;
     t=array[1..4]of record x,y:integer end;
var a:char;
    i:0..3;

procedure nab(b:integer);
const x=7; y=5;
begin
   clrscr;
   gotoxy(x,y);     write('Vytvareni mapy');
   gotoxy(x,y+1);   write('Reseni mapy');
   gotoxy(x,y+2);   write('Konec');
   gotoxy(x-2,y+b); write('*');
   gotoxy(80,24);
end;

procedure VM;
const x=5; y=5;
var a:char; m:mapa; i,j:0..11; k,l:1..10;
    vystup:text;
    nazev:string[8];
begin
   clrscr;
   write('Zadejte nazev nove mapy: '); readln(nazev);
   for i:=0 to 11 do
   begin
      gotoxy(x+i,y); write('Û');
      gotoxy(x+i,y+11); write('Û');
      gotoxy(x,y+i); write('Û');
      gotoxy(x+11,y+i); write('Û');
   end;
   window(x+1,y+1,x+10,y+11);
   for i:=1 to 10 do
      for j:=1 to 10 do
         m[i,j]:=0;
   k:=1; l:=1;
   repeat
      gotoxy(k,l);
      a:=readkey;
      if a=#0 then
      begin
         a:=readkey;
         case a of
            #72:if l>=2 then dec(l);
            #80:if l<=9 then inc(l);
            #75:if k>=2 then dec(k);
            #77:if k<=9 then inc(k);
         end;
      end
      else
      if a<>#27 then
      begin
         case a of
            'z','Z':if m[k,l]=1 then m[k,l]:=0 else m[k,l]:=1;
            'b','B':if m[k,l]=2 then m[k,l]:=0 else m[k,l]:=2;
            's','S':if m[k,l]=3 then m[k,l]:=0 else m[k,l]:=3;
            'c','C':if m[k,l]=4 then m[k,l]:=0 else m[k,l]:=4;
         end;
         for j:=1 to 10 do
           for i:=1 to 10 do
           begin
              gotoxy(i,j);
              case m[i,j] of
                 0:write(' ');
                 1:write('Û');
                 2:write('±');
                 3:write(#1);
                 4:write('C');
              end;
           end;
      end;
   until a=#27;
   assign(vystup,nazev+'.txt');
   rewrite(vystup);
   for j:=1 to 10 do
   begin
      for i:=1 to 10 do write(vystup,m[i,j]);
      writeln(vystup);
   end;
   close(vystup); window(1,1,80,25);
end;

procedure rm;
   procedure nacti(jm:string; var m:mapa);
   var vs:text; i,j:integer; a:char;
   begin
      assign(vs,jm+'.txt'); reset(vs);
      i:=1; j:=1;
      for J:=1 to 10 do
      begin
         for i:=1 to 10 do
         begin
            read(vs,a);
            m[i,j]:=ord(a)-48;
         end;
         readln(vs);
      end;
      close(vs);
   end;
   procedure vp(m:mapa);
   var x,y:1..12;
   begin
      clrscr;
      for y:=1 to 12 do
      begin
         gotoxy(y,1); write(#219);
         gotoxy(y,12); write(#219);
         gotoxy(1,y); write(#219);
         gotoxy(12,y); write(#219);
      end;
      for y:=1 to 10 do
      begin
         for x:=1 to 10 do
         begin
            gotoxy(x+1,y+1);
            case m[x,y] of
               0:write(' ');
               1:write(#219);
            end;
         end;
         writeln;
      end;
   end;

var hs:histstavu; m:mapa; cx,cy,i,j,x,y,s,q,p:integer;
    up:boolean; tah:t; ast:stav; a:char;
    nazev:string[8]; vysl:array[1..150] of stav;
begin
   clrscr;
   write('Zadejte nazev mapy: ');
   readln(nazev); nacti(nazev,m);
   for y:=1 to 10 do
      for x:=1 to 10 do
      begin
         case m[x,y] of
            2:begin hs[1].bx:=x; hs[1].by:=y; m[x,y]:=0; end;
            3:begin hs[1].sx:=x; hs[1].sy:=y; m[x,y]:=0; end;
            4:begin cx:=x; cy:=y; m[x,y]:=0; end;
         end;
      end;

   hs[1].pred:=0;
   tah[1].x:= 1; tah[1].y:= 0; tah[2].x:=-1; tah[2].y:= 0;
   tah[3].x:= 0; tah[3].y:= 1; tah[4].x:= 0; tah[4].y:=-1;
   i:=1; j:=2; s:=1;

   repeat
      up:=true;
      ast:=hs[i];
      with ast do
      begin
         sx:=sx+tah[s].x; sy:=sy+tah[s].y;
         if((sx=bx)and(sy=by))then
         begin
            bx:=bx+tah[s].x;
            by:=by+tah[s].y;
         end;

         if((sx>10)or(sx<1)or(sy>10)or(sy<1)or(bx>10)or(bx<1)or(by>10)or(by<1))then up:=false;

         if up then
         for y:=1 to 10 do
            for x:=1 to 10 do
            begin
            if((m[x,y]=1)and(((sx=x)and(sy=y)or((bx=x)and(by=y))))) then up:=false;
            end;

         if up then
         for p:=1 to j-1 do
         if((hs[p].sx=sx)and(hs[p].sy=sy)and(hs[p].bx=bx)and(hs[p].by=by))then up:=false;
      end;
      if up then begin hs[j]:=ast; hs[j].pred:=i; inc(j); end;
      inc(s);
      if s=5 then begin s:=1; inc(i); end;
   until((hs[j-1].bx=cx)and(hs[j-1].by=cy))or(i=j);

   if i<>j then
   begin
      dec(J); q:=0;
      repeat
         inc(q);
         vysl[q]:=hs[j];
         j:=hs[j].pred;
      until j=0;

      i:=q;
      vp(m);
      gotoxy(vysl[i].sx+1,vysl[i].sy+1); write(#1);
      gotoxy(vysl[i].bx+1,vysl[i].by+1); write(#177);
      gotoxy(cx+1,cy+1); write('C');

      repeat
         gotoxy(80,24);
         a:=readkey;
         if a=#0 then a:=readkey;

         if((a=#75)or(a=#77))then
         begin
            gotoxy(vysl[i].sx+1,vysl[i].sy+1); write(' ');
            gotoxy(vysl[i].bx+1,vysl[i].by+1); write(' ');
            gotoxy(cx+1,cy+1); write('C');
            case a of
               #75:if i<q then inc(i);
               #77:begin
                      if i>1 then dec(i)
                      else
                      begin gotoxy(25,10); write('KONEC - pro odchod stiskni ESC'); end;
                   end;
            end;
            gotoxy(vysl[i].sx+1,vysl[i].sy+1); write(#1);
            gotoxy(vysl[i].bx+1,vysl[i].by+1); write(#177);
         end;

      until a=#27;
   end
   else
   begin
      clrscr;
      write('Tato mapa nema reseni. Pro navrat do menu stisknete ESC');
      repeat
         a:=readkey;
      until a=#27;
   end;
end;

begin
   window(1,1,80,25); i:=0;
   repeat
      nab(i);
      a:=readkey;
      if a=#0 then
      begin
         a:=readkey;
         case a of
            #72:if i=0 then i:=2 else dec(i);
            #80:if i=2 then i:=0 else inc(i);
         end;
      end
      else
      if a=#13 then
      case i of
         0:VM;
         1:RM;
         2:exit;
      end;
   until a=#27;
end.
