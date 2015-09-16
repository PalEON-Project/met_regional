# Checking the precip alignment because something is breaking at the 1850 splice

library(raster)

# Cell present post-1949 but has no precip
p1849.12 <- stack("met_examples/precipf/precipf_1849_12.nc")
p1849.12x <- mean(p1849.12)
plot(p1849.12x)

p1850.01 <- stack("met_examples/precipf/precipf_1850_01.nc")
p1850.01x <- mean(p1850.01)
plot(p1850.01x)

p1950.01 <- stack("met_examples/precipf/precipf_1950_01.nc")
p1950.01x <- mean(p1950.01)
plot(p1950.01x)

# Cell Present in raw CCSM4
pc0850.01 <- stack("met_examples/precipf_ccsm4_raw/precipf_0850_01.nc")
pc0850.01x <- mean(pc0850.01)
plot(pc0850.01x)

pc1849.12 <- stack("met_examples/precipf_ccsm4_raw/precipf_1849_12.nc")
pc1849.12x <- mean(pc1849.12)
plot(pc1849.12x)

pc1850.01 <- stack("met_examples/precipf_ccsm4_raw/precipf_1850_01.nc")
pc1850.01x <- mean(pc1850.01)
plot(pc1850.01x)

pc1950.01 <- stack("met_examples/precipf_cru/precipf_1950_01.nc")
pc1950.01x <- mean(pc1950.01)
plot(pc1950.01x)

# Cru


# ---- CELL MISSING by script #3! --- 
pf1849.12 <- stack("met_examples/precipf_final_out/precipf_1849_12.nc")
pf1849.12x <- mean(pf1849.12)
plot(pf1849.12x)

pf1850.01 <- stack("met_examples/precipf_final_out/precipf_1850_06.nc")
pf1850.01x <- mean(pf1850.01)
plot(pf1850.01x)


t1849.12 <- stack("met_examples/tair/tair_1849_12.nc")
t1849.12x <- mean(t1849.12)
plot(t1849.12x, main="CCSM4 p1000, 1849")

t1850.01 <- stack("met_examples/tair/tair_1850_01.nc")
t1850.01x <- mean(t1850.01)
plot(t1850.01x, main="CCSM4 p1000, 1850")

t1950.01 <- stack("met_examples/tair/tair_1950_01.nc")
t1950.01x <- mean(t1950.01)
plot(t1950.01x, main="CRU, 1950")
