import os
import shutil
import numpy as np
import matplotlib.pyplot as plt

dll_name = 'testBilin'
dll_path = './{0}//x64/Release/{0}.dll'.format(dll_name)

if os.path.isfile(dll_name + '.dll'):
    os.remove(dll_name + '.dll')
shutil.copy(dll_path, './')

os.system("opensees test_material.tcl")
fig, ax = plt.subplots(1,1)
disp = np.loadtxt('Disp.out').T[1]
force = np.loadtxt('Force.out').T[-1]
ax.axhline(y=0,c='r')
ax.axvline(x=0,c='r')
ax.plot(disp, force)
ax.grid()
plt.show()