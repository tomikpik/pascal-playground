unit Pisk;

interface
const N=20; {rozmer hraciho planu}
type Barva = (Nic, Krizek, Kolecko); {obsah policka}

function Co(X, Y: byte): Barva;
function Konec(Kdo: string; B: Barva; X, Y: byte): boolean;
procedure KdoJeKdo(Kdo1, Kdo2: string);


implementation
uses Crt;
var  A: array[1..N,1..N] of Barva;
const D=500; {delay mezi tahy}


procedure Pis(Z:char; X,Y:byte; Novy:Boolean);
{zobrazi tah Z na pozici [X,Y]}
const NovyTah = LightRed;
      KrizekTah = LightGreen;
      KoleckoTah = Yellow;
      Normalni = LightGray;
begin
  if Novy then TextColor(NovyTah)
  else if Z='X' then TextColor(KrizekTah)
  else TextColor(KoleckoTah);
  GotoXY(X,Y);
  write(Z);
  TextColor(Normalni);
  GotoXY(1,N+4);
end; {Pis}


procedure Init;  {inicializace hraciho planu a obrazovky}
var X, Y: byte;
begin
  for X:=1 to N do
    for Y:=1 to N do A[X,Y]:=Nic;
  A[N div 2, N div 2]:=Krizek;
  A[N div 2 + 1, N div 2]:=Kolecko;
  TextMode(Co80+Font8x8);
  ClrScr;
  GotoXY(1,1);
  write('+');
  for X:=2 to N+1 do write('-');
  write('+');
  GotoXY(1,N+2);
  write('+');
  for X:=2 to N+1 do write('-');
  write('+');
  for Y:=2 to N+1 do
  begin
    GotoXY(1,Y); write('|');
    GotoXY(N+2,Y); write('|')
  end;
  Pis('X', N div 2 +1, N div 2 +1, false);
  Pis('O', N div 2 +2, N div 2 +1, false);
end; {Init}


procedure Zprava(S:string);
begin
  write(S);
end; {Zprava}


function Konec(Kdo: string; B: Barva; X, Y: byte): boolean;
  {parametry: jmeno hrace, barva figur, provedeny tah;
   kontroluje korektnost provedeneho tahu,
   vraci true <=> chybny tah nebo konec hry,
   korektni tah zaroven zobrazi na obrazovku}
label 111;

var Z:char; {s cim hrac Kdo hraje - kvuli vypisum}
    Xstr,Ystr: string; {souradnice tahu textove}
    i,j:byte;

begin
  if B=Krizek then Z:='X' else Z:='O';
  Str(X:3, Xstr);
  Str(Y:3, Ystr);
  Konec:=true; {muze nastat konec ... overime}

  if (X<1) or (X>N) or (Y<1) or (Y>N) then
  begin
    Zprava('Tah hrace '+Kdo+' mimo hraci plan na souradnice'+Xstr+Ystr);
    readln;
    exit
  end;

  if A[X,Y]<>Nic then
  begin
    Zprava('Tah hrace '+Kdo+' na obsazene pole'+Xstr+Ystr);
    readln;
    exit
  end;

  A[X,Y]:=B;
  Pis(Z,X+1,Y+1,true);

  i:=1;j:=1;
  while (X-i>=1) and (A[X-i,Y]=B) do inc(i);
  while (X+j<=N) and (A[X+j,Y]=B) do inc(j);
  if i+j>=6 then
  begin
    Zprava('Hrac '+Kdo+' zvitezil tahem '+Xstr+Ystr);
    readln;
    exit
  end;

  i:=1;j:=1;
  while (Y-i>=1) and (A[X,Y-i]=B) do inc(i);
  while (Y+j<=N) and (A[X,Y+j]=B) do inc(j);
  if i+j>=6 then
  begin
    Zprava('Hrac '+Kdo+' zvitezil tahem '+Xstr+Ystr);
    readln;
    exit
  end;

  i:=1;j:=1;
  while (X-i>=1) and (Y-i>=1) and (A[X-i,Y-i]=B) do inc(i);
  while (X+j<=N) and (Y+j<=N) and (A[X+j,Y+j]=B) do inc(j);
  if i+j>=6 then
  begin
    Zprava('Hrac '+Kdo+' zvitezil tahem '+Xstr+Ystr);
    readln;
    exit
  end;

  i:=1;j:=1;
  while (X-i>=1) and (Y+i<=N) and (A[X-i,Y+i]=B) do inc(i);
  while (X+j<=N) and (Y-j>=1) and (A[X+j,Y-j]=B) do inc(j);
  if i+j>=6 then
  begin
    Zprava('Hrac '+Kdo+' zvitezil tahem '+Xstr+Ystr);
    readln;
    exit
  end;

  if KeyPressed then
    if ReadKey=#27 then
    begin
      Zprava('Hra predcasne ukoncena po tahu hrace '+Kdo);
      readln;
      exit
    end;

  for i:=1 to N do
    for j:=1 to N do
      if A[i,j]=Nic then
        goto 111;
  Zprava('Po tahu hrace '+Kdo+' je hraci plan zcela zaplnen - REMIZA');
  readln;
  exit;

  111: {hraje se dal}
  if B=Krizek then Zprava('Na tahu je hrac s O')
              else Zprava('Na tahu je hrac s X');
  Konec:=false;
  Delay(D);
  Pis(Z,X+1,Y+1,false);
end; {Konec}


function Co(X, Y: byte): Barva;
begin
  Co:=A[X,Y]
end; {Co}


procedure KdoJeKdo(Kdo1, Kdo2: string);
begin
  GotoXY(N+6,2);
  write('Hraci v teto partii:');
  Pis('X',N+6,4,false);
  GotoXY(N+8,4);
  write('= ', Kdo1);
  Pis('O',N+6,5,false);
  GotoXY(N+8,5);
  write('= ', Kdo2);
  GotoXY(1, N+4);
  Delay(D)
end; {KdoJeKdo}


begin
Init;
Randomize;
end.
