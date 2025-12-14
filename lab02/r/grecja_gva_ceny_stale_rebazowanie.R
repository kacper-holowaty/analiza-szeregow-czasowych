# czyszczenie przestrzeni roboczej 
rm(list=ls(all=TRUE))

# zassanie danych
dane=read.table("grecja_gva_ceny_stale_rebazowanie.csv", header=TRUE, sep=";", dec=",")
dane

# sprawdzenie typów zmiennych w kolumnach, gva i gva2020 muszą być typu 'numeric'
str(dane)

# dane w cenach bieżących
CBq = as.matrix(dane[,c(1,2)])
CBq

# dane w cenach stałych
CSq = as.matrix(dane[,c(1,3)])
CSq

# indeksy identyfikujące lata i kwartały
daty.ch = as.character(CSq[,1])
ind.yq = substr(daty.ch, start=1, stop=4)
daty6 = substr(daty.ch, start=6, stop=6)

ind.q1 = (daty6=="1")
ind.q2 = (daty6=="2")
ind.q3 = (daty6=="3")
ind.q4 = (daty6=="4")

# obliczanie rocznego gva w cenach stałych 2020
CSy = tapply(X=CSq[,2], INDEX=ind.yq, FUN=sum)
CSy = as.matrix(CSy)

# obliczanie rocznego gva w cenach bieżących
CBy = tapply(X=CBq[,2], INDEX=ind.yq, FUN=sum)
CBy = as.matrix(CBy)

# indeksy lancuchowe, roczny i kwartalny
iy = CSy[2:nrow(CSy), 1]/CSy[1:(nrow(CSy)-1), 1]
iy = c(NA, iy)
iy

iq = CSq[2:nrow(CSq), 2]/CSq[1:(nrow(CSq)-1), 2]
iq = c(NA, iq)
iq

# liczymy gva w cenach stałych wybranego roku bazowego
RokB = 1995

# macierz 3 kolumny: daty, ceny bieżące, indeks łańcuchowy
CSCBy = cbind(as.numeric(row.names(CSy)), CBy, iy)

ind.yy = CSCBy[,1]
CSyB = as.matrix(CSCBy[,2])
CSyB[ind.yy!=RokB, 1] = NA

# indeksy wskazujące lata następujące po bazowym i przed bazowym
ind.po = (ind.yy>RokB)
ind.przed = !ind.po

for (i in 1:length(ind.po)) {
  if (ind.po[i]==TRUE) CSyB[i,1]=CSyB[(i-1), 1]*iy[i]
}

for (i in length(ind.przed):1) {
  if (ind.przed[i]==TRUE) CSyB[(i-1),1]=CSyB[i, 1]/iy[i]
}

CSCBy = cbind(CSCBy, CSyB)
CSCBy

# to samo co z rocznymmi robimy z kwartalnymi
# macierz 3 kolumny: daty, ceny bieżące, indeks łańcuchowy
CSCBq = cbind(CBq, iq, NA)
CSCBq

# z danych kwartalnych wybieramy indeksy roku bazowego do wyliczenia
# początkowej wartości z kwartału 1 roku bazowego
i2 = which(CSCBq[,1]==(RokB+0.2))
i2 = CSCBq[i2,3]

i3 = which(CSCBq[,1]==(RokB+0.3))
i3 = CSCBq[i3,3]

i4 = which(CSCBq[,1]==(RokB+0.4))
i4 = CSCBq[i4,3]

i2;i3;i4

mianownik = 1 + i2 + i2*i3 + i2*i3*i4

iy2 = which(CSCBy[,1]==RokB)
iy2

licznik = CSCBy[iy2,4]
licznik

# xx to kwartalna wartość w cenach stałych pierwszego kwartału roku wybranego jako bazowy
xx = licznik/mianownik
xx

i1=which(CSCBq[,1]==(RokB+0.1))
CSCBq[i1,4] = xx
CSCBq

# indeksy wskazujące kwartały następujące po pierwszym kwartale roku bazowego 
# oraz wskazujące kwartały przed pierwszym kwartałem roku bazowego
ind.po = (CSCBq[,1]>(RokB+0.1))
ind.przed = !ind.po


for (i in 1:length(ind.po)) {
  if (ind.po[i]==TRUE) CSCBq[i,4]=CSCBq[(i-1), 4]*CSCBq[i,3]
}

for (i in length(ind.przed):1) {
  if (ind.przed[i]==TRUE) CSCBq[(i-1),4]=CSCBq[i,4]/CSCBq[i,3]
}

CSCBq=as.data.frame(CSCBq)
names(CSCBq) = c("daty", "gva ceny biez", "ind.lan", paste("gva",RokB,sep="_"))
CSCBq


# wykres
DaneWykres=CSCBq[,c(2,4)]
DaneWykres
Ymin=min(DaneWykres, na.rm=TRUE) * 1.05
Ymax=max(DaneWykres, na.rm=TRUE) * 1.05
s1=seq(from=Ymin, to=Ymax, len=nrow(DaneWykres))

# automatyczne utworzenie obszaru rysowania
plot(s1, col="white", axes=FALSE, xlab=NA, ylab=NA, main=NA)

# dodanie osi odciętych (poziomej)
par(las=3, ps=8, lwd=2)
axis(side=1, at=1:nrow(DaneWykres), labels=CSCBq[,1], pos=Ymin, tck=-0.02)

aty=seq(from=Ymin, to=Ymax, len=5)
axis(side=2, pos=1, at=aty, labels=round(aty,1), tck=-0.02)

par(lwd=3)
lines(DaneWykres[,1], type="l", col="red")
lines(DaneWykres[,2], type="l", col="blue")

par(ps=12)
mtext(text="GVA Grecji w latach 1995-2025", side=3, line=1)

par(ps=8)
mtext(text="Kwartały lat 1995-2025", side=1, line=2)

par(las=0)
mtext(text="Miliony Euro", side=2, line=3)

