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

# wykres główny
n = nrow(mdane)
czas = 1:n

par(mar=c(6,5,2,2))

plot(czas, mdane[,2], type="l", col="blue", lwd=2,
     main="Analiza zmian wartości dodanej brutto (GVA) dla Grecji",
     xlab="", ylab="Wartość",
     ylim=c(min(mdane[,c(2,3,4)], na.rm=T), max(mdane[,c(2,3,4)], na.rm=T)),
     xaxt="n")
lines(czas, mdane[,3], col="orange", lwd=2)
lines(czas, mdane[,4], col="green3", lwd=2)
abline(h=0, col="gray", lty=2)
axis(1, at=seq(1, n, by=4), labels=mdane[seq(1, n, by=4), 1], las=2, cex.axis=0.8)

# legenda pod wykresem, poza obszarem kreślenia
par(xpd=TRUE)
legend(x=grconvertX(0.5, from="npc", to="user"), 
       y=grconvertY(0, from="npc", to="user") - 0.34*diff(par("usr")[3:4]),
       legend=c("GVA", "Przyrost kwartalny", "Wahania losowe"),
       col=c("blue", "orange", "green3"), 
       lwd=2, cex=0.9, bg="white", horiz=TRUE, xjust=0.5, yjust=1)
par(xpd=FALSE)

# przywrocenie marginesow
par(mar=c(5,4,4,2))
