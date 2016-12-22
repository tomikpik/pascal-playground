program Piskvory;
uses Crt, Pisk;
var X, Y: byte;
    Jmeno1, Jmeno2: string[20];  {jmena hracu s krizkem a s koleckem}


//zacatek procedura TAH1
procedure Tah1(Kdo: Barva; var X, Y: byte);  {hrac - clovek}  
   const smer:array[1..4,1..2] of -1..1 = ((1,0),(1,1),(0,1),(-1,1)); {x=1, y=2; po smìru ruèièek}
   type Tmapa = array[-4..N+4,-4..N+4] of barva;
        Ttahy=array[1..400,1..3] of integer;
   var 
       mapa:Tmapa;
   
   //zacatek nactiMapu
   procedure nactiMapu(var mapa:Tmapa); {Naètení mapy}
   var x,y:integer;
   begin
      for y:=-3 to N+4 do
         for x:=-3 to N+4 do begin
            mapa[x,y]:=Nic;
            if(x in[1..N])and(y in[1..N]) then mapa[x,y]:=Co(x,y);
         end;
   end;
   //konec nactiMapu
   
   
   //zacatek SOF
   procedure SOF(mapa:Tmapa; var x,y:byte; kdo:barva);
   const Hutok:array[0..4] of longint =(0,30,100,500,60000);
         Hobrana:array[0..4] of longint =(0,20,1000,5000,30000);
   var hodnota:array[1..n,1..n]of longint;
       k,l,i,j,s,t,c,max,utok,obrana:longint;
   begin
      max:=-maxint;
      for j:=1 to N do
         for i:=1 to N do
         begin 
            if mapa[i,j]=Nic then 
            begin//pro všechny body, které jsou prázdné
               hodnota[i,j]:=0;              
               for k:=1 to 4 do begin //vyzkoušej všechny smìry
                  for l:=4 downto 0 do begin//vyzkoušej všechny pìtice
                     s:=i-(l*smer[k,1]);
                     t:=j-(l*smer[k,2]);
                     utok:=0;
                     obrana:=0;
                     for c:=1 to 5 do begin
                        if mapa[s,t]=Kdo then inc(utok) else
                        if(mapa[s,t]<>Nic)then inc(obrana);
                        s:=s+smer[k,1];
                        t:=t+smer[k,2];
                     end;
                     if(utok>0)and(obrana>0)then begin utok:=0; obrana:=0; end;
                     hodnota[i,j]:=hodnota[i,j]+Hutok[utok]+Hobrana[obrana];                  
                  end;
               end;         
               if hodnota[i,j]>max then begin
                  max:=hodnota[i,j];
                  x:=i;
                  y:=j;
               end;
            end;
         end;
   end;
   //konec SOF
   
begin
   nactiMapu(mapa);  
   Sof(mapa,x,y,kdo);
end;
//konec procedura TAH1






//zacatek procedura TAH2
procedure Tah2(Kdo: Barva; var X, Y: byte);  {hrac - clovek}
var Z:char;
begin
  GotoXY(X+1,Y+1);
  repeat
    Z:=ReadKey;
    case Z of
      #27: begin X:=0; Y:=0; break end;
      #13: if Co(X,Y)=Nic then break;
      #0:  begin
             Z:=ReadKey;
             case Z of
               #72: if Y>1 then dec(Y);
               #75: if X>1 then dec(X);
               #77: if X<N then inc(X);
               #80: if Y<N then inc(Y);
             end;
             GotoXY(X+1,Y+1)
           end
    end
  until false;
  while KeyPressed do Z:=ReadKey;
  GotoXY(1,N+4);
end; {Tah2}


//konec procedura TAH2

//zacatek hlavniho programu
begin
  Jmeno1:='Pocitac';
  Jmeno2:='Clovek';
  KdoJeKdo(Jmeno2, Jmeno1);
  X:=N div 2 +1; Y:=N div 2; {pocatecni kolecko}
  while true do
  begin
    Tah2(Krizek, X, Y);
    if Konec(Jmeno1, Krizek, X, Y) then break;
    Tah1(Kolecko, X, Y);
    if Konec(Jmeno2, Kolecko, X, Y) then break;
  end
end.
//konec hlavniho programu
