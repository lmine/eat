require("zoo")
library("RcppRoll")
require("dplyr")
require("ggplot2")
require("reshape2")

EventDescription = c("Unknown","Click","Open","Unsub","Sent")


# origin=as.POSIXlt(strptime("1970-01-01 00:00:00", "%Y-%m-%d %H:%M:%S", tz="UTC"))
# tmp$FirstDate =  as.POSIXlt(tmp$first,origin = origin)
# tmp$LastDate =  as.POSIXlt(tmp$last,origin = origin)


EventLookup <- function(id){
  EventDescription[id]
}

unSub = read.csv("Projects/DS/MSM/ET/unSubInNov2015.csv")
names(unSub) = c("CRMEmailKey","SourceCode","EventTypeId","EventDateTime")
unSub$EventUnixtime = (as.POSIXct(unSub$EventDateTime, format="%d%b%Y:%H:%M:%S"))
unSub$EventUnixdate = (as.POSIXct(unSub$EventDateTime, format="%d%b%Y"))
unSub$EventTypeDescr = sapply(unSub$EventTypeId, EventLookup)


# build summary table

unSub.sent = filter(unSub, EventTypeId == 5) %>% group_by(CRMEmailKey) %>% 
  summarise(firstSent = min(EventUnixtime),
            lastSent = max(EventUnixtime), 
            daysSentActivity =  (max(EventUnixtime)-min(EventUnixtime))/(60*60*24), 
            fSent = n()/(1+(max(EventUnixtime)-min(EventUnixtime))/(60*60*24)),
            cSent = n()) %>%  filter(cSent<10, cSent>1, daysSentActivity < 10) %>%
  arrange(desc(CRMEmailKey))

rollwin <- function(c,t,size) {
  time_s = zoo(c,t)
  time_s.c = merge(time_s, zoo(,seq(start(time_s),end(time_s),by="1 day")), all=TRUE)
  max(rollapply(time_s,size,sum,partial=TRUE))
}

unSub.sent = filter(unSub, EventTypeId == 5) %>% 
  arrange(CRMEmailKey, EventUnixdate) %>%
  group_by(CRMEmailKey, EventUnixdate) %>%
  summarise( c = n()) %>%
  group_by(CRMEmailKey) %>%
  do(data.frame(total = sum(.$c)
                ,burst2 = rollwin(.$c,.$EventUnixdate,2)
                ,burst3 = rollwin(.$c,.$EventUnixdate,3)
                ,burst7 = rollwin(.$c,.$EventUnixdate,7)
                ,burst30 = rollwin(.$c,.$EventUnixdate,30)
                ,firstSent = min(.$EventUnixdate)
                ,lastSent = max(.$EventUnixdate)
                ,daysOpenActivity = max(.$EventUnixdate) - min(.$EventUnixdate)
                ))
  
unSub.sent = unSub.sent[1:4,]


t = zoo(unSub.sent$c,unSub.sent$EventUnixdate)
t.c = merge(t, zoo(,seq(start(t),end(t),by="1 day")), all=TRUE)
t.c[is.na(t.c)] <- 0

rollapply(t.c,6,sum)


# %>%
#  group_by(CRMEmailKey) %>%
#  mutate(roll_sum2 = roll_sum(EventUnixtime,2,c(-1)))

# roll_sum(count, 2, align = "right", fill = NAoll_sum(count, 2, align = "right", fill = NA)


unSub.open = filter(unSub, EventTypeId == 3) %>% group_by(CRMEmailKey) %>% 
  summarise(firstOpen = min(EventUnixtime), 
            lastOpen = max(EventUnixtime), 
            daysOpenActivity =  (max(EventUnixtime)-min(EventUnixtime))/(60*60*24), 
            fOpen = n()/(1+(max(EventUnixtime)-min(EventUnixtime))/(60*60*24)),
            cOpen = n()) %>% filter(cOpen<200) %>%
  arrange(desc(CRMEmailKey))
unSub.click = filter(unSub, EventTypeId == 2) %>% group_by(CRMEmailKey) %>% 
  summarise(firstClick = min(EventUnixtime), lastClick = max(EventUnixtime), c = n())
unSub.unsub = filter(unSub, EventTypeId == 4) %>% group_by(CRMEmailKey) %>% 
  summarise(firstUnsub = min(EventUnixtime), lastUnsub = max(EventUnixtime), cUnsub = n())

ggplot(unSub.open, aes(x=daysActivity,y=c)) + geom_point()


a = merge(unSub.sent, unSub.unsub)
a = filter(a, fSent <= 1, fOpen <= 1)
ggplot(a, aes(x=cSent,y=(fOpen/fSent))) + geom_point() +

  ggplot(unSub.sent, aes(x=daysSentActivity,y=cSent)) + geom_point() +
  geom_density2d() +
  stat_density2d(aes(fill = log(..level..), alpha = log(..level..)),size = 0.05, n=100, geom = 'polygon') +
  scale_fill_gradient(low = "green", high = "red") +
  scale_alpha(range = c(0.0, 1.0), guide = FALSE) 



  8414645  1438617264	1448912490	119.1577	0.69908124	84
8	9153168	1438618027	1448915821	119.1874	0.69890836	84
9	26357533	1438616998	1448912066	119.1559	0.68244684	82
10	1242028	1438617116	1448912763	119.1626	0.63247643	76
11	54859	1438692469	1448911546	118.2764	0.62879186	75
12	7241562	1438616493	1448911095	119.1505	0.62421720	75
13	8819097	1438617877	1448914855	119.1780	0.62407436	75
14	25842144	1438618501	1448915650	119.1800	0.62406408	75
15	4116852	1438616768	1448911675	119.1540	0.60755356	73
16	7789638	1438616841	1448911783	119.1544	0.60755151	73
17	91152655


unSub.sum = group_by(unSub, CRMEmailKey) %>% summarise(firstSent = min()) %>% ungroup()



unSub.sum = group_by(unSub, SourceCode, EventTypeId) %>% summarise(c = n()) %>% ungroup()

unSub.sum = group_by(unSub, CRMEmailKey) %>% summarise(firstSent = min()) %>% ungroup()

unSub.sum$EventTypeDesc = sapply(unSub.sum$EventTypeId, EventLookup)

unSub.sum2 = dcast(unSub.sum, SourceCode~EventTypeDesc, value.var="c")
  


unSub.sum2$UnHappy = (unSub.sum2$Unsub/unSub.sum2$Open)
unSub.sum2 = filter(unSub.sum2, UnHappy <= 1) %>% arrange( desc(UnHappy))

#    A  B D.c1 D.c2 D.c3
# 1 a1 b1   d1   d2   d3
# 4 a2 b2   d1 <NA>   d3



unSub.test = filter(unSub, SourceCode == "CRM-0X000000F08FCF6FEE" & EventTypeId == 5)

ggplot(data = unSub.test,aes(x=unSub.test$EventUnixtime, y=unSub.test$CRMEmailKey))+geom_point() 


ggplot(data = unSub.test,aes(x=unSub.test$EventUnixtime, y=unSub.test$EventTypeDescr))+geom_point() 

