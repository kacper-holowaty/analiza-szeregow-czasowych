# czyszczenie przestrzeni roboczej 
rm(list=ls(all=TRUE))

# zassanie danych
dane=read.table("grecja-gva.csv", header=TRUE, sep=";", dec=",", fileEncoding= "Windows-1250")
dane

# utworzenie macierzy danych
mdane=as.matrix(dane)
mdane

# pierwsze różnicowanie w celu usunięcia trendu
d_gva = mdane[2:nrow(mdane), 2] - mdane[1:(nrow(mdane)-1), 2]
length(d_gva)
mdane = cbind(mdane, c(NA, d_gva))

# wliczenie wskaźników sezonowości
# surowe
daty = as.character(mdane[,1])
daty6 = substr(daty, start = 6, stop = 6)
ind.q1 = (daty6 == "1")
ind.q2 = (daty6 == "2")
ind.q3 = (daty6 == "3")
ind.q4 = (daty6 == "4")

sws.q1 = mean(mdane[ind.q1,3], na.rm = T)
sws.q2 = mean(mdane[ind.q2,3], na.rm = T)
sws.q3 = mean(mdane[ind.q3,3], na.rm = T)
sws.q4 = mean(mdane[ind.q4,3], na.rm = T)
sws.q1
sws.q2
sws.q3
sws.q4

# oczyszczone
mean.sws = mean(c(sws.q1, sws.q2, sws.q3, sws.q4))
mean.sws

ows.q1 = sws.q1 - mean.sws
ows.q2 = sws.q2 - mean.sws
ows.q3 = sws.q3 - mean.sws
ows.q4 = sws.q4 - mean.sws

# wyrównanie sezonowe
mdane=cbind(mdane, NA)
mdane[ind.q1, 4] = mdane[ind.q1, 3] - ows.q1
mdane[ind.q2, 4] = mdane[ind.q2, 3] - ows.q2
mdane[ind.q3, 4] = mdane[ind.q3, 3] - ows.q3
mdane[ind.q4, 4] = mdane[ind.q4, 3] - ows.q4
mdane

# wykres
DaneWykres=mdane[,2:4]
Ymin=min(DaneWykres, na.rm=TRUE) * 1.05
Ymax=max(DaneWykres, na.rm=TRUE) * 1.05
s1=seq(from=Ymin, to=Ymax, len=nrow(DaneWykres))

# automatyczne utworzenie obszaru rysowania
plot(s1, col="white", axes=FALSE, xlab=NA, ylab=NA, main=NA)

# dodanie osi odciętych (poziomej)
par(las=1, ps=8, lwd=2)
axis(side=1, at=1:nrow(DaneWykres), labels=1:nrow(DaneWykres), pos=Ymin, tck=-0.02)

aty=seq(from=Ymin, to=Ymax, len=5)
axis(side=2, pos=1, at=aty, labels=round(aty,1), tck=-0.02)

par(lwd=3)
lines(DaneWykres[,1], type="l", col="red")
lines(DaneWykres[,2], type="l", col="blue")
lines(DaneWykres[,3], type="l", col="magenta")

par(ps=12)
mtext(text="GVA Grecji w latach 2017-2025", side=3, line=1)

par(ps=8)
mtext(text="Kwartały lat 2017-2025", side=1, line=2)

par(las=0)
mtext(text="Miliony Euro", side=2, line=3)
