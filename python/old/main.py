# from snells_law import *
from linear_wave_theory import *
import math

def main():
    '''
    temp =
        temp.H1, temp.T, temp.d1, temp.alpha1, temp.cotphi, temp.d2, temp.H0,
        temp.H2, temp.alpha0, temp.alpha2, temp.L0, temp.L1, temp.L2, temp.c1,
        temp.c0, temp.cg1, temp.cg0, temp.cg2, temp.E1, temp.E0, temp.E2,
        temp.P1, temp.P0, temp.P2, temp.HL, temp.Ur1, temp.Ur2, temp.Hb, temp.db
        = snellsLaw(6, 10, 18, 6, 100, 13)
    # temp.toString()
    '''
    temp = LinearWaveTheoryOutput()
    temp.H, temp.T, temp.d, temp.z, temp.xL, temp.L, temp.C, temp.Cg, temp.E, \
        temp.Ef, temp.Ur, temp.eta, temp.px, temp.py, temp.pz, temp.u, temp.w, \
        temp.dudt, temp.dwdt, temp.pres = \
        linearWaveTheory(6.30, 8, 20.0, -12.0, 0.75, 'I')
    temp.toString()
    '''
    testPlot(temp)

def testPlot(obj):
    tot = obj.d + obj.z
    t = np.arange(-1, 1, 0.001)
    plottheta = t * np.pi * 2

    ploteta = (obj.H / 2) * np.cos(plottheta)
    plotu = (obj.H * np.pi / obj.T) * (np.cosh(obj.k * tot) / np.sinh(obj.k * obj.d)) * np.cos(plottheta)
    # plotw=(H*pi/T)*(sinh(k*tot)/sinh(k*d))*sin(plottheta);

    plt.subplot(2, 1, 1)
    plt.plot(t, ploteta, lw=2)
    plt.ylabel('Elevation [m]')
    plt.ylim(-4, 4)

    # ref line
    plt.axhline(color = 'r', linestyle = '--')
    # subplot
    plt.subplot(2, 1, 2)
    plt.plot(t, plotu, lw=2)
    plt.axhline(color = 'r', linestyle = '--')

    plt.show()
'''
#main()

def testCommandLineInput():
    print("Function: Linear Wave Theory")
    unitSystem = raw_input("Enter a unit system (M or I): ")
    #print("You entered: %s" % unitSystem)
    H = raw_input("Wave Height (H): ")
    T = raw_input("Wave Period (T): ")
    d = raw_input("Water Depth (d): ")
    z = raw_input("Vertical Coordinate (z): ")
    xL = raw_input("Horizontal coordinate as fraction of wavelength (x/L): ")
    temp = LinearWaveTheoryOutput()
    temp.H, temp.T, temp.d, temp.z, temp.xL, temp.L, temp.C, temp.Cg, temp.E, \
        temp.Ef, temp.Ur, temp.eta, temp.px, temp.py, temp.pz, temp.u, temp.w, \
        temp.dudt, temp.dwdt, temp.pres = \
        linearWaveTheory(float(H), float(T), float(d), float(z), float(xL), unitSystem)
    temp.toString()


testCommandLineInput()

# temporarily placing here
class LinearWaveTheoryOutput:
    # input
    H1 = 0
    T = 0
    d1 = 0
    alpha1 = 0
    cotphi = 0
    d2 = 0
    # output
    H0 = 0
    H2 = 0
    alpha0 = 0
    alpha2 = 0
    L0 = 0
    L1 = 0
    L2 = 0
    c1 = 0
    c0 = 0
    c2 = 0
    cg1 = 0
    cg0 = 0
    cg2 = 0
    E1 = 0
    E0 = 0
    E2 = 0
    P1 = 0
    P0 = 0
    P2 = 0
    HL = 0
    Ur1 = 0
    Ur2 = 0
    Hb = 0
    db = 0

    def __init__(self): pass

    def toString(self):
        print("\t\t\t %s \t\t %s \t\t %s \n" % ("Known", "Deepwater", "Subject"));
        print("%s \t\t %-5.2f \t\t %-5.2f \t\t\t %-5.2f \n" % ("Wave height", self.H1, self.H0, self.H2))
        print("%s \t %-5.2f \t\t %-5.2f \t\t\t %-5.2f \n" % ("Wave crest angle", self.alpha1, self.alpha0, self.alpha2))
        print("%s \t\t %-5.2f \t\t %-5.2f \t\t %-5.2f \n" % ("Wavelength", self.L1, self.L0, self.L2))
        print("%s \t\t %-5.2f \t\t %-5.2f \t\t\t %-5.2f \n" % ("Celerity", self.c1, self.c0, self.c2))
        print("%s \t\t %-5.2f \t\t %-5.2f \t\t\t %-5.2f \n" % ("Group speed", self.cg1, self.cg0, self.cg2))
        print("%s \t\t %-8.2f \t %-8.2f \t\t %-8.2f \n" % ("Energy density", self.E1, self.E0, self.E2))
        print("%s \t\t %-8.2f \t %-8.2f \t\t %-8.2f \n" % ("Energy flux", self.P1, self.P0, self.P2))
        print("%s \t\t %-5.2f \t\t %-5.2f \n" % ("Ursell number", self.Ur1, self.Ur2))
        print("%s \t\t\t\t\t %-5.2f \n" % ("Wave steepness", self.HL))
        print("\n")
        print("%s \n" % ("Breaking parameters"))
        print("%s \t %-5.2f \n" % ("Breaking height", self.Hb))
        print("%s \t %-5.2f \n" % ("Breaking depth", self.db))
