import math
from GODA5 import GODA5


# Subroutine calculates the effective refraction coefficeint Kreff based
# on Goda's method for random wave refraction analysis. The frequencies to
# be analyzed are calculated based on an assumed Bretschnieder-Mitsuyasu
# spectrum. The refraction coefficient of each frequency and direction
# component (based on Snell's Law) are then weight according to the Goda's
# method to yield Kreff.

def GODA4(direc, Ts, d, Hdeep, g):
    deg2rad = math.pi / 180
    M = 10
    diff = 100
    sumsq = 0
    sumkr = 0
    d10 = [0.05, 0.11, 0.21, 0.26, 0.21, 0.11, 0.05]
    d25 = [0.02, 0.06, 0.23, 0.38, 0.23, 0.06, 0.02]
    d75 = [0.00, 0.02, 0.18, 0.60, 0.18, 0.02, 0.00]

    for i in range(1, 7):
        direcr = direc * deg2rad

        for j in range(1, 10):
            if j == 1:
                if direcr > 0:
                    # TODO something wrong here
                    theta[1] = direcr - (67.5 * deg2rad)
                else:
                    theta[1] = -(abs(direcr) + (67.5 * deg2rad))

            F = (1.007 / Ts) * (math.log10(2 * M / (2 * j - 1))**(-0.25))
            omg = 2 * math.pi * F
            T = 2 * math.pi / omg
            Lo = (g / (2 * math.pi)) * T**2
            Co = Lo / T
            dLo = d / Lo
            dL = GODA5(dLo)
            L = d / dL
            Cr[j] = L / T
            th = theta[i]
            argu = (Cr[j] / Co) * math.sin(th)
            if abs(argu) > 1.00:
                argu = 0.9999999
            theta2 = math.asin(argu)
            if th >= (math.pi / 2):
                theta2 = math.pi-theta2
            elif th <= (-math.pi / 2):
                theta2 = -(math.pi - theta2)
            argm = math.cos(th) / math.cos(theta2)
            kr[i, j] = math.sqrt(abs(argm))
            sumsq = sumsq + kr[i, j]**2

            sumsqkr[i] = sumsq
            sumsq = 0
            theta[i+1] = theta[i] + (22.5 * deg2rad)

    Kreff2 = 1.0
    N = 0

    while diff > 0.005 and N <= 20:
        Los = (g / (2 * math.pi)) * Ts**2
        dLos = d / Los
        dLs = GODA5(dLos)
        H = Kreff2 * Hdeep
        L = d / dLs
        HL = H / L

        if Ts <= 10:
            for i in range(1, 7):
                sumkr = sumkr + (d10[i] / 10) * sumsqkr[i]
            end
        elif Ts > 10 and HL > 0.02:
            for i in range(1, 7):
                sumkr = sumkr + (d25[i] / 10) * sumsqkr[i]
            end
        else:
            for i in range(1, 7):
                sumkr = sumkr + (d75[i] / 10) * sumsqkr[i]

        Kreff = math.sqrt(sumkr)
        sumkr = 0
        diff = abs(Kreff2 - Kreff) / Kreff2
        Kreff2 = Kreff

        N = N + 1

    return Kreff
