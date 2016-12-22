uses crt,dos;
type pol_menu = array [1..5] of record
                                   nazev,pm1,pm2:string[14];
                                   sp1,sp2:byte;  {spusteni procedury jedna a dva}
                                end;
     souradnice = record
                     x,y:integer;
                  end;

     prof = record
               p:array[1..10] of record
                                    jmeno:string[20];
                                    uroven:array[1..11] of record
                                                              ok:boolean;
                                                              cas:longint;
                                                           end;
                                    obtiznost:1..3;
                                    skore:word;
                                    barva:9..15;
                                 end;
               pp:0..10;
            end;
     mapy = array[1..10] of record      {10 map}
                               prekazka:array[1..400] of souradnice;
                               pp:0..400;      {pocet prekazek}
                               pph:souradnice; {pocatecni pozice hada}
                               psh:0..3; {pocatecni smer hada}
                            end;
     prf = record
              profil,level:byte;
           end;
     had_ds = record
                  th:array[1..1000] of souradnice;  {telo hada}
                  dh:1..1000; sh:0..3;  {delka hada, smer hada}
               end;



procedure menu;

var a: char;
    m:pol_menu;
    i: integer;


   procedure pozadi;
   const a='Cervik';
   var k:integer;

   begin
      textbackground(0); textcolor(14); clrscr;
      gotoxy(round(40-(length(a) / 2)),2); write(a);
      for k:=10 to 70 do
      begin
        gotoxy(k,38); write(#177);
        gotoxy(k,42); write(#177);
      end;
   end;

   procedure VykrMenu(m:pol_menu;i:integer);
   var j,pom, pozice:integer;
   begin
      for j:=10 to 70 do
      begin
         gotoxy(j,40); write(' ');
      end;
      for j:=1 to 3 do
      begin
         case j of
         1: begin
               pozice:=i-1;
               if pozice=0 then pozice:=5;
            end;
         2: begin pozice:=i; textcolor(15); end;
         3: begin
               pozice:=i+1;
               if pozice=6 then pozice:=1;
            end;
         end;
         pom:=(j*20)-(length(m[pozice].nazev) div 2);
         gotoxy(pom,40);
         write(m[pozice].nazev);
         textcolor(14);
      end;
      gotoxy(80,49);
   end;

   procedure ramecek;
   var i:integer;
   begin
      for i:=20 to 60 do
      begin
         gotoxy(i,10);write(#177);
         gotoxy(i,25);write(#177);
      end;
   end;

   procedure smaz_ramecek;
   var i,j:integer;
   begin
      for i:=20 to 60 do
         for j:=10 to 25 do
         begin
            gotoxy(i,j);write(' ');
         end;
   end;


  procedure rekordy;

      var s:prof;
      us:file of prof;
      i,j,k:integer;
      spr:array[1..10] of record jmeno:string[20]; doba:longint; end;
      begin
         ramecek;

         assign(us,'profily.dat');
         {$I-} reset(us); {$I+}
         if IOResult=0 then
         begin
            read(us,s);
            close(us);
            k:=0;

            for i:=1 to 10 do
            begin
               if s.p[i].uroven[11].ok then
               begin
                  inc(k);
                  spr[k].jmeno:=s.p[i].jmeno;
                  spr[k].doba:=s.p[i].uroven[1].cas;
                  for j:=2 to 10 do spr[k].doba:=spr[k].doba+s.p[i].uroven[j].cas;
                  gotoxy(22,11+k); write('Hrac ',spr[k].jmeno,' udelal celych 10 urovni za ',round(spr[k].doba / 100),' sekund.');
               end;


            end;
            while keypressed do readkey; repeat until keypressed;
         end
         else
         begin
            gotoxy(22,12); write('Neexistuje zadny profil.');
            repeat until keypressed; readkey;
         end;
         smaz_ramecek;
      end;



   procedure Pomoc;
   var v:text;
       a:string;
       i:byte;
   begin
     i:=0;
     assign(v,'help.txt');
     ramecek;
     {$I-} reset(v); {$I+}
     if IOResult=0 then
     while not seekeof(v) do
     begin
        readln(v,a);
        gotoxy(22,12+i);
        write(a);
        inc(i);
     end
     else
     begin
        gotoxy(22,12); write('Soubor s napovedou se nenachazi ve');
        gotoxy(22,13); write('stejnem adresari jako program! ');
     end;
     gotoxy(20,24); write('Pro navrat stisknete libovolnou klavesu..');
     gotoxy(80,49);
     while keypressed do readkey;
     repeat until keypressed; readkey;
     smaz_ramecek;
   end;



   procedure VykrPodmenu(m:pol_menu;i:integer);

      procedure vykr_nadp(m:pol_menu;k,i:integer);
      var b:byte;
      begin
         b:=14; if k=1 then begin b:=15; textcolor(b); end;
         gotoxy((40-length(m[i].pm1) div 2),34); write(m[i].pm1);
         if b=15 then b:=14 else b:=15; textcolor(b);
         gotoxy((40-length(m[i].pm2) div 2),36); write(m[i].pm2);
         gotoxy(32,34);write(' '); gotoxy(47,34);write(' ');
         gotoxy(32,36);write(' '); gotoxy(47,36);write(' ');
         textcolor(15);
         gotoxy(32,32+k*2);write('*'); gotoxy(47,32+k*2);write('*');
         textcolor(14);
      end;

      procedure Jeden_Hrac;
      var s:prof;
          us:file of prof;
          cp:prf;
          x,y:word;

      function vyberprofil(s:prof):prf;
         procedure vykr_sezn_prof(s:prof;i:integer);
         var j:integer;
         begin
            for j:=1 to s.pp do
            begin
            gotoxy(22,11+j); write('  ',s.p[j].jmeno);
            end;
            gotoxy(22,11+i); write('*');
            gotoxy(80,48);
         end;

         function vykr_sezn_lvl(s:prof;i:word):word;
         var j,k:integer;
             a:char;
             m,x,y:word;
         begin
            m:=1;
            for x:=20 to 60 do
            for y:=11 to 24 do
            begin
               gotoxy(x,y);write(' ');
            end;
            repeat
            k:=0;
            for j:=1 to 10 do
               begin
               if s.p[i].uroven[j].ok=true then begin gotoxy(22,11+j); write('  Uroven ',j); inc(k); end;
               end;
               gotoxy(22,11+m); write('*');
               gotoxy(80,48);
               a:=readkey;
               if a=#0 then
               begin
                  a:=readkey;
                  case a of
                     #72: if m>1 then dec(m);
                     #80: if m<k then inc(m);
                  end;
               end
            until a=#13;
            vykr_sezn_lvl:=m;
         end;

      var i,j: word; a:char;
      begin
         i:=1;
         repeat
            vykr_sezn_prof(s,i);
            a:=readkey;
            if a=#0 then
            begin
               a:=readkey;
               case a of
                  #72: if i>1 then dec(i);
                  #80: if i<s.pp then inc(i);
               end;
            end else
            if a=#13 then
            begin
            j:=vykr_sezn_lvl(s,i);
            end;

         until((a=#13)or(a=#27));
         if a=#27 then
         begin
            vyberprofil.profil:=0; vyberprofil.level:=0;
         end else
         begin
            vyberprofil.profil:=i; vyberprofil.level:=j;

         end;
      end;

      procedure had(var pr:prof; var cp:byte; cl:byte);

            procedure nacti_mapu(var m:mapy);
            var vstup:text;
                i,j,k,l:word;
                a:char;
            begin
            assign(vstup,'mapy.txt');
            reset(vstup);
            for i:=1 to 10 do
            begin
               with m[i] do
               begin
                  pp:=0;
                  for j:=1 to 400 do with prekazka[j] do
                  begin x:=0; y:=0; end;
                  pph.x:=0; pph.y:=0;
                  psh:=0;
                  for k:=1 to 20 do
                  begin
                     for l:=1 to 40 do
                     begin
                        read(vstup,a);
                        case a of
                           '1':begin inc(pp); prekazka[pp].x:=l; prekazka[pp].y:=k; end; {podle nacteneho znaku z textoveho}
                           '2':begin pph.x:=l; pph.y:=k; psh:=0; end;                    {souboru provede danou operaci}
                           '3':begin pph.x:=l; pph.y:=k; psh:=1; end;
                           '4':begin pph.x:=l; pph.y:=k; psh:=2; end;
                          '5':begin pph.x:=l; pph.y:=k; psh:=3; end;
                        end;
                     end;
                     readln(vstup,a);
                  end;
               end;
            end;
            close(vstup);
            end;

            procedure udelej_jidlo(var x,y:integer;var t:byte; var jn:boolean);
            begin
               jn:=false; {jidlo nelze}
               x:=random(40)+20;
               y:=random(20)+6;
               t:=random(6);
            end;

            procedure vykr_jidlo(x,y:integer;t:byte);
            begin
               gotoxy(x,y);
               case t of
                  0:begin textcolor(2); write(#162); end;  {jablko}
                  1:begin textcolor(12); write(#3); end;  {srdce cervene}
                  2:begin textcolor(8); write(#3); end;   {srdce sede}
                  3:begin textcolor(14); write(#36); end;   {dolar}
                  4:begin textcolor(9); write(#247); end;   {voda modra}
                  5:begin textcolor(10); write(#247); end;   {voda zelena}
               end;
               textcolor(pr.p[cp].barva);
            end;

         const bpkd:array[1..10] of word = (100,200,300,400,500,600,700,800,900,1000);  {body potrebne k dokonceni urovne}
         var h:had_ds;
             jidlo: array[1..4] of record s:souradnice; typ:0..5; end;
             pk:byte;  {pocet kroku}
             a:char; i,j:integer;kr_prov,jidlo_nejde,konec,hotovo:boolean; {krok proveden, jidlo nelze vygenerovat}
             hod,min,sec,sec100:word;
             doba,body:longint; cekani:byte;
             m:mapy;  {promenna s ulozenymi mapami}
         begin
            while keypressed do readkey;
            nacti_mapu(m);
            for i:=1 to m[cl].pp do
            begin
               gotoxy(m[cl].prekazka[i].x+19,m[cl].prekazka[i].y+5);
               write(#177);
            end;
            pk:=0;
            h.sh:=m[cl].psh;
            h.dh:=3;
            konec:=false; hotovo:=false; pk:=0;
            kr_prov:=true;
            body:=0;
            case pr.p[cp].obtiznost of
            1:cekani:=150;
            2:cekani:=100;
            3:cekani:=50;
            end;

            for i:=1 to h.dh do with h.th[i] do   {prirazeni pocatecni pozice vsem bodum}
            begin
               x:=m[cl].pph.x+19; y:=m[cl].pph.y+5;
            end;

            for i:=1 to 3 do with jidlo[i] do          {vygenerovani noveho jidla}
            begin
               repeat
                  udelej_jidlo(s.x,s.y,typ,jidlo_nejde);
                  for j:=1 to h.dh do if(s.x=h.th[j].x)and(s.y=h.th[j].y)then jidlo_nejde:=true;   {kontroluje vypis na hada}
                  for j:=1 to m[cl].pp do
                     if((m[cl].prekazka[j].x+19=s.x)and(m[cl].prekazka[j].y+5=s.y))then jidlo_nejde:=true;   {kontroluje vypis na prekazku}
               until not jidlo_nejde;
               vykr_jidlo(s.x,s.y,typ);
            end;

            GetTime(hod,min,sec,sec100);
            doba:=sec100+(sec*100)+(min*6000)+(hod*360000);

            repeat
               if keypressed then
               begin
                  a:=readkey; if a=#0 then a:=readkey;
                  if kr_prov=true then
                  begin
                     case a of                              {rozliseni smeru podle sipek}
                        #72:if h.sh in[0,2] then h.sh:=1;   {nahoru}
                        #75:if h.sh in[1,3] then h.sh:=0;   {vlevo}
                        #77:if h.sh in[1,3] then h.sh:=2;   {vpravo}
                        #80:if h.sh in[0,2] then h.sh:=3;   {dolu}
                     end;
                     kr_prov:=false;
                  end
               end
               else
               begin
                  for i:=h.dh downto 1 do h.th[i+1]:=h.th[i];   {posunuti hlavy podle sipkami zvoleneho smeru}
                  case h.sh of
                     0:h.th[1].x:=h.th[2].x-1;
                     1:h.th[1].y:=h.th[2].y-1;
                     2:h.th[1].x:=h.th[2].x+1;
                     3:h.th[1].y:=h.th[2].y+1;
                  end;                                                    {vykresleni hada}
                  gotoxy(h.th[h.dh+1].x,h.th[h.dh+1].y); write(' ');      {mazani zadeèku(anusu)}
                  gotoxy(h.th[2].x,h.th[2].y); write(#9);                 {prepsani druheho clanku}
                  gotoxy(h.th[1].x,h.th[1].y); write(#1);                 {vykresleni hlavy}
                  gotoxy(80,49); delay(cekani);
                  kr_prov:=true;
               end;

               if(h.th[1].x<20)or(h.th[1].x>59)or(h.th[1].y<6)or(h.th[1].y>25) then konec:=true;  {narazeni hada hlavou do okraju}

               for i:=1 to m[cl].pp do
               begin
                  if((m[cl].prekazka[i].x+19 = h.th[1].x)and(m[cl].prekazka[i].y+5 = h.th[1].y)) then konec:=true;  {narazeni hada hlavou do zaludne prekazky}
               end;

               if pk>50 then
               begin
                  with jidlo[4] do         {mizeni jidla po 50 krocich}
                  begin
                     repeat
                        udelej_jidlo(s.x,s.y,typ,jidlo_nejde);
                        for j:=1 to h.dh do if(s.x=h.th[j].x)and(s.y=h.th[j].y)then jidlo_nejde:=true;
                        for j:=1 to m[cl].pp do
                           if((m[cl].prekazka[j].x+19=s.x)or(m[cl].prekazka[j].y+5=s.y))then jidlo_nejde:=true;
                  until not jidlo_nejde;
                  vykr_jidlo(s.x,s.y,typ);
               end;
               gotoxy(jidlo[1].s.x,jidlo[1].s.y); write(' ');
               for j:=1 to 3 do jidlo[j]:=jidlo[j+1];
               pk:=0;
            end;

            for i:=1 to 3 do          {zmizeni jidla po prejeti hlavou - zapocitani jako snezene}
            if (h.th[1].x=jidlo[i].s.x)and(h.th[1].y=jidlo[i].s.y) then
            begin
               case jidlo[i].typ of
               0:inc(body,10);     {jablko}
               1:inc(body,20);     {srdce cervene}
               2:dec(body,20);     {srdce sede}
               3:inc(body,30);     {tolar}
               4:inc(body,15);     {voda modra}
               5:dec(body,15);     {voda zelena}
               end;

               inc(h.dh);
               textcolor(14);
               gotoxy(50,27); write('Body: ',body,'   ');
               with jidlo[4] do
               begin
                  repeat
                     udelej_jidlo(s.x,s.y,typ,jidlo_nejde);
                     for j:=1 to h.dh do if(s.x=h.th[j].x)and(s.y=h.th[j].y)then jidlo_nejde:=true;
                     for j:=1 to m[cl].pp do if((m[cl].prekazka[j].x+19=s.x)or(m[cl].prekazka[j].y+5=s.y))then jidlo_nejde:=true;
                  until not jidlo_nejde;
                  vykr_jidlo(s.x,s.y,typ);
               end;
               for j:=i to 3 do jidlo[j]:=jidlo[j+1];
               pk:=0;
            end;
            for i:=2 to h.dh do
            if(h.th[1].x=h.th[i].x)and(h.th[1].y=h.th[i].y)then konec:=true;

            if body>bpkd[cl] then hotovo:=true;
            if body<0 then konec:=true;
            inc(pk);

         until(a=#27)or(konec)or(hotovo);

         gettime(hod,min,sec,sec100);
         doba:=(sec100+(sec*100)+(min*6000)+(hod*360000)-doba);
         if hotovo then
         begin
            if doba<pr.p[cp].uroven[cl].cas then pr.p[cp].uroven[cl].cas:=doba;
            pr.p[cp].uroven[cl+1].ok:=true;
            gotoxy(20,28); write('Dokazal jsi udelat ',cl,' uroven !');
         end;
         if konec then
         begin
            gotoxy(20,28); write('Tak jsi to nezvladl!');
         end;
         while keypressed do readkey;
         repeat until keypressed;
          gotoxy(50,27); write('                  ');
         gotoxy(20,28); write('                              ');
         textcolor(14);
      end;

      begin
         ramecek;
         assign(us,'profily.dat');
         {$I-} reset(us); {$I+}
         if IOResult<>0 then
         begin
            gotoxy(23,12);
            write('Musis si nejprve vytvorit profil !!!');
            while keypressed do readkey;
            repeat until keypressed;
         end else
         begin
            read(us,s);
            close(us);
            gotoxy(20,24); write('Pro navrat stisknete Esc...');
            cp:=vyberprofil(s);


            if cp.profil<>0 then
            begin
               for x:=19 to 60 do
                  for y:=5 to 26 do
                  begin gotoxy(x,y); if (x=19)or(x=60)or(y=5)or(y=26) then write(#177) else write(' '); end;
               had(s,cp.profil,cp.level);
               for x:=19 to 60 do
                  for y:=5 to 26 do
                  begin gotoxy(x,y); write(' '); end;
            end;
            rewrite(us);
            write(us,s);
            close(us);
         end;
         textcolor(14);
         smaz_ramecek;
      end;
      procedure ukaz_barvu(i,x,y:integer);
         begin
            gotoxy(x,y);write(#17);
            textcolor(i); write(' ',#1#9#9#9#9#9,' ');
            textcolor(14);write(#16);
            gotoxy(80,49);
         end;
      procedure Dva_hraci;
      var bh1,bh2,obt:integer;
         a:char;
         procedure had2(b1,b2,obt:integer);
            procedure udelej_jidlo(var x,y:integer; var jn:boolean);
            begin
               jn:=false; {jidlo nelze}
               x:=random(40)+20;
               y:=random(20)+6;
            end;

            procedure vykr_jidlo(x,y:integer);
            begin
               gotoxy(x,y);
               textcolor(2); write(#162);
            end;
            procedure vypis_body(b1,b2,h1,h2:longint);
            begin
               textcolor(b1); gotoxy(20,27); write('Hrac 1: ',h1,' ');
               textcolor(b2); gotoxy(50,27); write('Hrac 2: ',h2,' ');
            end;


         var h1,h2:had_ds;
         jidlo: array[1..4] of record s:souradnice; typ:0..5; end;
         pk:byte;  {pocet kroku}
         a:char; i,j,y,x,start:integer;
         krp1,krp2,jidlo_nejde:boolean; {krok proveden, jidlo nelze vygenerovat}
         vysl:0..3;
         bh1,bh2:longint;
         begin
            for x:=19 to 61 do
               for y:=5 to 27 do
               begin gotoxy(x,y); write(' '); end;
            for y:=19 to 60 do
            begin
               if y<=38 then
               begin
                  gotoxy(19,y-13); write(#177);
                  gotoxy(60,y-13); write(#177);
               end;
               gotoxy(y,5); write(#177);
               gotoxy(y,26);write(#177);
            end;
            pk:=0; vysl:=0;
            h1.sh:=2;   h2.sh:=0;
            h1.dh:=6;   h2.dh:=6;
            start:=1;
            krp1:=true; krp2:=true;
            bh1:=0; bh2:=0;
            vypis_body(b1,b2,bh1,bh2);
            for i:=1 to 6 do
            begin
               h1.th[i].x:=25;
               h1.th[i].y:=10;
               h2.th[i].x:=55;
               h2.th[i].y:=20;
            end;
            for i:=1 to 3 do with jidlo[i] do          {vygenerovani noveho jidla}
            begin
               repeat
                  udelej_jidlo(s.x,s.y,jidlo_nejde);
                  for j:=1 to h1.dh do if(s.x=h1.th[j].x)and(s.y=h1.th[j].y)then jidlo_nejde:=true;
                  for j:=1 to h2.dh do if(s.x=h2.th[j].x)and(s.y=h2.th[j].y)then jidlo_nejde:=true;   {kontroluje vypis na hada}
               until not jidlo_nejde;
               vykr_jidlo(s.x,s.y);
            end;
            while keypressed do readkey;

            repeat
               if start<6 then inc(start);
               if keypressed then
               repeat
                  a:=readkey;
                  if(a in['w','W','s','S','a','A','d','D'])and(krp1)then
                  begin
                     case a of
                        'w','W':if h1.sh in[0,2] then h1.sh:=1;
                        'a','A':if h1.sh in[1,3] then h1.sh:=0;
                        'd','D':if h1.sh in[1,3] then h1.sh:=2;
                        's','S':if h1.sh in[0,2] then h1.sh:=3;
                     end;

                     krp1:=false;
                  end else
                  if(a in[#72,#75,#77,#80])and(krp2)then
                  begin
                     case a of                              {rozliseni smeru podle sipek}
                        #72:if h2.sh in[0,2] then h2.sh:=1;   {nahoru}
                        #75:if h2.sh in[1,3] then h2.sh:=0;   {vlevo}
                        #77:if h2.sh in[1,3] then h2.sh:=2;   {vpravo}
                        #80:if h2.sh in[0,2] then h2.sh:=3;   {dolu}
                     end;

                     krp2:=false;
                  end;
               until (not keypressed)or((not krp2)and(not krp1));

               for i:=h1.dh downto 1 do h1.th[i+1]:=h1.th[i];   {posunuti hlavy podle sipkami zvoleneho smeru}
               for i:=h2.dh downto 1 do h2.th[i+1]:=h2.th[i];

               case h1.sh of
                  0:h1.th[1].x:=h1.th[2].x-1;
                  1:h1.th[1].y:=h1.th[2].y-1;
                  2:h1.th[1].x:=h1.th[2].x+1;
                  3:h1.th[1].y:=h1.th[2].y+1;
               end;
               case h2.sh of
                  0:h2.th[1].x:=h2.th[2].x-1;
                  1:h2.th[1].y:=h2.th[2].y-1;
                  2:h2.th[1].x:=h2.th[2].x+1;
                  3:h2.th[1].y:=h2.th[2].y+1;
               end;
               textcolor(b1);
               gotoxy(h1.th[h1.dh+1].x,h1.th[h1.dh+1].y); write(' ');
               gotoxy(h1.th[2].x,h1.th[2].y); write(#9);
               gotoxy(h1.th[1].x,h1.th[1].y); write(#1);
               textcolor(b2);
               gotoxy(h2.th[h2.dh+1].x,h2.th[h2.dh+1].y); write(' ');
               gotoxy(h2.th[2].x,h2.th[2].y); write(#9);
               gotoxy(h2.th[1].x,h2.th[1].y); write(#1);
               textcolor(15);
               gotoxy(80,49); delay(150);
               krp1:=true; krp2:=true;

            if(h1.th[1].x<20)or(h1.th[1].x>59)or(h1.th[1].y<6)or(h1.th[1].y>25)then vysl:=3;
            if(h2.th[1].x<20)or(h2.th[1].x>59)or(h2.th[1].y<6)or(h2.th[1].y>25)then vysl:=1;  {narazeni hada hlavou do okraju}
            if pk>50 then
            begin
                  with jidlo[4] do         {mizeni jidla po 50 krocich}
                  begin
                     repeat
                        udelej_jidlo(s.x,s.y,jidlo_nejde);
                        for j:=1 to h1.dh do if(s.x=h1.th[j].x)and(s.y=h1.th[j].y)then jidlo_nejde:=true;
                        for j:=1 to h2.dh do if(s.x=h2.th[j].x)and(s.y=h2.th[j].y)then jidlo_nejde:=true;

                  until not jidlo_nejde;
                  vykr_jidlo(s.x,s.y);
                  end;
               gotoxy(jidlo[1].s.x,jidlo[1].s.y); write(' ');
               for j:=1 to 3 do jidlo[j]:=jidlo[j+1];
               pk:=0;
            end;
            if((h1.th[1].x=h2.th[1].x)and(h1.th[1].y=h2.th[1].y))then vysl:=2;


            for i:=1 to 3 do
            if((jidlo[i].s.x=h1.th[1].x)and(jidlo[i].s.y=h1.th[1].y))then
            begin
               inc(h1.dh); inc(bh1,10);
               with jidlo[4] do
               begin
                  repeat
                     udelej_jidlo(s.x,s.y,jidlo_nejde);
                     for j:=1 to h1.dh do if(s.x=h1.th[j].x)and(s.y=h1.th[j].y)then jidlo_nejde:=true;
                     for j:=1 to h2.dh do if(s.x=h2.th[j].x)and(s.y=h2.th[j].y)then jidlo_nejde:=true;
                  until not jidlo_nejde;
                  vykr_jidlo(s.x,s.y);
               end;
               for j:=i to 3 do jidlo[j]:=jidlo[j+1];
               vypis_body(b1,b2,bh1,bh2);
            end;

           for i:=1 to 3 do
           if((jidlo[i].s.x=h2.th[1].x)and(jidlo[i].s.y=h2.th[1].y))then
           begin
              inc(h2.dh); inc(bh2,10);
              with jidlo[4] do
              begin
                 repeat
                    udelej_jidlo(s.x,s.y,jidlo_nejde);
                    for j:=1 to h1.dh do if(s.x=h1.th[j].x)and(s.y=h1.th[j].y)then jidlo_nejde:=true;
                    for j:=1 to h2.dh do if(s.x=h2.th[j].x)and(s.y=h2.th[j].y)then jidlo_nejde:=true;
                 until not jidlo_nejde;
                 vykr_jidlo(s.x,s.y);
              end;
              for j:=i to 3 do jidlo[j]:=jidlo[j+1];
              vypis_body(b1,b2,bh1,bh2);
           end;

           for i:=2 to h2.dh do
           begin
              if((h2.th[1].x=h2.th[i].x)and(h2.th[1].y=h2.th[i].y))and(start>4) then vysl:=1;
              if((h1.th[1].x=h2.th[i].x)and(h1.th[1].y=h2.th[i].y)) then     {prvni narazi do druheho}
              begin
                 inc(h1.dh,h2.dh-i+1);
                 inc(bh1,(h2.dh-i+1)*5);
                 dec(bh2,(h2.dh-i+1)*5);
                 for j:=i+1 to h2.dh do begin gotoxy(h2.th[j].x,h2.th[j].y); write(' '); end;
                 h2.dh:=i-1;
                 vypis_body(b1,b2,bh1,bh2);
              end;
           end;
           for i:=2 to h1.dh do
           begin
              if((h1.th[1].x=h1.th[i].x)and(h1.th[1].y=h1.th[i].y))and(start>4) then vysl:=3;
              if((h2.th[1].x=h1.th[i].x)and(h2.th[1].y=h1.th[i].y)) then     {druhy narazi do prvniho}
              begin
                 inc(h2.dh,h1.dh-i+1);
                 inc(bh2,(h1.dh-i+1)*5);
                 dec(bh1,(h1.dh-i+1)*5);
                 for j:=i+1 to h1.dh do begin gotoxy(h1.th[j].x,h1.th[j].y); write(' '); end;
                 h1.dh:=i-1;
                 vypis_body(b1,b2,bh1,bh2);
              end;
          end;
          if((bh1>200)or(bh2>200))then if bh2>bh1 then vysl:=3 else vysl:=1;
          if((bh1<0)or(bh2<0))then if bh2>bh1 then vysl:=3 else vysl:=1;
          inc(pk);

         until(a=#27)or(vysl<>0);
         gotoxy(32,28);
         textcolor(14);
         case vysl of
         1:write('Vyhral hrac 1!');
         2:write('Remiza!');
         3:write('Vyhral hrac 2!');
         end;
         gotoxy(80,49); delay(1000);
         while keypressed do readkey;
         repeat until keypressed; readkey;

         for x:=19 to 61 do
               for y:=5 to 29 do
               begin gotoxy(x,y); write(' '); end;


      end;
      begin
         ramecek;
         bh1:=9;
         bh2:=9;
         gotoxy(22,12); write('Vyber barvu hrace 1 ');
         repeat
               ukaz_barvu(bh1,42,12);
               a:=readkey;
               if a=#0 then
               begin

                  a:=readkey;
                  case a of
                     #75:if bh1>9 then dec(bh1);
                     #77:if bh1<15 then inc(bh1);
                  end;
               end;
         until a=#13;
         gotoxy(22,14); write('Vyber barvu hrace 2 ');
         repeat
               ukaz_barvu(bh2,42,14);
               a:=readkey;
               if a=#0 then
               begin

                  a:=readkey;
                  case a of
                     #75:if bh2>9 then dec(bh2);
                     #77:if bh2<15 then inc(bh2);
                  end;
               end;
         until a=#13;

         had2(bh1,bh2,1);

         smaz_ramecek;
      end;



      procedure Novy_Profil;


      var s:prof;
         u:file of prof;
         i,j,b:integer;
         a:char;
      begin
         ramecek;
         assign(u,'profily.dat');
         {$I-} reset(u); {$I+}
         if IOResult<>0 then
         begin
            s.pp:=0;
            for i:=1 to 20 do
            with s.p[i] do
            begin
               jmeno:='';
               for j:=1 to 11 do
               with uroven[j] do
               begin
                  if j=1 then ok:=true else ok:=false;
                  cas:=maxint;
               end;
               obtiznost:=1;
               skore:=0;
            end;
            rewrite(u); write(u,s);
            close(u); reset(u);
         end;
         read(u,s); close(u);
         if s.pp<10 then
         begin
            inc(s.pp);
            gotoxy(21,12); write('Zadejte jmeno: '); readln(s.p[s.pp].jmeno);
            gotoxy(21,14); write('Zadejte obtiznost(1-3): '); repeat gotoxy(45,14); write('          '); gotoxy(45,14); read(a); until a in[#49,#50,#51]; s.p[s.pp].obtiznost:=ord(a)-48;
            gotoxy(21,16); write('Vyberte barvu hada ');
            b:=9;
            repeat
               ukaz_barvu(b,40,16);
               a:=readkey;
               if a=#0 then
               begin

                  a:=readkey;
                  case a of
                     #75:if b>9 then dec(b);
                     #77:if b<15 then inc(b);
                  end;
               end;
            until a=#13;
            s.p[s.pp].barva:=b;
            rewrite(u); write(u,s); close(u);
         end
         else
         begin
            gotoxy(22,12); write('Uz jich tu mame nejak moc. Nemyslis?');
            repeat until keypressed;
            readkey;
         end;

         smaz_ramecek;
      end;

      procedure Upravit_Profil;
         procedure vykr_sezn_prof(s:prof;i:integer);
         var j:integer;
         begin
            for j:=1 to s.pp do
            begin
            gotoxy(22,11+j); write('  ',s.p[j].jmeno);
            end;
            gotoxy(22,11+i); write('*');
            gotoxy(80,49);
         end;
         procedure otevri_profil(var s:prof;i:integer);
            procedure vykr_moz(s:prof;i,p:integer);
            begin
               gotoxy(21,12); write('  Jmeno:  '); textcolor(15); write(s.p[p].jmeno); textcolor(14);
               gotoxy(21,14); write('  Obtiznost:  '); textcolor(15); write(s.p[p].obtiznost); textcolor(14);
               gotoxy(21,16); write('  Barva:  '); textcolor(s.p[p].barva); write(#1#9#9#9#9#9,'  '); textcolor(14);
               gotoxy(21,10+i*2); write('*');
               gotoxy(80,49);
            end;

         var a:char;
             j:integer;
         begin
            smaz_ramecek;
            ramecek;
            j:=1;
            repeat
               vykr_moz(s,j,i);
               a:=readkey;
               if a=#0 then
               begin
                  a:=readkey;
                  case a of
                     #72:if j>1 then dec(j);
                     #80:if j<3 then inc(j);
                  end;
               end else
               if a=#13 then
               begin
                  case j of
                     1:gotoxy(31,10+j*2);
                     2:gotoxy(35,10+j*2);
                     3:gotoxy(31,10+j*2);
                  end;
                  write('                    ');
                  case j of
                     1:begin gotoxy(31,10+j*2); readln(s.p[i].jmeno); end;
                     2:begin repeat gotoxy(35,10+j*2); write('          '); gotoxy(35,10+j*2); read(a); until a in[#49,#50,#51]; s.p[i].obtiznost:=ord(a)-48; end;
                     3:begin gotoxy(31,10+j*2);
                          repeat
                             ukaz_barvu(s.p[i].barva,29,16);
                             while keypressed do readkey;
                             a:=readkey;
                             if a=#0 then
                             begin
                                a:=readkey;
                                case a of
                                  #75:if s.p[i].barva>9 then dec(s.p[i].barva);
                                  #77:if s.p[i].barva<15 then inc(s.p[i].barva);
                                end;
                             end;
                          until a=#13;

                       end;
                  end;

               end;

            until a=#27;
            smaz_ramecek;
            ramecek;
         end;
      var s:prof;
      u:file of prof;
      i,j:integer;
      a:char;
      begin
         ramecek;
         assign(u,'profily.dat');
         {$I-} reset(u); {$I+}
         if IOResult=0 then
         begin
            i:=1;
            read(u,s);
            close(u);
            repeat
               vykr_sezn_prof(s,i);
               a:=readkey;
               if a=#0 then
               begin
                  a:=readkey;
                  case a of
                     #72: if i>1 then dec(i);
                     #80: if i<s.pp then inc(i);
                     #83:begin
                            if s.pp>0 then
                            begin
                               for j:=i to s.pp-1 do s.p[j]:=s.p[j+1];
                               dec(s.pp);
                               if i=s.pp then dec(i);
                               rewrite(u); write(u,s); close(u);
                               smaz_ramecek;
                               ramecek;
                            end;
                         end;
                  end;
               end else
               if a=#13 then
               begin
                  otevri_profil(s,i);
                  rewrite(u); write(u,s); close(u);
               end;

            until a=#27;

         end
         else
         begin
            gotoxy(22,12); write('Neexistuje zadny profil.');
            repeat until keypressed; readkey;
         end;

         smaz_ramecek;
      end;

   var j,k:integer;
       a:char;
   begin
      k:=1;
      for j:=1 to 6 do
      begin
         gotoxy(31,38-j); write(#177#177#177#177#177#177#177#177#177#177#177#177#177#177#177#177#177#177);
         gotoxy(32,39-j); write('                '); delay(45);
      end;
      vykr_nadp(m,k,i);
      repeat
         gotoxy(80,49);
         a:=readkey;
         if a=#0 then
         begin
            a:=readkey;
            case a of
            #72: if k=2 then k:=1;
            #80: if k=1 then k:=2;
            end;
            vykr_nadp(m,k,i);
         end else
         if a=#13 then
         begin
            case k of
               1:case m[i].sp1 of
                    1:Jeden_Hrac;
                    3:Novy_Profil;
                 end;
               2:case m[i].sp2 of
                    2:Dva_hraci;
                    4:Upravit_Profil;
                    6:halt;
                 end;
            end;

         end;

      until ((a=#27)or((a=#13)and(k=1)and(m[i].sp1=5)));

      for j:=1 to 6 do
      begin
         gotoxy(31,31+j); write('                  ');
         gotoxy(32,32+j); write(#177#177#177#177#177#177#177#177#177#177#177#177#177#177#177#177);
         delay(45);
      end;
   end;




begin
   textmode(256);
   with m[1] do begin nazev:='HRA'; pm1:='1 HRAC'; pm2:='2 HRACI'; sp1:=1; sp2:=2; end;
   with m[2] do begin nazev:='NASTAVENI'; pm1:='NOVY PROFIL'; pm2:='UPRAVIT PROFIL '; sp1:=3; sp2:=4; end;
   with m[3] do nazev:='NEJVYSSI SKORE';
   with m[4] do nazev:='POMOC';
   with m[5] do begin nazev:='UKONCIT HRU'; pm1:='NE'; pm2:='ANO'; sp1:=5; sp2:=6; end;

   i:=1;
   pozadi;
   VykrMenu(m,i);
   repeat
      a:=readkey;
      if a=#0 then a:=readkey;
      case a of
      #75: begin                               {vlevo}
              dec(i);
              if i=0 then i:=5;
           end;
      #77: begin                               {vpravo}
              inc(i);
              if i=6 then i:=1;
           end;
      #13: begin
              case i of
              1,2,5: VykrPodmenu(m,i);
              3: Rekordy;
              4: Pomoc;
              end;
           end;
      end;
   VykrMenu(m,i);
   until 1=2;
end;





begin
   randomize;
   menu;
end.
